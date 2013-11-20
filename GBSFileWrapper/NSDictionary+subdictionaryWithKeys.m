//
//  NSDictionary+subdictionaryWithKeys.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 11/19/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "NSDictionary+subdictionaryWithKeys.h"

@implementation NSDictionary (subdictionaryWithKeys)

- (NSDictionary*)subdictionaryWithKeys:(NSArray*)keys notFoundKeys:(out NSArray *__autoreleasing *)notFoundKeys {
    NSObject * marker = [NSObject new];
    NSArray * objects = [self objectsForKeys:keys notFoundMarker:marker];
    
    NSIndexSet * indexes = [objects indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return obj == marker;
    }];
        
    if(notFoundKeys) {
        *notFoundKeys = [keys objectsAtIndexes:indexes];
    }
    
    if(indexes.count) {
        NSMutableIndexSet * invertedIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, keys.count)];
        [invertedIndexes removeIndexes:indexes];
        
        keys = [keys objectsAtIndexes:invertedIndexes];
        objects = [objects objectsAtIndexes:invertedIndexes];
    }
    
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

@end
