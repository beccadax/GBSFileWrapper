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

- (id)initWithContents:(id<GBSFileWrapperContents>)contents resourceValues:(id <GBSFileWrapperResourceValues>)resourceValues {
    GBSFileWrapperMemoryDataSource * source = [[GBSFileWrapperMemoryDataSource alloc] initWithContents:contents];
    
    return [self initWithDataSource:source resourceValues:resourceValues];
}

@end

@interface GBSFileWrapperMemoryDataSource ()

@property (strong) id <GBSFileWrapperContents> contents;

@end

@interface GBSFileWrapperMemoryMutableDataSource : GBSFileWrapperMemoryDataSource

@end

@implementation GBSFileWrapperMemoryDataSource

- (id)initWithContents:(id<GBSFileWrapperContents>)contents {
    if((self = [super init])) {
        _contents = contents;
    }
    return self;
}

- (id)init {
    return [self initWithContents:nil];
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

- (id<GBSFileWrapperDataSource>)copyFromFileWrapper:(GBSFileWrapper *)fileWrapper {
    return self;
}

- (GBSFileWrapperMemoryMutableDataSource*)substituteIntoFileWrapper:(GBSFileWrapper*)fileWrapper {
    GBSFileWrapperMemoryMutableDataSource * mutableDataSource = [[GBSFileWrapperMemoryMutableDataSource alloc] initWithContents:self.contents];
    
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

@end

@implementation GBSFileWrapperMemoryMutableDataSource

- (id)initWithContents:(id<GBSFileWrapperContents>)contents resourceValues:(NSDictionary *)resourceValues {
    contents = [contents typeForFileWrapper:nil] == GBSFileWrapperTypeDirectory ? [(id)contents mutableCopy] : contents;
    resourceValues = [resourceValues mutableCopy];
    
    return [super initWithContents:contents];
}

- (id<GBSFileWrapperDataSource>)copyFromFileWrapper:(GBSFileWrapper *)fileWrapper {
    return [[GBSFileWrapperMemoryMutableDataSource alloc] initWithContents:self.contents];
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

@end
