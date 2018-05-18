//
//  WKWebView + SafeEvaluateJS.m
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "WKWebView + SafeEvaluateJS.h"

@implementation WKWebView (SafeEvaluateJS)

- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script{
    [self safeAsyncEvaluateJavaScriptString:script completionBlock:nil];
}
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(SafeEvaluateJSCompletion)block{
    if (!script) {
        return;
    }
    [self evaluateJavaScript:script
            completionHandler:^(id result, NSError *_Nullable error) {
                // retainify self for callback
                __unused __attribute__((objc_ownership(strong))) __typeof__(self) self_retain_ = self;
                
                if (!error) {
                    if (block) {
                        if (!result || [result isKindOfClass:[NSNull class]]) {
                            block(@"");
                        } else if ([result isKindOfClass:[NSObject class]]) {
                            block((NSObject *)result);
                        }  else {
                            NSAssert(NO,@"WKWebView (SafeEvaluateJS) evaluate js return type:%@,js:%@",
                                      NSStringFromClass([result class]),
                                      script);
                        }
                    }
                } else {
                    if (block) {
                        block(@"");
                    }
                }
            }];
}

@end
