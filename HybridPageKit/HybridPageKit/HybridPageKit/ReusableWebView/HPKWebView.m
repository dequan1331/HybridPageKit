//
//  HPKWebView.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKWebView.h"
#import "WKWebViewExtensionsDef.h"
#import "HPKJavascriptUtils.h"

@implementation HPKWebView

-(void)dealloc{
    [self stopLoading];
    [self unUseExternalNavigationDelegate];
    [super setUIDelegate:nil];
    [super setNavigationDelegate:nil];
    _holderObject = nil;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
    }
    return self;
}

#pragma mark -

- (BOOL)canGoBack {
    if ([self.backForwardList.backItem.URL.absoluteString isEqualToString:kHPKWebViewReuseUrlString] || [self.URL.absoluteString isEqualToString:kHPKWebViewReuseUrlString]) {
        return NO;
    }
    return [super canGoBack];
}

- (BOOL)canGoForward {
    if ([self.backForwardList.forwardItem.URL.absoluteString isEqualToString:kHPKWebViewReuseUrlString] || [self.URL.absoluteString isEqualToString:kHPKWebViewReuseUrlString]) {
        return NO;
    }
    return [super canGoForward];
}

#pragma mark - HPKWebViewReuseProtocol

-(void)webViewWillReuse{
    [self useExternalNavigationDelegate];
}
-(void)webViewEndReuse{
    
    [self.configuration.userContentController removeAllUserScripts];
    _holderObject = nil;
    self.scrollView.delegate = nil;
    [self stopLoading];
    [self unUseExternalNavigationDelegate];
    [super setUIDelegate:nil];
    
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kHPKWebViewReuseUrlString]]];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(cut:) || action == @selector(copy:) || action == @selector(paste:) ||
        action == @selector(delete:)) {
        return [super canPerformAction:action withSender:sender];
    }
    return NO;
}

#pragma mark - WKWebViewExtension

+ (void)fixWKWebViewMenuItems{
    [WKWebView fixWKWebViewMenuItems];
}

+ (void)supportProtocolWithHTTP:(BOOL)supportHTTP
              customSchemeArray:(NSArray<NSString *> *)customSchemeArray
               urlProtocolClass:(Class)urlProtocolClass{
    
    if (!urlProtocolClass) {
        return;
    }
    
    [NSURLProtocol registerClass:urlProtocolClass];
    [WKWebView supportProtocolWithHTTP:supportHTTP customSchemeArray:customSchemeArray];
}

+ (void)safeClearAllCache{
    [WKWebView safeClearAllCache];
}

+ (void)configCustomUAWithType:(ConfigUAType)type
                      UAString:(NSString *)customString{
    [WKWebView configCustomUAWithType:type UAString:customString];
}

- (void)scrollToOffset:(CGFloat)offset
           maxRunloops:(NSUInteger)maxRunloops
       completionBlock:(SafeScrollToCompletionBlock)completionBlock{
    [super scrollToOffset:offset maxRunloops:maxRunloops completionBlock:completionBlock];
}


- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script{
    [super safeAsyncEvaluateJavaScriptString:script];
}
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(SafeEvaluateJSCompletion)block{
    [super safeAsyncEvaluateJavaScriptString:script completionBlock:block];
}

- (void)setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expiresDate:(NSDate *)expiresDate{
    [super setCookieWithName:name value:value domain:domain path:path expiresDate:expiresDate];
}
- (void)deleteCookiesWithName:(NSString *)name{
    [super deleteCookiesWithName:name];
}
- (NSSet<NSString *> *)getAllCustomCookiesName{
    return [super getAllCustomCookiesName];
}
- (void)deleteAllCustomCookies{
    [super deleteAllCustomCookies];
}

- (void)addDocumentStartScriptArray:(NSArray <NSString *> *)documentStartScriptArray
             documentEndScriptArray:(NSArray <NSString *> *)documentEndScriptArray{
    
    for(NSString *script in documentStartScriptArray){
        [self.configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:script
                                                                                       injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                                                    forMainFrameOnly:YES]];
    }
    for(NSString *script in documentStartScriptArray){
        [self.configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:script
                                                                                       injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                                                    forMainFrameOnly:YES]];
    }
}

@end
