//
// HPKWebViewTests.m
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

#import <XCTest/XCTest.h>
#import "HPKWebView.h"
#import "HPKPageManager.h"

@interface HPKWebViewTests : XCTestCase<WKNavigationDelegate>

@property (nonatomic, strong, readwrite) HPKWebView *webView;

@property (nonatomic, strong, readwrite) XCTestExpectation *expectation;

@end

@implementation HPKWebViewTests

- (void)setUp {
    if (!_webView) {
        _webView = [[HPKWebView alloc] initWithFrame:CGRectZero];
        _webView.navigationDelegate = self;
    }
}

- (void)tearDown {
    [_webView stopLoading];
    _webView.navigationDelegate = nil;
    _webView = nil;
}

- (void)testEvaluateJSWithReturnNUll {
    XCTestExpectation *expectation = [self expectationWithDescription:@(__LINE__).stringValue];
    HPKWebView *temporaryWebView = [[HPKWebView alloc] initWithFrame:CGRectZero];
    [temporaryWebView safeAsyncEvaluateJavaScriptString:[NSString stringWithFormat:@"document.getElementById('%@')", @(__LINE__).stringValue] completionBlock:^(NSObject *result) {
        XCTAssertTrue(temporaryWebView);
        XCTAssertTrue([result isKindOfClass:[NSString class]]);
        [expectation fulfill];
    }];
    temporaryWebView = nil;
    [self waitForExpectationsWithTimeout:10 * 60 handler:nil];
}

- (void)testEvaluateInvalidJS {
    XCTestExpectation *expectation = [self expectationWithDescription:@(__LINE__).stringValue];
    HPKWebView *temporaryWebView = [[HPKWebView alloc] initWithFrame:CGRectZero];
    [temporaryWebView safeAsyncEvaluateJavaScriptString:[NSString stringWithFormat:@"%@", NSStringFromClass(self.class)] completionBlock:^(NSObject *result) {
        XCTAssertTrue(temporaryWebView);
        XCTAssertTrue([result isKindOfClass:[NSString class]]);
        [expectation fulfill];
    }];
    temporaryWebView = nil;
    [self waitForExpectationsWithTimeout:10 * 60 handler:nil];
}

- (void)testUAReplace {
    XCTestExpectation *expectation = [self expectationWithDescription:@(__LINE__).stringValue];
    NSString *uaStr = NSStringFromClass(self.class);
    [HPKPageManager configCustomUAWithType:kHPKWebViewUAConfigTypeReplace UAString:NSStringFromClass(self.class) ];
    HPKWebView *temporaryWebView = [[HPKWebView alloc] initWithFrame:CGRectZero];
    [temporaryWebView safeAsyncEvaluateJavaScriptString:@"navigator.userAgent" completionBlock:^(NSObject *result) {
        XCTAssertNotNil(result);
        XCTAssertEqualObjects(result, uaStr);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 * 60 handler:nil];
}

- (void)testUAAppend {
    XCTestExpectation *expectation = [self expectationWithDescription:@(__LINE__).stringValue];
    NSString *uaStr = NSStringFromClass(self.class);
    [HPKPageManager configCustomUAWithType:kHPKWebViewUAConfigTypeAppend UAString:uaStr ];
    HPKWebView *temporaryWebView = [[HPKWebView alloc] initWithFrame:CGRectZero];
    [temporaryWebView safeAsyncEvaluateJavaScriptString:@"navigator.userAgent" completionBlock:^(NSObject *result) {
        XCTAssertNotNil(result);
        XCTAssertNotEqualObjects(result, uaStr);
        XCTAssertTrue([result isKindOfClass:[NSString class]] && [((NSString *)result) containsString:uaStr]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 * 60 handler:nil];
}

- (void)testCookies {
    _expectation = [self expectationWithDescription:@(__LINE__).stringValue];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/"]]];
    [self waitForExpectationsWithTimeout:10 * 60 handler:nil];
}

#pragma mark -

- (void)webView:(HPKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    __weak typeof(self)_self = self;
    [self.webView setCookieWithName:NSStringFromClass(self.class)
                              value:NSStringFromClass(self.class)
                             domain:@""
                               path:@""
                        expiresDate:nil
                    completionBlock:^(NSObject *result) {
        __strong typeof(_self) self = _self;
        [self.webView safeAsyncEvaluateJavaScriptString:@"document.cookie" completionBlock:^(NSObject *result) {
            XCTAssertTrue([result isKindOfClass:[NSString class]] && [((NSString *)result) containsString:NSStringFromClass(self.class)]);
            __strong typeof(_self) self = _self;
            [self.webView deleteCookiesWithName:NSStringFromClass(self.class) completionBlock:^(NSObject *result) {
                __strong typeof(_self) self = _self;
                [self.webView safeAsyncEvaluateJavaScriptString:@"document.cookie" completionBlock:^(NSObject *result) {
                    __strong typeof(_self) self = _self;
                    XCTAssertFalse([result isKindOfClass:[NSString class]] && [((NSString *)result) containsString:NSStringFromClass(self.class)]);
                    [self.expectation fulfill];
                }];
            }];
        }];
    }];
}

@end
