//
//  GBSFileWrapperTests.m
//  GBSFileWrapperTests
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GBSFileWrapper.h"

@interface GBSFileWrapperTests : XCTestCase

@end

@implementation GBSFileWrapperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSData * data = [@"example" dataUsingEncoding:NSUTF8StringEncoding];
        
    GBSFileWrapper * wrapper = [[GBSFileWrapper alloc] initWithContents:data resourceValues:@{ NSURLFileSecurityKey: [[NSFileSecurity alloc] initWithPOSIXMode:@(0644)] }];
    
    XCTAssertNotNil(wrapper, @"Constructed a file wrapper");
    XCTAssertEqual(wrapper.type, GBSFileWrapperTypeRegularFile, @"GBSFileWrapper with NSData contents is a regualr file");
    
    XCTAssertEqualObjects(wrapper.contents, data, @"GBSFileWrapper preserves contents correctly");
    
    NSFileSecurity * security;
    XCTAssertTrue([wrapper getResourceValue:&security forKey:NSURLFileSecurityKey error:NULL], @"Fetched security object successfully");
    XCTAssertNotNil(wrapper, @"Actually got a security object");
    
    XCTAssertNotNil(security.POSIXMode, @"Can get POSIX mode");
    XCTAssertEqual((mode_t)security.POSIXMode.integerValue, (mode_t)0644, @"POSIX mode is correct");
}

- (void)testDirectory {
    NSData * oneData = [@"1" dataUsingEncoding:NSUTF8StringEncoding];
    NSData * twoData = [@"2" dataUsingEncoding:NSUTF8StringEncoding];
    NSData * threeData = [@"3" dataUsingEncoding:NSUTF8StringEncoding];
    
    GBSFileWrapper * oneWrapper = [[GBSFileWrapper alloc] initWithContents:oneData resourceValues:nil];
    GBSFileWrapper * twoWrapper = [[GBSFileWrapper alloc] initWithContents:twoData resourceValues:nil];
    GBSFileWrapper * threeWrapper = [[GBSFileWrapper alloc] initWithContents:threeData resourceValues:nil];
    
    GBSFileWrapper * dir1 = [[GBSFileWrapper alloc]initWithContents:@{ @"one": oneWrapper, @"two": twoWrapper } resourceValues:nil];
    
    XCTAssertNotNil(dir1, @"Constructed a file wrapper");
    XCTAssertEqual(dir1.type, GBSFileWrapperTypeDirectory, @"GBSFileWrapper constructed with a dictionary creates a directory");
    XCTAssertEqualObjects(dir1.contents[@"one"], oneWrapper, @"dir1 contents include file one");
    XCTAssertEqualObjects(dir1.contents[@"two"], twoWrapper, @"dir1 contents include file two");
    
    GBSFileWrapper * dir2 = [[GBSFileWrapper alloc] initWithContents:@{ @"three": threeWrapper, @"dir1": dir1 } resourceValues:nil];
    XCTAssertEqualObjects(dir2.contents[@"three"], threeWrapper, @"dir2 contents include file 3");
    XCTAssertEqualObjects(dir2.contents[@"dir1"], dir1, @"Nesting directories works");
    XCTAssertEqualObjects([dir2.contents[@"dir1"] contents][@"one"], oneWrapper, @"Nesting directories doesn't damage the inner directory");
}

@end
