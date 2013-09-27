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
    GBSFileWrapperMemoryDataSource * source = [GBSFileWrapperMemoryDataSource new];
    source.contents = contents;
    [source.resourceValues addEntriesFromDictionary:resourceValues];
    
    return [self initWithDataSource:source];
}

@end

@implementation GBSFileWrapperMemoryDataSource

- (id)init {
    if((self = [super init])) {
        _resourceValues = [NSMutableDictionary new];
    }
    return self;
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

@end
