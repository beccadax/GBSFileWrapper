//
//  GBSFileWrapperDefines.h
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GBSFileWrapperType) {
    GBSFileWrapperTypeNil,
    GBSFileWrapperTypeRegularFile,
    GBSFileWrapperTypeDirectory,
    GBSFileWrapperTypeSymbolicLink
};

@protocol GBSFileWrapperDataSource;
@protocol GBSFileWrapperResourceValues;
@protocol GBSFileWrapperContents;

@class GBSFileWrapper;
