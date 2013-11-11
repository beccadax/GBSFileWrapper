//
//  NSFileSecurity+GBSExtensions.h
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileSecurity (GBSExtensions)

- (id)initWithPOSIXMode:(NSNumber*)mode;
- (id)initWithPOSIXMode:(NSNumber*)mode owner:(NSNumber*)owner group:(NSNumber*)group;

- (CFFileSecurityRef)CFFileSecurity NS_RETURNS_INNER_POINTER;

@property (readonly) NSNumber * POSIXMode;
@property (readonly) NSNumber * POSIXOwner;
@property (readonly) NSNumber * POSIXGroup;
@property (readonly) NSValue * accessControlList;

- (BOOL)setPOSIXMode:(NSNumber*)value;
- (BOOL)setPOSIXOwner:(NSNumber*)value;
- (BOOL)setPOSIXGroup:(NSNumber*)value;
- (BOOL)setAccessControlList:(NSValue*)ACL;

@end

@interface NSValue (ACL)

+ (instancetype)valueWithACL:(acl_t)acl;    // Will automatically acl_free acl when finished.
- (acl_t)ACLValue NS_RETURNS_INNER_POINTER;

@end