//
//  NSFileSecurity+GBSExtensions.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "NSFileSecurity+GBSExtensions.h"

@implementation NSFileSecurity (GBSExtensions)

- (id)initWithPOSIXMode:(NSNumber*)mode {
    if((self = [self init])) {
        if(![self setPOSIXMode:mode]) {
            return nil;
        }
    }
    return self;
}

- (id)initWithPOSIXMode:(NSNumber*)mode owner:(NSNumber*)owner group:(NSNumber*)group; {
    if((self = [self init])) {
        if(![self setPOSIXMode:mode]) {
            return nil;
        }
        if(![self setPOSIXOwner:owner]) {
            return nil;
        }
        if(![self setPOSIXGroup:group]) {
            return nil;
        }
    }
    return self;
}

- (CFFileSecurityRef)CFFileSecurity {
    return (__bridge CFFileSecurityRef)self;
}

#define GBSFileSecurityAccessors(name, type) \
- (NSNumber*)POSIX##name { \
    type value; \
    if(!CFFileSecurityGet##name([self CFFileSecurity], &value)) { return nil; } \
    return @(value); \
} \
\
- (BOOL)setPOSIX##name:(NSNumber*)value { \
    if(!value) { \
        return CFFileSecurityClearProperties([self CFFileSecurity], kCFFileSecurityClear##name); \
    } \
    return CFFileSecuritySet##name([self CFFileSecurity], (type)value.unsignedLongValue); \
} \

GBSFileSecurityAccessors(Mode, mode_t)
GBSFileSecurityAccessors(Owner, uid_t)
GBSFileSecurityAccessors(Group, gid_t)

- (NSValue*)accessControlList {
    acl_t value;
    if(!CFFileSecurityCopyAccessControlList([self CFFileSecurity], &value)) {
        return nil;
    }
    return [NSValue valueWithACL:value];
}

- (BOOL)setAccessControlList:(NSValue *)ACL {
    if(!ACL) {
        return CFFileSecurityClearProperties([self CFFileSecurity], kCFFileSecurityClearAccessControlList);
    }
    
    return CFFileSecuritySetAccessControlList([self CFFileSecurity], ACL.ACLValue);
}

@end

@interface GBSACLValue : NSValue @end

@implementation NSValue (ACL)

- (acl_t)ACLValue {
    if(strcmp(self.objCType, @encode(acl_t)) != 0) {
        return NULL;
    }
    
    acl_t value;
    [self getValue:&value];
    return value;
}

+ (instancetype)valueWithACL:(acl_t)acl {
    return [GBSACLValue valueWithACL:acl];
}

@end

@implementation GBSACLValue

+ (instancetype)valueWithACL:(acl_t)acl {
    return [[GBSACLValue alloc] initWithBytes:&acl objCType:@encode(acl_t)];
}

- (void)dealloc {
    acl_free(self.ACLValue);
}

@end


