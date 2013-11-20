//
//  GBSFileWrapper+URL.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "GBSFileWrapper+URL.h"
#import "GBSFileWrapper+NSFileWrapper.h"

NSString * const GBSFileWrapperContentsInaccessibleException = @"GBSFileWrapperContentsInaccessible";
#define GBSAssertSucceeded(operation, error) if(!(operation)) { \
@throw [NSException exceptionWithName:GBSFileWrapperContentsInaccessibleException reason:[NSString stringWithFormat:@"The file at %@ cannot be accessed: %@.", self.URL.filePathURL.absoluteString, error.localizedDescription] userInfo:@{ NSUnderlyingErrorKey: error }]; \
}

@interface GBSFileWrapperURLDataSource : NSObject <GBSFileWrapperDataSource>

@property NSURL * URL;
@property BOOL withoutMapping;

- (id)initWithURL:(NSURL*)URL withoutMapping:(BOOL)mapping;

@end

@interface NSURL (GBSFileWrapperResourceValues) <GBSFileWrapperResourceValues> @end

@implementation GBSFileWrapper (URL)

+ (NSArray *)writableResourceValueKeys {
    static NSArray * singleton;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        singleton = @[ NSURLIsSystemImmutableKey, NSURLIsUserImmutableKey, NSURLIsHiddenKey, NSURLHasHiddenExtensionKey, NSURLCreationDateKey, NSURLContentAccessDateKey, NSURLContentModificationDateKey, NSURLAttributeModificationDateKey, NSURLCustomIconKey, NSURLFileSecurityKey, NSURLIsExcludedFromBackupKey, NSURLTagNamesKey ];
    });
    
    return singleton;
}

+ (NSArray *)persistentResourceValueKeys {
    static NSArray * singleton;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        NSIndexSet * indexes = [[self writableResourceValueKeys] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return ![@[ NSURLContentAccessDateKey, NSURLContentModificationDateKey, NSURLAttributeModificationDateKey ] containsObject:obj];
        }];
        
        singleton = [[self writableResourceValueKeys] objectsAtIndexes:indexes];
    });
    
    return singleton;
}

- (id)initWithURL:(NSURL *)URL options:(GBSFileWrapperReadingOptions)options error:(NSError *__autoreleasing *)error {
    if(![URL checkResourceIsReachableAndReturnError:error]) {
        return nil;
    }
    
    GBSFileWrapperURLDataSource * dataSource = [[GBSFileWrapperURLDataSource alloc] initWithURL:URL withoutMapping:(options & GBSFileWrapperReadingWithoutMapping)];
    
    if((self = [self initWithDataSource:dataSource resourceValues:[URL fileReferenceURL]])) {
        if(options & GBSFileWrapperReadingImmediate) {
            @try {
                [self loadContents];
            }
            @catch (NSException *exception) {
                if(![exception.name isEqualToString:GBSFileWrapperContentsInaccessibleException]) {
                    @throw;
                }
                
                if(error) {
                    *error = exception.userInfo[NSUnderlyingErrorKey];
                }
                return nil;
            }
        }
    }
    
    return self;
}

- (void)loadContents {
    [self contents];
    
    if(self.type == GBSFileWrapperTypeDirectory) {
        for(GBSFileWrapper * wrapper in [self.contents allValues]) {
            [wrapper loadContents];
        }
    }
}

- (BOOL)gbs_applyResourceValueKeys:(NSArray*)keys toURL:(NSURL*)URL error:(NSError**)error {
    NSDictionary * values = [self resourceValuesForKeys:keys];
    return [URL setResourceValues:values error:error];
}

- (BOOL)writeToURL:(NSURL *)URL withResourceValueKeys:(NSArray*)keys options:(GBSFileWrapperWritingOptions)options error:(NSError *__autoreleasing *)error {
    NSFileManager * manager = [NSFileManager new];
    
    if(options & GBSFileWrapperWritingAtomic) {
        NSURL * tempDirURL = [manager URLForDirectory:NSItemReplacementDirectory inDomain:NSUserDomainMask appropriateForURL:URL create:YES error:error];
        NSURL * tempURL = [tempDirURL URLByAppendingPathComponent:URL.lastPathComponent];
        
        BOOL writeOK = [self writeToURL:tempURL withResourceValueKeys:keys options:GBSFileWrapperWritingWithoutOverwriting | _GBSFileWrapperWritingWithoutResourceValueKeys error:error];
        
        [manager removeItemAtURL:tempDirURL error:NULL];
        
        if(!writeOK) {
            return NO;
        }
        
        if(![manager replaceItemAtURL:URL withItemAtURL:tempURL backupItemName:nil options:0 resultingItemURL:nil error:error]) {
            return NO;
        }
        
        return [self gbs_applyResourceValueKeys:keys toURL:URL error:error];
    }
    
    if(!(options & GBSFileWrapperWritingWithoutOverwriting)) {
        [manager removeItemAtURL:URL error:NULL];
    }
    
    switch (self.type) {
        case GBSFileWrapperTypeDirectory:
            if(![manager createDirectoryAtURL:URL withIntermediateDirectories:NO attributes:nil error:error]) {
                return NO;
            }
            
            for(NSString * name in self.contents) {
                GBSFileWrapper * child = self.contents[name];
                
                if(![child writeToURL:[URL URLByAppendingPathComponent:name] withResourceValueKeys:keys options:0 error:error]) {
                    return NO;
                }
            }
            
            break;
            
        case GBSFileWrapperTypeRegularFile:
            if(![self.contents writeToURL:URL options:0 error:error]) {
                return NO;
            }
            break;
            
        case GBSFileWrapperTypeSymbolicLink: {
            NSURL * relativeContents = [NSURL URLWithString:[self.contents relativePath] relativeToURL:nil];
            
            if(![manager createSymbolicLinkAtURL:URL withDestinationURL:relativeContents error:error]) {
                return NO;
            }
            
            break;
        }
            
        case GBSFileWrapperTypeNil:
            NSAssert(self.type != GBSFileWrapperTypeNil, @"Attempted to write a nil file wrapper");
            return NO;
    }
    
    return options & _GBSFileWrapperWritingWithoutResourceValueKeys ? YES : [self gbs_applyResourceValueKeys:keys toURL:URL error:error];
}

@end

@implementation GBSFileWrapperURLDataSource

- (id)initWithURL:(NSURL *)URL withoutMapping:(BOOL)mapping {
    if((self = [super init])) {
        _URL = [URL fileReferenceURL] ?: URL;
        _withoutMapping = mapping;
    }
    return self;
}

- (GBSFileWrapperType)typeForFileWrapper:(GBSFileWrapper *)fileWrapper {
    NSError * error;
    NSString * type;
    
    GBSAssertSucceeded([self.URL getResourceValue:&type forKey:NSURLFileResourceTypeKey error:&error], error);
    
    return [@{ NSURLFileResourceTypeDirectory: @(GBSFileWrapperTypeDirectory), NSURLFileResourceTypeRegular: @(GBSFileWrapperTypeRegularFile), NSURLFileResourceTypeSymbolicLink: @(GBSFileWrapperTypeSymbolicLink) }[type] integerValue];
}

- (GBSFileWrapperMemoryDataSource*)substituteIntoFileWrapper:(GBSFileWrapper*)fileWrapper withContents:(id <GBSFileWrapperContents>)contents {
    GBSFileWrapperMemoryDataSource * dataSource = [[GBSFileWrapperMemoryDataSource alloc] initWithContents:contents];
    
    [fileWrapper substituteEquivalentDataSource:dataSource];
    
    return dataSource;
}

- (NSData *)regularFileContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    NSDataReadingOptions options = self.withoutMapping ? 0 : NSDataReadingMappedIfSafe;
    NSError * error;
    NSData * data = [[NSData alloc] initWithContentsOfURL:self.URL options:options error:&error];
    
    GBSAssertSucceeded(data, error);
        
    return [[self substituteIntoFileWrapper:fileWrapper withContents:data] regularFileContentsForFileWrapper:fileWrapper];
}

- (NSDictionary *)directoryContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    NSMutableDictionary * contents = [NSMutableDictionary new];
    
    __block BOOL ok = YES;
    __block NSError * error;
    
    for(NSURL * childURL in [[NSFileManager new] enumeratorAtURL:self.URL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *inError) {
        ok = NO;
        error = inError;
        return NO;
    }]) {
        GBSFileWrapper * wrapper = [(GBSFileWrapper*)[fileWrapper.class alloc] initWithURL:childURL options:self.withoutMapping ? GBSFileWrapperReadingWithoutMapping : 0 error:&error];
        
        if(wrapper) {
            contents[childURL.filePathURL.lastPathComponent] = wrapper;
        }
        else {
            ok = NO;
            break;
        }
    }
    
    GBSAssertSucceeded(ok, error);
    
    return [[self substituteIntoFileWrapper:fileWrapper withContents:contents] directoryContentsForFileWrapper:fileWrapper];
}

- (NSURL *)symbolicLinkContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    NSError * error;
    NSString * path = [[NSFileManager new] destinationOfSymbolicLinkAtPath:self.URL.path error:&error];
    
    GBSAssertSucceeded(path, error);
    
    NSURL * url = [NSURL URLWithString:path relativeToURL:self.URL];
    
    return [[self substituteIntoFileWrapper:fileWrapper withContents:url] symbolicLinkContentsForFileWrapper:fileWrapper];
}

- (id<GBSFileWrapperDataSource>)copyFromFileWrapper:(GBSFileWrapper *)fileWrapper {
    return [[GBSFileWrapperURLDataSource alloc] initWithURL:self.URL withoutMapping:self.withoutMapping];
}

- (void)setNilContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    [self substituteIntoFileWrapper:fileWrapper withContents:nil];
}

- (void)setRegularFileContents:(NSData *)contents forFileWrapper:(GBSFileWrapper *)fileWrapper {
    [self substituteIntoFileWrapper:fileWrapper withContents:contents];
}

- (void)setSymbolicLinkContents:(NSURL *)contents forFileWrapper:(GBSFileWrapper *)fileWrapper {
    contents = [NSURL URLWithString:contents.relativePath relativeToURL:self.URL];
    [self substituteIntoFileWrapper:fileWrapper withContents:contents];
}

- (void)makeDirectoryContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    [self substituteIntoFileWrapper:fileWrapper withContents:@{}];
}

- (void)addDirectoryContents:(NSDictionary *)dictionaryOfNamesAndFileWrappersOrNulls {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)removeAllDirectoryContents {
    [self doesNotRecognizeSelector:_cmd];
}

@end

@implementation NSURL (GBSFileWrapperResourceValues)

- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys {
    NSError * error;
    NSDictionary * values = [self resourceValuesForKeys:keys error:&error];
    GBSAssertSucceeded(values, error);
    
    return values;
}

- (id<GBSFileWrapperResourceValues>)copyFromFileWrapper:(GBSFileWrapper *)fileWrapper {
    return self;
}

- (NSURL*)URL {
    return self;
}

@end
