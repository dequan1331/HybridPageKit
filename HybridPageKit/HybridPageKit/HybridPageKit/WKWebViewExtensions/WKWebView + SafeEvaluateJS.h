//
//  WKWebView + SafeEvaluateJS.h
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^SafeEvaluateJSCompletion)(NSObject *result);

@interface WKWebView (SafeEvaluateJS)
/**
 *  Safe Evaluate JS And Retainify Webview For CallBack
 */
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script;

/**
 *  Safe Evaluate JS And Retainify Webview For CallBack
 *  Make Sure CallBack IS NSString
 */
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(SafeEvaluateJSCompletion)block;

@end
