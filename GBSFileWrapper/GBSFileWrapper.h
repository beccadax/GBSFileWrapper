//
//  GBSFileWrapper.h
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBSFileWrapperDefines.h"
#import "NSFileSecurity+GBSExtensions.h"

@interface GBSFileWrapper : NSObject

// Designated initializer
- (id)initWithDataSource:(id <GBSFileWrapperDataSource>)dataSource;

@property (readonly) id <GBSFileWrapperDataSource> dataSource;

// Only call this to replace the data source with one that represents the exact same data.
// It will not trigger KVO notifications for `type` or `contents`!
- (void)substituteEquivalentDataSource:(id <GBSFileWrapperDataSource>)dataSource;

@property (readonly) GBSFileWrapperType type;
@property (readonly) id /*<GBSFileWrapperContents>*/ contents;

- (BOOL)getResourceValue:(out id *)value forKey:(NSString *)key error:(out NSError **)error;
- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys error:(NSError **)error;
//- (BOOL)setResourceValue:(id)value forKey:(NSString *)key error:(NSError **)error;
//- (BOOL)setResourceValues:(NSDictionary *)keyedValues error:(NSError **)error;

@end

#import "GBSFileWrapperDataSource.h"
#import "GBSFileWrapperContents.h"
#import "GBSFileWrapper+Memory.h"
#import "GBSFileWrapper+NSFileWrapper.h"
#import "GBSFileWrapper+URL.h"
