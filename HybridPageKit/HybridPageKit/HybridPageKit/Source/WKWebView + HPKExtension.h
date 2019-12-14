//
// WKWebView + HPKExtension.h
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


#import <WebKit/WebKit.h>

typedef void (^_HPKWebViewJSCompletionBlock)(NSObject *result);

typedef NS_ENUM (NSInteger, ConfigUAType) {
    kConfigUATypeReplace,     //replace all UA string
    kConfigUATypeAppend,      //append to original UA string
};

@interface WKWebView (HPKExtension)

#pragma mark - safe evaluate js

- (void)_safeAsyncEvaluateJavaScriptString:(NSString *)script;

- (void)_safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(_HPKWebViewJSCompletionBlock)block;

#pragma mark - Cookies

- (void)_setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expiresDate:(NSDate *)expiresDate
          completionBlock:(_HPKWebViewJSCompletionBlock)completionBlock;

- (void)_deleteCookiesWithName:(NSString *)name completionBlock:(_HPKWebViewJSCompletionBlock)completionBlock;

- (NSSet<NSString *> *)_getAllCustomCookiesName;
- (void)_deleteAllCustomCookies;

#pragma mark - UA

+ (void)configCustomUAWithType:(ConfigUAType)type
                      UAString:(NSString *)customString API_AVAILABLE(ios(9.0));

#pragma mark - clear webview cache

+ (void)safeClearAllCacheIncludeiOS8:(BOOL)includeiOS8;

#pragma mark - fix menu items

+ (void)fixWKWebViewMenuItems;

#pragma mark - disable double click

+ (void)disableWebViewDoubleClick;

@end
