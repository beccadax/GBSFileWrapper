//
//  GBSFileWrapper+Memory.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "GBSFileWrapper+Memory.h"

@implementation GBSFileWrapper (Memory)

- (id)init {
    return [self initWithContents:nil resourceValues:nil];
}

- (id)initWithContents:(id<GBSFileWrapperContents>)contents resourceValues:(NSDictionary *)resourceValues {
    GBSFileWrapperMemoryDataSource * source = [[GBSFileWrapperMemoryDataSource alloc] initWithContents:contents resourceValues:resourceValues];
    
    return [self initWithDataSource:source];
}

@end

@interface GBSFileWrapperMemoryDataSource ()

@property (strong) id <GBSFileWrapperContents> contents;
@property (strong) NSDictionary * resourceValues; 

@end

@interface GBSFileWrapperMemoryMutableDataSource ()

@property (strong) NSMutableDictionary * resourceValues; 

@end

@implementation GBSFileWrapperMemoryDataSource

- (id)initWithContents:(id<GBSFileWrapperContents>)contents resourceValues:(NSDictionary *)resourceValues {
    if((self = [super init])) {
        _contents = contents;
        _resourceValues = resourceValues;
    }
    return self;
}

- (id)init {
    return [self initWithContents:nil resourceValues:@{}];
}

- (GBSFileWrapperType)typeForFileWrapper:(GBSFileWrapper *)fileWrapper {
    return [self.contents typeForFileWrapper:fileWrapper];
}

- (NSData *)regularFileContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    return (id)self.contents;
}

- (NSDictionary *)directoryContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    return (id)self.contents;
}

- (NSURL *)symbolicLinkContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    return (id)self.contents;
}

- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys error:(NSError *__autoreleasing *)error {
    NSArray * objects = [self.resourceValues objectsForKeys:keys notFoundMarker:[NSNull null]];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
    [dict removeObjectsForKeys:[dict allKeysForObject:[NSNull null]]];
    
    return dict;
}

- (id<GBSFileWrapperDataSource>)copyFromFileWrapper:(GBSFileWrapper *)fileWrapper {
    return self;
}

- (GBSFileWrapperMemoryMutableDataSource*)substituteIntoFileWrapper:(GBSFileWrapper*)fileWrapper {
    GBSFileWrapperMemoryMutableDataSource * mutableDataSource = [[GBSFileWrapperMemoryMutableDataSource alloc] initWithContents:self.contents resourceValues:self.resourceValues];
    
    [fileWrapper substituteEquivalentDataSource:mutableDataSource];
    
    return mutableDataSource;
}

- (void)setRegularFileContents:(NSData *)contents forFileWrapper:(GBSFileWrapper *)fileWrapper {
    [[self substituteIntoFileWrapper:fileWrapper] setRegularFileContents:contents forFileWrapper:fileWrapper];
}

- (void)setSymbolicLinkContents:(NSURL *)contents forFileWrapper:(GBSFileWrapper *)fileWrapper {
    [[self substituteIntoFileWrapper:fileWrapper] setSymbolicLinkContents:contents forFileWrapper:fileWrapper];
}

- (void)makeDirectoryContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    [[self substituteIntoFileWrapper:fileWrapper] makeDirectoryContentsForFileWrapper:fileWrapper];
}

- (void)addDirectoryContents:(NSDictionary *)dictionaryOfNamesAndFileWrappersOrNulls {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)removeAllDirectoryContents {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)setNilContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    [[self substituteIntoFileWrapper:fileWrapper] setNilContentsForFileWrapper:fileWrapper];
}

- (void)updateResourceValues:(NSDictionary *)values forFileWrapper:(GBSFileWrapper *)fileWrapper {
    [[self substituteIntoFileWrapper:fileWrapper] updateResourceValues:values forFileWrapper:fileWrapper];
}

@end

@implementation GBSFileWrapperMemoryMutableDataSource

@dynamic resourceValues;

- (id)initWithContents:(id<GBSFileWrapperContents>)contents resourceValues:(NSDictionary *)resourceValues {
    contents = [contents typeForFileWrapper:nil] == GBSFileWrapperTypeDirectory ? [(id)contents mutableCopy] : contents;
    resourceValues = [resourceValues mutableCopy];
    
    return [super initWithContents:contents resourceValues:resourceValues];
}

- (id<GBSFileWrapperDataSource>)copyFromFileWrapper:(GBSFileWrapper *)fileWrapper {
    return [[self.class alloc] initWithContents:self.contents resourceValues:self.resourceValues];
}

- (GBSFileWrapperMemoryMutableDataSource*)substituteIntoFileWrapper:(GBSFileWrapper*)fileWrapper {
    return self;
}

- (void)setRegularFileContents:(NSData *)contents forFileWrapper:(GBSFileWrapper *)fileWrapper {
    self.contents = contents;
}

- (void)setSymbolicLinkContents:(NSURL *)contents forFileWrapper:(GBSFileWrapper *)fileWrapper {
    self.contents = contents;
}

- (void)makeDirectoryContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    if([self typeForFileWrapper:fileWrapper] == GBSFileWrapperTypeDirectory) {
        return;
    }
    
    self.contents = [NSMutableDictionary new];
}

- (void)addDirectoryContents:(NSDictionary *)dictionaryOfNamesAndFileWrappersOrNulls {
    NSParameterAssert([self typeForFileWrapper:nil] == GBSFileWrapperTypeDirectory);
    
    [(NSMutableDictionary*)self.contents addEntriesFromDictionary:dictionaryOfNamesAndFileWrappersOrNulls];
    [(NSMutableDictionary*)self.contents removeObjectsForKeys:[(NSMutableDictionary*)self.contents allKeysForObject:[NSNull null]]];
}

- (void)removeAllDirectoryContents {
    NSParameterAssert([self typeForFileWrapper:nil] == GBSFileWrapperTypeDirectory);
    
    [(NSMutableDictionary*)self.contents removeAllObjects];
}

- (void)setNilContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    self.contents = nil;
}

- (void)updateResourceValues:(NSDictionary *)values forFileWrapper:(GBSFileWrapper *)fileWrapper {
    [self.resourceValues addEntriesFromDictionary:values];
    [self.resourceValues removeObjectsForKeys:[self.resourceValues allKeysForObject:[NSNull null]]];
}

@end
