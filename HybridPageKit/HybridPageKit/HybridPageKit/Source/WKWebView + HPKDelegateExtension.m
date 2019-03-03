//
// WKWebView + HPKDelegateExtension.m
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


#import "WKWebView + HPKDelegateExtension.h"
#import "WKWebView + HPKReusable.h"
#import "HPKPageManager.h"
#import <objc/runtime.h>

@interface _WKWebViewDelegateDispatcher : NSObject<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, weak, readwrite) id<WKNavigationDelegate> mainNavigationDelegate;
@property (nonatomic, strong, readwrite) NSHashTable *weakNavigationDelegates;

- (void)addNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (void)removeNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (BOOL)containNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (void)removeAllNavigationDelegate;

@end

@implementation _WKWebViewDelegateDispatcher

- (instancetype)init {
    self = [super init];
    if (self) {
        _weakNavigationDelegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

#pragma mark -
- (void)addNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    if (delegate && ![self.weakNavigationDelegates.allObjects containsObject:delegate]) {
        [_weakNavigationDelegates addObject:delegate];
    }
}

- (void)removeNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    if (delegate) {
        [_weakNavigationDelegates removeObject:delegate];
    }
}

- (BOOL)containNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    return delegate ? [_weakNavigationDelegates.allObjects containsObject:delegate] : NO;
}

- (void)removeAllNavigationDelegate {
    for (id<WKNavigationDelegate> delegate in _weakNavigationDelegates.copy) {
        [_weakNavigationDelegates removeObject:delegate];
    }
}

#pragma mark -

- (void)                    webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    __block BOOL isResponse = NO;

    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;

    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        isResponse = YES;
    } else {
        for (id delegate in self.weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
                isResponse = YES;
            }
        }
    }

    if (!isResponse) {
        // for webview reuse
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)                      webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                      decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;

    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didCommitNavigation:navigation];
    }

    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didCommitNavigation:navigation];
        }
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;

    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didStartProvisionalNavigation:navigation];
    }

    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didStartProvisionalNavigation:navigation];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([webView.URL.absoluteString isEqualToString:[[HPKPageManager sharedInstance] webViewReuseLoadUrlStr]]) {
        // 加载复用页面，finishNavigation之后不作处理，防止影响业务逻辑
        return;
    }

    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;

    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didFinishNavigation:navigation];
    }

    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didFinishNavigation:navigation];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;

    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didFailNavigation:navigation withError:error];
    }

    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didFailNavigation:navigation withError:error];
        }
    }
}

- (void)                 webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;

    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }

    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didFailProvisionalNavigation:navigation withError:error];
        }
    }
}

- (void)                      webView:(WKWebView *)webView
    didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
                    completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition,
                                NSURLCredential *_Nullable))completionHandler {
    
    __block BOOL isResponse = NO;
    
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
        isResponse = YES;
    } else {
        for (id delegate in self.weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
                isResponse = YES;
            }
        }
    }
    
    if (!isResponse) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 9.0, *)) {
        id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;

        if ([mainDelegate respondsToSelector:_cmd]) {
            [mainDelegate webViewWebContentProcessDidTerminate:webView];
        }

        for (id delegate in self.weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webViewWebContentProcessDidTerminate:webView];
            }
        }
    }
#endif
}

- (void)                                     webView:(WKWebView *)webView
    didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;

    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }

    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
        }
    }
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)   webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (BOOL)p_canShowPanelWithWebView:(WKWebView *)webView {
    if ([webView.holderObject isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)webView.holderObject;
        if (vc.isBeingPresented || vc.isBeingDismissed || vc.isMovingToParentViewController || vc.isMovingFromParentViewController) {
            return NO;
        }
    }
    return YES;
}

- (void)                       webView:(WKWebView *)webView
    runJavaScriptAlertPanelWithMessage:(NSString *)message
                      initiatedByFrame:(WKFrameInfo *)frame
                     completionHandler:(void (^)(void))completionHandler {
    if (![self p_canShowPanelWithWebView:webView]) {
        completionHandler();
        return;
    }

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"" message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
        completionHandler();
    }])];
    if ([self _topPresentedViewController].presentingViewController) {
        completionHandler();
    } else {
        [[self _topPresentedViewController] presentViewController:alertController animated:YES completion:NULL];
    }
}

- (void)                         webView:(WKWebView *)webView
    runJavaScriptConfirmPanelWithMessage:(NSString *)message
                        initiatedByFrame:(WKFrameInfo *)frame
                       completionHandler:(void (^)(BOOL result))completionHandler {
    if (![self p_canShowPanelWithWebView:webView]) {
        completionHandler(NO);
        return;
    }

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"" message:message
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:([UIAlertAction actionWithTitle:@"取消"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *_Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
        completionHandler(YES);
    }])];

    if ([self _topPresentedViewController].presentingViewController) {
        completionHandler(NO);
    } else {
        [[self _topPresentedViewController] presentViewController:alertController animated:YES completion:NULL];
    }
}

- (void)                          webView:(WKWebView *)webView
    runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
                              defaultText:(nullable NSString *)defaultText
                         initiatedByFrame:(WKFrameInfo *)frame
                        completionHandler:(void (^)(NSString *_Nullable result))completionHandler {
    if (![self p_canShowPanelWithWebView:webView]) {
        completionHandler(nil);
        return;
    }

    NSString *hostString = webView.URL.host;
    NSString *sender = [NSString stringWithFormat:@"%@", hostString];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt
                                                                             message:sender
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alertController
     addAction:([UIAlertAction actionWithTitle:@"确定"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
        if (alertController.textFields && alertController.textFields.count > 0) {
            UITextField *textFiled = [alertController.textFields firstObject];
            if (textFiled.text && textFiled.text.length > 0) {
                completionHandler(textFiled.text);
            } else {
                completionHandler(nil);
            }
        } else {
            completionHandler(nil);
        }
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }])];

    if ([self _topPresentedViewController].presentingViewController) {
        completionHandler(nil);
    } else {
        [[self _topPresentedViewController] presentViewController:alertController animated:YES completion:NULL];
    }
}

- (UIViewController *)_topPresentedViewController {
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (viewController.presentedViewController)
        viewController = viewController.presentedViewController;
    return viewController;
}

@end

#pragma mark -
#pragma mark -

@interface WKWebView ()
@property (nonatomic, assign, readwrite) BOOL isUseExternalDelegate;
@property (nonatomic, strong, readwrite) _WKWebViewDelegateDispatcher *delegateDispatcher;
@end

@implementation WKWebView (HPKDelegateExtension)

#pragma mark -

- (void)setIsUseExternalDelegate:(BOOL)isUseExternalDelegate {
    objc_setAssociatedObject(self, @"isUseExternalDelegate", @(isUseExternalDelegate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isUseExternalDelegate {
    NSNumber *isUseExternalDelegate = objc_getAssociatedObject(self, @"isUseExternalDelegate");
    return isUseExternalDelegate.boolValue;
}

- (void)setDelegateDispatcher:(_WKWebViewDelegateDispatcher *)delegateDispatcher {
    objc_setAssociatedObject(self, @"delegateDispatcher", delegateDispatcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_WKWebViewDelegateDispatcher *)delegateDispatcher {
    return objc_getAssociatedObject(self, @"delegateDispatcher");
}

#pragma mark -

- (void)_useExternalNavigationDelegateAndWithDefaultUIDelegate:(BOOL)useDefaultUIDelegate {
    if ([self isUseExternalDelegate] && [self delegateDispatcher]) {
        return;
    }

    [self setDelegateDispatcher:[[_WKWebViewDelegateDispatcher alloc] init]];
    [self setNavigationDelegate:[self delegateDispatcher]];
    if (useDefaultUIDelegate) {
        [self setUIDelegate:[self delegateDispatcher]];
    }
    [self setIsUseExternalDelegate:YES];
}

#pragma mark -

- (void)_setMainNavigationDelegate:(NSObject<WKNavigationDelegate> *)mainDelegate {
    [self delegateDispatcher].mainNavigationDelegate = mainDelegate;
}

- (void)_addSecondaryNavigationDelegate:(NSObject<WKNavigationDelegate> *)delegate {
    [[self delegateDispatcher] addNavigationDelegate:delegate];
}

- (void)_removeSecondaryNavigationDelegate:(NSObject<WKNavigationDelegate> *)delegate {
    [[self delegateDispatcher] removeNavigationDelegate:delegate];
}

- (void)_removeAllSecondaryNavigationDelegates {
    [[self delegateDispatcher] removeAllNavigationDelegate];
}

@end
