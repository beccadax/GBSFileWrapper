//
//  GBSFileWrapper+NSFileWrapper.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "GBSFileWrapper+NSFileWrapper.h"
#import "NSFileSecurity+GBSExtensions.h"
#import <objc/runtime.h>
#import <pwd.h>
#import <grp.h>

@interface NSFileWrapper (GBSFileWrapperDataSource) <GBSFileWrapperDataSource>

@end

@implementation GBSFileWrapper (NSFileWrapper)

- (id)initWithNSFileWrapper:(NSFileWrapper *)nsFileWrapper {
    return [self initWithDataSource:nsFileWrapper];
}

- (NSFileWrapper *)NSFileWrapper {
    if([self.dataSource isKindOfClass:NSFileWrapper.class]) {
        return (id)self.dataSource;
    }
    
    NSFileWrapper * wrapper;
    
    switch (self.type) {
        case GBSFileWrapperTypeNil:
            wrapper = nil;
            break;
            
        case GBSFileWrapperTypeRegularFile:
            wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:self.contents];
            break;
            
        case GBSFileWrapperTypeSymbolicLink:
            wrapper = [[NSFileWrapper alloc] initSymbolicLinkWithDestinationURL:self.contents];
            break;
            
        case GBSFileWrapperTypeDirectory: {
            NSMutableDictionary * children = [NSMutableDictionary new];
            
            for(NSString * name in self.contents) {
                GBSFileWrapper * child = self.contents[name];
                children[name] = [child NSFileWrapper];
            }
            
            wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:children];
        }
    }
    
    NSMutableDictionary * attrs = [NSMutableDictionary new];
    
    NSNumber * noExtension;
    if([self getResourceValue:&noExtension forKey:NSURLHasHiddenExtensionKey error:NULL]) {
        attrs[NSFileExtensionHidden] = noExtension;
    }
    
    NSFileSecurity * security;
    if([self getResourceValue:&security forKey:NSURLFileSecurityKey error:NULL]) {
        NSNumber * mode = security.POSIXMode;
        if(mode) {
            attrs[NSFilePosixPermissions] = mode;
        }
        
        NSNumber * owner = security.POSIXOwner;
        if(owner) {
            attrs[NSFileOwnerAccountID] = owner;
            attrs[NSFileOwnerAccountName] = @(getpwuid(owner.integerValue)->pw_name);
        }
        
        NSNumber * group = security.POSIXGroup;
        if(group) {
            attrs[NSFileGroupOwnerAccountID] = group;
            attrs[NSFileGroupOwnerAccountName] = @(getgrgid(group.integerValue)->gr_name);
        }
    }
    
    wrapper.fileAttributes = attrs;
   
    return wrapper;
}

@end

@implementation NSFileWrapper (GBSFileWrapperDataSource)

- (GBSFileWrapperType)typeForFileWrapper:(GBSFileWrapper *)fileWrapper {
    if(self.isDirectory) {
        return GBSFileWrapperTypeDirectory;
    }
    else if(self.isRegularFile) {
        return GBSFileWrapperTypeRegularFile;
    }
    else if(self.isSymbolicLink) {
        return GBSFileWrapperTypeSymbolicLink;
    }
    else {
        NSAssert(NO, @"None of -isDirectory, -isRegularFile, or -isSymbolicLink is true!");
        return GBSFileWrapperTypeNil;
    }
}

- (NSData *)regularFileContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    return self.regularFileContents;
}

- (NSURL *)symbolicLinkContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    return self.symbolicLinkDestinationURL;
}

- (NSMutableDictionary *)cachedGBSFileWrappers {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCachedGBSFileWrappers:(NSMutableDictionary*)wrappers {
    objc_setAssociatedObject(self, @selector(cachedGBSFileWrappers), wrappers, OBJC_ASSOCIATION_RETAIN);
}

- (NSDictionary *)directoryContentsForFileWrapper:(GBSFileWrapper *)fileWrapper {
    NSMutableDictionary * childGBSWrappers = [self cachedGBSFileWrappers];
    
    if(!childGBSWrappers) {
        childGBSWrappers = [NSMutableDictionary new];
        
        NSDictionary * childNSWrappers = self.fileWrappers;
        
        for(NSString * name in childNSWrappers) {
            NSFileWrapper * childNSWrapper = childNSWrappers[name];
            childGBSWrappers[name] = [[GBSFileWrapper alloc] initWithNSFileWrapper:childNSWrapper];
        }
        
        [self setCachedGBSFileWrappers:childGBSWrappers];
    }
    
    return childGBSWrappers;
}

- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys error:(NSError *__autoreleasing *)error {
    NSMutableDictionary * dict = [NSMutableDictionary new];
    
    for(NSString * key in keys) {
        if([key isEqualToString:NSURLHasHiddenExtensionKey]) {
            dict[NSURLHasHiddenExtensionKey] = self.fileAttributes[NSFileExtensionHidden];
        }
        else if([key isEqualToString:NSURLFileSecurityKey]) {
            dict[NSURLFileSecurityKey] = [[NSFileSecurity alloc] initWithPOSIXMode:self.fileAttributes[NSFilePosixPermissions] owner:self.fileAttributes[NSFileOwnerAccountID] group:self.fileAttributes[NSFileGroupOwnerAccountID]];
        }
        else {
            NSAssert(NO, @"The resource value key %@ is not yet supported.", key);
        }
    }
    
    return dict;
}

- (id<GBSFileWrapperDataSource>)copyFromFileWrapper:(GBSFileWrapper *)fileWrapper {
    return self;
}

- (GBSFileWrapperMemoryMutableDataSource*)substituteIntoFileWrapper:(GBSFileWrapper*)fileWrapper {
    id <GBSFileWrapperContents> contents;
    NSDictionary * resourceValues = [self resourceValuesForKeys:@[ NSURLHasHiddenExtensionKey, NSURLFileSecurityKey ] error:NULL];
    
    switch ([self typeForFileWrapper:fileWrapper]) {
        case GBSFileWrapperTypeDirectory:
            contents = [self directoryContentsForFileWrapper:fileWrapper];
            break;
            
        case GBSFileWrapperTypeNil:
            contents = nil;
            break;
            
        case GBSFileWrapperTypeRegularFile:
            contents = [self regularFileContentsForFileWrapper:fileWrapper];
            break;
            
        case GBSFileWrapperTypeSymbolicLink:
            contents = [self symbolicLinkContentsForFileWrapper:fileWrapper];
            break;
    }
    
    GBSFileWrapperMemoryMutableDataSource * mutableDataSource = [[GBSFileWrapperMemoryMutableDataSource alloc] initWithContents:contents resourceValues:resourceValues];
    
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
