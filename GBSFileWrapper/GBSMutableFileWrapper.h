//
//  GBSMutableFileWrapper.h
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 11/9/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <GBSFileWrapper/GBSFileWrapper.h>

@interface GBSMutableFileWrapper : GBSFileWrapper

//@property (readwrite) id contents;
- (void)setContents:(id <GBSFileWrapperContents>)contents;

- (void)setContentsChildFileWrapper:(GBSFileWrapper*)childWrapper forName:(NSString*)name;
- (NSString*)addContentsChildFileWrapper:(GBSFileWrapper*)childWrapper forPreferredName:(NSString*)name;    // WARNING: Not thread-safe

- (void)setResourceValue:(id)value forKey:(NSString *)key;
- (void)setResourceValues:(NSDictionary *)keyedValues;

@end
