//
//  WKWebView + ExternalNavigationDelegates.h
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "WKWebView + ExternalNavigationDelegates.h"
#import <objc/runtime.h>

@interface _WKWebViewDelegateDispatcher : NSObject<WKNavigationDelegate>

@property(nonatomic, weak, readwrite) id<WKNavigationDelegate> mainNavigationDelegate;
@property(nonatomic, strong, readwrite) NSHashTable *weakNavigationDelegates;

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
    for (id<WKNavigationDelegate> delegate in _weakNavigationDelegates) {
        [_weakNavigationDelegates removeObject:delegate];
    }
}


#pragma mark -

- (void)webView:(WKWebView *)webView
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
        };
    }
    
    if (!isResponse) {
        // for webview reuse
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView
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
    };
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
    };
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didFinishNavigation:navigation];
    }
    
    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didFinishNavigation:navigation];
        }
    };
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
    };
}

- (void)webView:(WKWebView *)webView
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
    };
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
        };
    }
#endif
}

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
    
    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
        }
    };
}

@end

#pragma mark -
#pragma mark -

@interface WKWebView()
@property(nonatomic, assign, readwrite) BOOL isUseExternalDelegate;
@property(nonatomic, strong, readwrite) _WKWebViewDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong, readwrite) id<WKNavigationDelegate> originalNavigationDelegate;
@end

@implementation WKWebView (ExternalNavigationDelegates)

- (void)setIsUseExternalDelegate:(BOOL)isUseExternalDelegate{
    objc_setAssociatedObject(self, @"isUseExternalDelegate", @(isUseExternalDelegate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isUseExternalDelegate{
    NSNumber *isUseExternalDelegate = objc_getAssociatedObject(self, @"isUseExternalDelegate");
    return isUseExternalDelegate.boolValue;
}

- (void)setDelegateDispatcher:(_WKWebViewDelegateDispatcher *)delegateDispatcher{
    objc_setAssociatedObject(self, @"delegateDispatcher", delegateDispatcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (_WKWebViewDelegateDispatcher *)delegateDispatcher{
    return objc_getAssociatedObject(self, @"delegateDispatcher");
}

- (void)setOriginalNavigationDelegate:(id<WKNavigationDelegate>)originalNavigationDelegate{
    objc_setAssociatedObject(self, @"originalNavigationDelegate", originalNavigationDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id<WKNavigationDelegate>)originalNavigationDelegate{
    return objc_getAssociatedObject(self, @"originalNavigationDelegate");
}

- (void)useExternalNavigationDelegate{
    
    if ([self isUseExternalDelegate] && [self delegateDispatcher]) {
        return;
    }
    
    [self setDelegateDispatcher:[[_WKWebViewDelegateDispatcher alloc] init]];
    [self setOriginalNavigationDelegate:self.navigationDelegate];
    
    [self setNavigationDelegate:[self delegateDispatcher]];
    [[self delegateDispatcher] addNavigationDelegate:[self originalNavigationDelegate]];
    
    [self setIsUseExternalDelegate:YES];
}
- (void)unUseExternalNavigationDelegate{
    
    [self setNavigationDelegate:[self originalNavigationDelegate]];
    
    [self setDelegateDispatcher:nil];
    [self setIsUseExternalDelegate:NO];
}
- (void)setMainNavigationDelegate:(id<WKNavigationDelegate>)mainDelegate {
    [self delegateDispatcher].mainNavigationDelegate = mainDelegate;
}
- (id<WKNavigationDelegate>)mainNavigationDelegate {
    return [self delegateDispatcher].mainNavigationDelegate;
}
- (void)addExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    [[self delegateDispatcher] addNavigationDelegate:delegate];
}
- (void)removeExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    [[self delegateDispatcher] removeNavigationDelegate:delegate];
}
- (BOOL)containsExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    return [[self delegateDispatcher] containNavigationDelegate:delegate];
}
- (void)clearExternalNavigationDelegates {
    [[self delegateDispatcher] removeAllNavigationDelegate];
}

@end
