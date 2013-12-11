//
//  GBSFileWrapper.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "GBSFileWrapper.h"
#import "NSDictionary+subdictionaryWithKeys.h"

@interface GBSFileWrapper ()

@property (readonly) NSMutableDictionary * cachedResourceValues;

@end

@implementation GBSFileWrapper

- (id)initWithDataSource:(id<GBSFileWrapperDataSource>)dataSource resourceValues:(id<GBSFileWrapperResourceValues>)resourceValues {
    NSParameterAssert(dataSource);
    
    if((self = [super init])) {
        _dataSource = dataSource;
        _resourceValues = resourceValues;
        
        _cachedResourceValues = [NSMutableDictionary new];
    }
    return self;
}

- (void)substituteEquivalentDataSource:(id<GBSFileWrapperDataSource>)dataSource {
    _dataSource = dataSource;
}

- (GBSFileWrapperType)type {
    return [self.dataSource typeForFileWrapper:self];
}

- (id<GBSFileWrapperContents>)contents {
    switch (self.type) {
        case GBSFileWrapperTypeNil:
            return nil;
            
        case GBSFileWrapperTypeRegularFile:
            return [self.dataSource regularFileContentsForFileWrapper:self];
            
        case GBSFileWrapperTypeDirectory:
            return [self.dataSource directoryContentsForFileWrapper:self];
            
        case GBSFileWrapperTypeSymbolicLink:
            return [self.dataSource symbolicLinkContentsForFileWrapper:self];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[GBSMutableFileWrapper alloc] initWithDataSource:[self.dataSource copyFromFileWrapper:self] resourceValues:[self.resourceValues copyFromFileWrapper:self]];
}

- (NSUInteger)hash {
    return [self.contents hash] << 2 | self.type;
}

- (BOOL)isEqual:(GBSFileWrapper*)object {
    if(self == object) {
        return YES;
    }
    
    if(![object isKindOfClass:GBSFileWrapper.class]) {
        return NO;
    }
    
    return self.type == object.type && [self.contents isEqual:object.contents];
}

- (id)resourceValueForKey:(NSString *)key {
    return [self resourceValuesForKeys:@[ key ]][key];
}

- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys {
    NSArray * newKeys;
    NSMutableDictionary * values = [[self.cachedResourceValues subdictionaryWithKeys:keys notFoundKeys:&newKeys] mutableCopy];
    
    if(newKeys.count) {
        NSDictionary * newValues = [self.resourceValues resourceValuesForKeys:newKeys];
        [self.cachedResourceValues addEntriesFromDictionary:newValues];
        [values addEntriesFromDictionary:newValues];
    }
    
    return values;
}

- (GBSMutableFileWrapper*)recursiveMutableCopy {
    if(self.type != GBSFileWrapperTypeDirectory) {
        return [self mutableCopy];
    }
    
    GBSMutableFileWrapper * copy = [[GBSMutableFileWrapper alloc] initWithContents:@{} resourceValues:self.resourceValues];
    
    for(NSString * name in self.contents) {
        [copy setContentsChildFileWrapper:[self.contents[name] recursiveMutableCopy] forName:name];
    }
    
    return copy;
}

@end
