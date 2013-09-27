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

@end
