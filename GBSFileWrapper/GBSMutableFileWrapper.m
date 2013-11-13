//
//  GBSMutableFileWrapper.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 11/9/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "GBSMutableFileWrapper.h"

@implementation GBSMutableFileWrapper

- (void)setContents:(id)contents {
    switch ([contents typeForFileWrapper:self]) {
        case GBSFileWrapperTypeNil:
            [self.dataSource setNilContentsForFileWrapper:self];
            break;
            
        case GBSFileWrapperTypeRegularFile:
            [self.dataSource setRegularFileContents:[contents copy] forFileWrapper:self];
            break;
            
        case GBSFileWrapperTypeSymbolicLink:
            [self.dataSource setSymbolicLinkContents:contents forFileWrapper:self];
            break;
            
        case GBSFileWrapperTypeDirectory:
            [self.dataSource makeDirectoryContentsForFileWrapper:self];
            [self.dataSource removeAllDirectoryContents];
            [self.dataSource addDirectoryContents:contents];
            break;
    }
}

- (void)setContentsChildFileWrapper:(GBSFileWrapper *)childWrapper forName:(NSString *)name {
    [self.dataSource makeDirectoryContentsForFileWrapper:self];
    [self.dataSource addDirectoryContents:@{ name: childWrapper ?: [NSNull null] }];
}

- (NSString*)addContentsChildFileWrapper:(GBSFileWrapper *)childWrapper forPreferredName:(NSString *)preferredName {
    NSParameterAssert(childWrapper);
    
    NSString * name = preferredName;
    
    if(self.type == GBSFileWrapperTypeDirectory) {
        NSUInteger number = 2;
        while (self.contents[name]) {
            name = [NSString stringWithFormat:@"%@ %lu.%@", preferredName.stringByDeletingPathExtension, (unsigned long)number++, preferredName.pathExtension];
        }
    }
    
    [self setContentsChildFileWrapper:childWrapper forName:name];
    
    return name;
}

- (void)setResourceValue:(id)value forKey:(NSString *)key {
    [self setResourceValues:@{ key: value ?: [NSNull null] }];
}

- (void)setResourceValues:(NSDictionary *)keyedValues {
    [self.dataSource updateResourceValues:keyedValues forFileWrapper:self];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[GBSFileWrapper alloc] initWithDataSource:[self.dataSource copyFromFileWrapper:self]];
}

@end
