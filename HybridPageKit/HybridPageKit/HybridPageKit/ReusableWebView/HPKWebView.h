//
//  HPKWebView.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "WKWebViewExtensionsDef.h"
#import "HPKWebViewPool.h"
#import <WebKit/WebKit.h>

@interface HPKWebView : WKWebView <HPKWebViewReuseProtocol>
@property(nonatomic, weak, readwrite) id holderObject;

#pragma mark - WKWebViewExtension

//fix longpress MenuItems bug under iOS11
+ (void)fixWKWebViewMenuItems;

// supprot WKWebview URLProtocol
+ (void)supportProtocolWithHTTP:(BOOL)supportHTTP
              customSchemeArray:(NSArray<NSString *> *)customSchemeArray
               urlProtocolClass:(Class)urlProtocolClass;

//clear all webview cache include iOS8
+ (void)safeClearAllCache;

// sync set custom UA
+ (void)configCustomUAWithType:(ConfigUAType)type
                  UAString:(NSString *)customString;

// safe scroll to specific offset
- (void)scrollToOffset:(CGFloat)offset
       maxRunloops:(NSUInteger)maxRunloops
   completionBlock:(SafeScrollToCompletionBlock)completionBlock;

// safe evaluate js
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script;
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(SafeEvaluateJSCompletion)block;

// safe set cookies
- (void)setCookieWithName:(NSString *)name
                value:(NSString *)value
               domain:(NSString *)domain
                 path:(NSString *)path
          expiresDate:(NSDate *)expiresDate;
- (void)deleteCookiesWithName:(NSString *)name;
- (NSSet<NSString *> *)getAllCustomCookiesName;
- (void)deleteAllCustomCookies;

//add script
- (void)addDocumentStartScriptArray:(NSArray <NSString *> *)documentStartScriptArray
             documentEndScriptArray:(NSArray <NSString *> *)documentEndScriptArray;


@end
