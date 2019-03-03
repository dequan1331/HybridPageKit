//
// HPKWebViewDelegateTests.m
//
// Copyright (c) 2019 dequanzhu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <libkern/OSAtomic.h>
#import "_HPKUtils.h"

@interface Test_NSObject_KVO : XCTestCase
@end

@implementation Test_NSObject_KVO

- (void)testBasics {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor redColor];
    NSObject *tmpObserver = [[NSObject alloc] init];
    int __block callbackCount = 0;
    
    [view safeAddObserver:tmpObserver
                  keyPath:@"backgroundColor"
                 callback:^(NSObject *oldValue, NSObject *newValue) {
                     callbackCount++;
                     XCTAssert(oldValue == [UIColor redColor]);
                     XCTAssert(newValue == [UIColor blackColor]);
                 }];
    
    [view safeAddObserver:tmpObserver
                  keyPath:@"frame"
                 callback:^(NSObject *oldValue, NSObject *newValue) {
                     callbackCount++;
                     XCTAssert([newValue isKindOfClass:[NSValue class]]);
                     XCTAssert([oldValue isKindOfClass:[NSValue class]]);
                 }];
    
    view.backgroundColor = [UIColor blackColor];
    XCTAssert(callbackCount == 1);
    
    view.frame = CGRectMake(0, 0, 100, 100);
    XCTAssert(callbackCount == 2);
    
    [view safeRemoveObserver:tmpObserver keyPath:@"backgroundColor"];
    view.backgroundColor = [UIColor blackColor];
    XCTAssert(callbackCount == 2);
}

- (void)testObservedObjectDealloc {
    NSObject *tmpObserver = [[NSObject alloc] init];
    @autoreleasepool {
        UIView *view = [[UIView alloc] init];
        int __block callbackCount = 0;
        [view safeAddObserver:tmpObserver
                      keyPath:@"backgroundColor"
                     callback:^(NSObject *oldValue, NSObject *newValue) {
                         callbackCount++;
                     }];
        
        view.backgroundColor = [UIColor blackColor];
        XCTAssert(callbackCount == 1);
    }
}

- (void)testObserverDealloc {
    @autoreleasepool {
        UIView *view = [[UIView alloc] init];
        int __block callbackCount = 0;
        @autoreleasepool {
            NSObject *tmpObserver = [[NSObject alloc] init];

            [view safeAddObserver:tmpObserver
                          keyPath:@"backgroundColor"
                         callback:^(NSObject *oldValue, NSObject *newValue) {
                             callbackCount++;
                         }];

            view.backgroundColor = [UIColor blackColor];

            XCTAssert(callbackCount == 1);
        }
        view.backgroundColor = [UIColor redColor];  // trigger to unbind KVO
        XCTAssert(callbackCount == 1);
    }
}
@end
