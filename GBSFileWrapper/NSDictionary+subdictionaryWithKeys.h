//
//  NSDictionary+subdictionaryWithKeys.h
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 11/19/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (subdictionaryWithKeys)

- (NSDictionary*)subdictionaryWithKeys:(NSArray*)keys notFoundKeys:(out NSArray**)notFoundKeys;

@end
