//
//  GBSFileWrapper.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "GBSFileWrapper.h"

@implementation GBSFileWrapper

- (id)initWithDataSource:(id<GBSFileWrapperDataSource>)dataSource {
    NSParameterAssert(dataSource);
    
    if((self = [super init])) {
        _dataSource = dataSource;
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

- (BOOL)getResourceValue:(out id *)value forKey:(NSString *)key error:(out NSError **)error {
    NSDictionary * dict = [self resourceValuesForKeys:@[ key ] error:error];
    if(!dict) {
        return NO;
    }
        
    *value = dict[key];
    return YES;
}

- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys error:(NSError **)error {
    return [self.dataSource resourceValuesForKeys:keys error:error];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[GBSMutableFileWrapper alloc] initWithDataSource:[self.dataSource copyFromFileWrapper:self]];
}

- (NSUInteger)hash {
    return [self.contents hash] << 2 | self.type;
}

- (BOOL)isEqual:(GBSFileWrapper*)object {
    if(![object isKindOfClass:GBSFileWrapper.class]) {
        return NO;
    }
    
    return self.type == object.type && [self.contents isEqual:object.contents];
}

@end
