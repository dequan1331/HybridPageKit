//
// HPKWebView.m
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


#import "HPKWebView.h"
#import "WKWebView + HPKExtension.h"
#import "WKWebView + HPKReusable.h"
#import "WKWebView + HPKDelegateExtension.h"
#import "_HPKUtils.h"

@implementation HPKWebView

IMP_HPKViewProtocol()

- (void)dealloc {
    [super setNavigationDelegate:nil];
    [super setUIDelegate:nil];
    self.scrollView.delegate = nil;
    [self stopLoading];
    [self removeAllSecondaryNavigationDelegates];
    [self setMainNavigationDelegate:nil];
}

- (void)setInvalidForReuse:(BOOL)invalidForReuse {
    [super setInvalid:invalidForReuse];
}

- (BOOL)invalidForReuse {
    return [super invalid];
}

- (void)componentViewWillLeavePool {
    [super componentViewWillLeavePool];
}

- (void)componentViewWillEnterPool {
    [super componentViewWillEnterPool];
    [self setMainNavigationDelegate:nil];
    [self removeAllSecondaryNavigationDelegates];
    [self.scrollView safeRemoveAllObserver];
}

- (void)clearBackForwardList {
    [super _clearBackForwardList];
}

- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script {
    [super _safeAsyncEvaluateJavaScriptString:script];
}

- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(HPKWebViewJSCompletionBlock)block {
    [super _safeAsyncEvaluateJavaScriptString:script completionBlock:block];
}

- (void)setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expiresDate:(NSDate *)expiresDate
          completionBlock:(HPKWebViewJSCompletionBlock)completionBlock {
    [super _setCookieWithName:name value:value domain:domain path:path expiresDate:expiresDate completionBlock:completionBlock];
}

- (void)deleteCookiesWithName:(NSString *)name completionBlock:(HPKWebViewJSCompletionBlock)completionBlock {
    [super _deleteCookiesWithName:name completionBlock:completionBlock];
}

- (NSSet<NSString *> *)getAllCustomCookiesName {
    return [super _getAllCustomCookiesName];
}

- (void)deleteAllCustomCookies {
    [super _deleteAllCustomCookies];
}

- (void)useExternalNavigationDelegateAndWithDefaultUIDelegate:(BOOL)useDefaultUIDelegate {
    [super _useExternalNavigationDelegateAndWithDefaultUIDelegate:useDefaultUIDelegate];
}

- (void)setMainNavigationDelegate:(NSObject<WKNavigationDelegate> *)mainDelegate {
    [super _setMainNavigationDelegate:mainDelegate];
}

- (void)addSecondaryNavigationDelegate:(NSObject<WKNavigationDelegate> *)delegate {
    [super _addSecondaryNavigationDelegate:delegate];
}

- (void)removeSecondaryNavigationDelegate:(NSObject<WKNavigationDelegate> *)delegate {
    [super _removeSecondaryNavigationDelegate:delegate];
}

- (void)removeAllSecondaryNavigationDelegates {
    [super _removeAllSecondaryNavigationDelegates];
}

- (CGFloat)componentHeight {
    return self.scrollView.contentSize.height;
}

- (UIScrollView *)componentInnerScrollView {
    return self.scrollView;
}

@end
