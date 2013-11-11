//
//  GBSMutableFileWrapperTests.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 11/10/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GBSMutableFileWrapper.h"

@interface GBSMutableFileWrapperTests : XCTestCase

@end

@implementation GBSMutableFileWrapperTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegularFile {
    GBSMutableFileWrapper * wrapper = [GBSMutableFileWrapper new];
    XCTAssertEqual(wrapper.type, GBSFileWrapperTypeNil, @"Wrappers start off with nil type");
    XCTAssertNil(wrapper.contents, @"Nil wrapper has nil contents");
    
    wrapper.contents = [@"Hello world!" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqual(wrapper.type, GBSFileWrapperTypeRegularFile, @"Setting an NSData makes the wrapper into a regular file");
    XCTAssertTrue([wrapper.contents isKindOfClass:NSData.class], @"Actually remembers it's an NSData");
    XCTAssertEqualObjects(wrapper.contents, [@"Hello world!" dataUsingEncoding:NSUTF8StringEncoding], @"Retains correct data");
    
    wrapper.contents = [@"Goodbye world!" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqual(wrapper.type, GBSFileWrapperTypeRegularFile, @"Still a regular file");
    XCTAssertEqualObjects(wrapper.contents, [@"Goodbye world!" dataUsingEncoding:NSUTF8StringEncoding], @"Properly changes data");
}

- (void)testDirectory {
    GBSFileWrapper * file = [[GBSFileWrapper alloc] initWithContents:[NSData data] resourceValues:nil];
    GBSMutableFileWrapper * dir = [GBSMutableFileWrapper new];
    XCTAssertEqual(dir.type, GBSFileWrapperTypeNil, @"Wrappers start off with nil type");
    
    [dir setDirectoryContentsFileWrapper:file forName:@"example.txt"];
    XCTAssertEqual(dir.type, GBSFileWrapperTypeDirectory, @"Adding a file makes wrapper a directory");
    XCTAssertEqual([dir.contents count], (NSUInteger)1, @"...and actually adds the file");
    XCTAssertNotNil(dir.contents[@"example.txt"], @"Can access the file by name");
    
    [dir setDirectoryContentsFileWrapper:nil forName:@"example.txt"];
    XCTAssertEqual(dir.type, GBSFileWrapperTypeDirectory, @"Still a directory after removing file");
    XCTAssertNil(dir.contents[@"example.txt"], @"Setting file to nil deletes it");
    
    dir.contents = nil;
    XCTAssertEqual(dir.type, GBSFileWrapperTypeNil, @"Successfully nil'd directory");
    
    dir.contents = @{ @"example.txt": file };
    XCTAssertEqual(dir.type, GBSFileWrapperTypeDirectory, @"Setting contents makes wrapper a directory");
    XCTAssertEqual([dir.contents count], (NSUInteger)1, @"...and actually adds the file");
    XCTAssertNotNil(dir.contents[@"example.txt"], @"Can access the file by name");
    
    dir.contents = nil;
    XCTAssertEqual(dir.type, GBSFileWrapperTypeNil, @"Successfully nil'd directory");
    
    NSString * name = [dir addDirectoryContentsFileWrapper:file forPreferredName:@"example.txt"];
    XCTAssertEqual([dir.contents count], (NSUInteger)1, @"-addDirectoryContentsFileWrapper: adds file to directory");
    XCTAssertEqualObjects(name, @"example.txt", @"Doesn't rename file if there's no conflict");
    XCTAssertNotNil(dir.contents[name], @"Adds the file under the right name");
    
    name = [dir addDirectoryContentsFileWrapper:file forPreferredName:@"example.txt"];
    XCTAssertEqual([dir.contents count], (NSUInteger)2, @"-addDirectoryContentsFileWrapper: chooses a different name if there's a conflict");
    XCTAssertEqualObjects(name, @"example 2.txt", @"...using the expected algorithm");
    XCTAssertNotNil(dir.contents[name], @"Adds the file under the right (different) name");
}

@end
