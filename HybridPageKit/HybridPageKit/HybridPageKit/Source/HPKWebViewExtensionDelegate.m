//
// HPKWebViewExtensionDelegate.m
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


#import "HPKWebViewExtensionDelegate.h"
#import "HPKPageManager.h"
#import "HPKControllerProtocol.h"
#import "_HPKUtils.h"

typedef NS_ENUM (NSInteger, HPKWebViewEvent) {
    //webview
    HPKWebViewEventStartProvisionalNavigation,
    HPKWebViewEventReceiveServerRedirect,
    HPKWebViewEventFailProvisionalNavigation,
    HPKWebViewEventCommitNavigation,
    HPKWebViewEventFinishNavigation,
    HPKWebViewEventFailNavigation,
    HPKWebViewEventTerminate,
    HPKWebViewEventInitialized,
    HPKWebViewEventWillShow,
    HPKWebViewEventDidShow,
    HPKWebViewEventContentSizeChange,
    HPKWebViewEventLayoutWebComponent,
};

static inline SEL _getHPKWebViewProtocolByEventType(HPKWebViewEvent event) {
    SEL mapping[] = {
        [HPKWebViewEventStartProvisionalNavigation] = @selector(webViewDidStartProvisionalNavigation:),
        [HPKWebViewEventReceiveServerRedirect] = @selector(webViewDidReceiveServerRedirectForProvisionalNavigation:),
        [HPKWebViewEventFailProvisionalNavigation] = @selector(webViewDidFailProvisionalNavigation:withError:),
        [HPKWebViewEventCommitNavigation] = @selector(webViewDidCommitNavigation:),
        [HPKWebViewEventFinishNavigation] = @selector(webViewDidFinishNavigation:),
        [HPKWebViewEventFailNavigation] = @selector(webViewDidFailNavigation:withError:),
        [HPKWebViewEventTerminate] = @selector(webViewDidTerminate),
        [HPKWebViewEventInitialized] = @selector(webViewDidInitialized),
        [HPKWebViewEventWillShow] = @selector(webViewWillShowWithAnimation),
        [HPKWebViewEventDidShow] = @selector(webViewDidShowWithAnimation),
        [HPKWebViewEventContentSizeChange] = @selector(webViewContentSizeChangeWithNewSize:oldSize:),
        [HPKWebViewEventLayoutWebComponent] = @selector(webViewWillLayoutWebComponent),
    };
    return mapping[event];
}

typedef BOOL (^HPKRetryUtilsConditionBlock)(void);
typedef void (^HPKRetryUtilsSuccessBlock)(NSInteger currentTimes);
typedef void (^HPKRetryUtilsFailedBlock)(NSInteger currentTimes);

@interface HPKRetryUtils : NSObject

+ (HPKRetryUtils *)sharedInstance;

- (void)retryFuntionWithHolder:(id)holder
                      MaxTimes:(NSInteger)maxTimes
                     condition:(HPKRetryUtilsConditionBlock)conditionBlock
                  successBlock:(HPKRetryUtilsSuccessBlock)successBlock
                   failedBlock:(HPKRetryUtilsFailedBlock)failedBlock;

- (void)stopRetryFuntionWithHolder:(id)holder;

@end

@interface HPKRetryUtils ()

@property (nonatomic, assign, readwrite) CFRunLoopObserverRef observer;
@property (nonatomic, assign, readwrite) CFRunLoopRef runLoop;

@property (nonatomic, assign, readwrite) NSInteger maxTimes;
@property (nonatomic, copy, readwrite) HPKRetryUtilsConditionBlock conditionBlock;
@property (nonatomic, copy, readwrite) HPKRetryUtilsSuccessBlock successBlock;
@property (nonatomic, copy, readwrite) HPKRetryUtilsFailedBlock failedBlock;
@property (nonatomic, weak, readwrite) id holder;

@property (atomic, assign, readwrite) NSInteger currentLoopNum;
@end

@implementation HPKRetryUtils

+ (HPKRetryUtils *)sharedInstance {
    static dispatch_once_t once;
    static HPKRetryUtils *singleton;
    dispatch_once(&once,
                  ^{
                      singleton = [[HPKRetryUtils alloc] init];
                  });
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _runLoop = (CFRunLoopRef)CFRetain(CFRunLoopGetMain());
        
        __weak typeof(self)_self = self;
        _observer = CFRunLoopObserverCreateWithHandler(
                                                       NULL,
                                                       kCFRunLoopAllActivities,
                                                       YES,
                                                       0,
                                                       ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
                                                           __strong typeof(_self)self = _self;
                                                           switch (activity) {
                                                               case kCFRunLoopBeforeWaiting:
                                                                   if (self.currentLoopNum > self.maxTimes) {
                                                                       if (self.failedBlock) {
                                                                           self.failedBlock(self.currentLoopNum);
                                                                       }
                                                                       [self stopRetryFunction];
                                                                   } else {
                                                                       if (self.conditionBlock()) {
                                                                           if (self.successBlock) {
                                                                               self.successBlock(self.currentLoopNum);
                                                                           }
                                                                           [self stopRetryFunction];
                                                                       } else {
                                                                           self.currentLoopNum++;
                                                                       }
                                                                   }
                                                                   break;
                                                               case kCFRunLoopExit:
                                                                   // main runloop never exit
                                                                   if (self.failedBlock) {
                                                                       self.failedBlock(self.currentLoopNum);
                                                                   }
                                                                   [self stopRetryFunction];
                                                                   break;
                                                               default:
                                                                   break;
                                                           }
                                                       });
    }
    return self;
}

- (void)retryFuntionWithHolder:(id)holder
                      MaxTimes:(NSInteger)maxTimes
                     condition:(HPKRetryUtilsConditionBlock)conditionBlock
                  successBlock:(HPKRetryUtilsSuccessBlock)successBlock
                   failedBlock:(HPKRetryUtilsFailedBlock)failedBlock {
    if (_observer == NULL || _runLoop == NULL) {
        HPKFatalLog(@"HPKRetryUtils observer or runloop is not exist");
        return;
    }
    
    //上次没执行完的，直接走到failed block中
    if (CFRunLoopContainsObserver(_runLoop, _observer, kCFRunLoopDefaultMode)) {
        HPKErrorLog(@"HPKRetryUtils should never observer simultaneously");
        CFRunLoopRemoveObserver(_runLoop, _observer, kCFRunLoopDefaultMode);
        if (self.failedBlock) {
            self.failedBlock(self.currentLoopNum);
        }
    }
    
    NSParameterAssert(conditionBlock != NULL);
    NSParameterAssert(successBlock != NULL);
    NSParameterAssert(failedBlock != NULL);
    NSParameterAssert(holder != nil);
    
    _maxTimes = maxTimes;
    _conditionBlock = [conditionBlock copy];
    _successBlock = [successBlock copy];
    _failedBlock = [failedBlock copy];
    _currentLoopNum = 1;
    _holder = holder;
    
    [self beginRetryFunction];
}

- (void)stopRetryFuntionWithHolder:(id)holder {
    if (CFRunLoopContainsObserver(CFRunLoopGetMain(), _observer, kCFRunLoopDefaultMode)) {
        if (holder == _holder) {
            [self stopRetryFunction];
            HPKInfoLog(@"HPKRetryUtils stop Retry when holder dealloc");
        } else {
            HPKInfoLog(@"HPKRetryUtils stop Retry failed with holder:%@ %@,", _holder, holder);
        }
    }
}

- (void)beginRetryFunction {
    if (CFRunLoopContainsObserver(_runLoop, _observer, kCFRunLoopDefaultMode)) {
        HPKErrorLog(@"HPKRetryUtils should never observer simultaneously");
        CFRunLoopRemoveObserver(_runLoop, _observer, kCFRunLoopDefaultMode);
    }
    
    CFRunLoopAddObserver(_runLoop, _observer, kCFRunLoopDefaultMode);
    
    HPKInfoLog(@"HPKRetryUtils begin observer runloop");
}

- (void)stopRetryFunction {
    if (CFRunLoopContainsObserver(CFRunLoopGetMain(), _observer, kCFRunLoopDefaultMode)) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopDefaultMode);
    }
    
    _maxTimes = 0;
    _conditionBlock = nil;
    _successBlock = nil;
    _failedBlock = nil;
    _currentLoopNum = 1;
    _holder = nil;
    
    HPKInfoLog(@"HPKRetryUtils stop observer runloop");
}

- (void)dealloc {
    if (CFRunLoopContainsObserver(CFRunLoopGetMain(), _observer, kCFRunLoopDefaultMode)) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopDefaultMode);
    }
    
    if (CFRunLoopObserverIsValid(_observer)) {
        CFRunLoopObserverInvalidate(_observer);
    }
    
    if (_observer != NULL) {
        CFRelease(_observer);
        _observer = NULL;
    }
    
    if (_runLoop != NULL) {
        CFRelease(_runLoop);
        _runLoop = NULL;
    }
    
    _conditionBlock = nil;
    _successBlock = nil;
    _failedBlock = nil;
    _holder = nil;
}

@end

#define HPKWebViewContentSize @"contentSize"

@interface HPKWebViewExtensionDelegate ()

@property (nonatomic, weak, readwrite) __kindof WKWebView *webView;
@property (nonatomic, weak, readwrite) NSObject<HPKDefaultWebViewProtocol> *originalDelegate;
@property (nonatomic, copy, readwrite) NSArray<NSObject<HPKDefaultWebViewProtocol> *> *navigationDelegates;

@property (nonatomic, copy, readwrite) HPKWebViewMainNavDelegateScrollBlock webViewScrollBlock;;
@property (nonatomic, copy, readwrite) HPKWebViewMainNavDelegateContentSizeChangeBlock contentSizeChangeBlock;

@property (nonatomic, assign, readwrite) CGFloat lastReadPositionY;
@property (nonatomic, assign, readwrite) BOOL hasAddObserver;
@end

@implementation HPKWebViewExtensionDelegate

- (void)dealloc {
    //stop Retry
    [[HPKRetryUtils sharedInstance] stopRetryFuntionWithHolder:self];
    //remove observer
    [self.webView.scrollView safeRemoveObserver:self keyPath:HPKWebViewContentSize];
    self.webView = nil;
    self.originalDelegate = nil;
    _navigationDelegates = nil;
    _webViewScrollBlock = nil;
    _contentSizeChangeBlock = nil;
}

- (instancetype)initWithOriginalDelegate:(NSObject<HPKDefaultWebViewProtocol> *)originalDelegate
                     navigationDelegates:(NSArray<NSObject<HPKDefaultWebViewProtocol> *> *)navigationDelegates{
    self = [super init];
    if (self) {
        self.originalDelegate = originalDelegate;
        _navigationDelegates = navigationDelegates;
    }
    return self;
}

#pragma mark - public method

- (void)configWebViewLastReadPositionY:(CGFloat)lastReadPositionY
                           scrollBlock:(HPKWebViewMainNavDelegateScrollBlock)scrollBlock{
    _lastReadPositionY = lastReadPositionY;
    _webViewScrollBlock = [scrollBlock copy];
}

- (void)configWebView:(__kindof WKWebView *)webView contentSizeChangeBlock:(HPKWebViewMainNavDelegateContentSizeChangeBlock)contentSizeChangeBlock{
    
    if (_hasAddObserver) {
        [self.webView.scrollView safeRemoveObserver:self keyPath:HPKWebViewContentSize];
        _hasAddObserver = NO;
    }
    
    self.webView = webView;
    _contentSizeChangeBlock = [contentSizeChangeBlock copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self triggerWebViewEvent:HPKWebViewEventInitialized para1:nil para2:nil];
    });
}

- (void)triggerRelayoutWebComponentEvent{
    [self triggerWebViewEvent:HPKWebViewEventLayoutWebComponent para1:nil para2:nil];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    if ([self.originalDelegate respondsToSelector:@selector(webViewDecidePolicyForNavigationResponse:decisionHandler:)]) {
        [self.originalDelegate webViewDecidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
        return;
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *_Nullable credential))completionHandler {
    if ([self.originalDelegate respondsToSelector:@selector(webViewDidReceiveAuthenticationChallenge:completionHandler:)]) {
        [self.originalDelegate webViewDidReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
        return;
    }
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if (!url.absoluteString || url.absoluteString.length <= 0) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    // 复用的url
    if ([url.absoluteString isEqualToString:[[HPKPageManager sharedInstance] webViewReuseLoadUrlStr]]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if ([self.originalDelegate respondsToSelector:@selector(webViewDecidePolicyForNavigationAction:decisionHandler:)]) {
        [self.originalDelegate webViewDecidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self triggerWebViewEvent:HPKWebViewEventStartProvisionalNavigation para1:navigation para2:nil];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self triggerWebViewEvent:HPKWebViewEventReceiveServerRedirect para1:navigation para2:nil];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self triggerWebViewEvent:HPKWebViewEventFailProvisionalNavigation para1:navigation para2:error];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    [self triggerWebViewEvent:HPKWebViewEventCommitNavigation para1:navigation para2:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    if (!_hasAddObserver) {
        __weak typeof(self) _self = self;
        [self.webView.scrollView safeAddObserver:self keyPath:HPKWebViewContentSize callback:^(NSObject *oldValue, NSObject *newValue) {
            __strong typeof(_self) self = _self;
            if (self.contentSizeChangeBlock) {
                self.contentSizeChangeBlock((NSValue *)newValue,(NSValue *)oldValue);
            }
            [self triggerWebViewEvent:HPKWebViewEventContentSizeChange para1:(NSValue *)newValue para2:(NSValue *)oldValue];
        }];
        _hasAddObserver = YES;
    }

    [self triggerWebViewEvent:HPKWebViewEventFinishNavigation para1:navigation para2:nil];
    //进行监听展示webView
    [self _showWebView];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self triggerWebViewEvent:HPKWebViewEventFailNavigation para1:navigation para2:error];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self triggerWebViewEvent:HPKWebViewEventTerminate para1:nil para2:nil];
}

#pragma mark - private method

- (void)_showWebView {
    __weak typeof(self) _self = self;
    [[HPKRetryUtils sharedInstance] retryFuntionWithHolder:self
                                                       MaxTimes:[HPKPageManager sharedInstance].webViewShowMaxRetryTimes
                                                      condition:^BOOL {
        __strong typeof(_self) self = _self;
        if (self.lastReadPositionY <= 0) {
            //没有上次阅读位置的,只要webview有内容了就展示
            return self.webView.scrollView.contentSize.height > 0;
        } else {
            //有上次阅读位置的
            if (self.webView.scrollView.contentSize.height + self.webView.frame.origin.y - self.webView.frame.size.height >= self.lastReadPositionY) {
                return YES;
            }
            return NO;
        }
    }
                                                   successBlock:^(NSInteger currentTimes) {
        __strong typeof(_self) self = _self;
        if (self.lastReadPositionY > 0 && self.webViewScrollBlock) {
            self.webViewScrollBlock(CGPointMake(0, self.lastReadPositionY));
        }
        [self _showWebViewWithAnimation];
        HPKInfoLog(@"HPKWebView success show by %@ runloops", @(currentTimes));
    }
                                                    failedBlock:^(NSInteger currentTimes) {
        __strong typeof(_self) self = _self;
        HPKErrorLog(@"HPKWebView fail render content by %@ runloops,contentSize height:%@,last offsetY:%@,webviewcontentSizeHeight:%@",
             @(currentTimes),
             @(self.webView.scrollView.contentSize.height),
             @(self.lastReadPositionY),
             @(self.webView.scrollView.contentSize.height));
        //容错 失败的直接展示
        if (self.lastReadPositionY > 0 && self.webViewScrollBlock) {
            //直接滚到最底部
            self.webViewScrollBlock(CGPointMake(0, self.lastReadPositionY));
        }
        [self _showWebViewWithAnimation];
    }];
}

- (void)_showWebViewWithAnimation {
    [self triggerWebViewEvent:HPKWebViewEventWillShow para1:nil para2:nil];
    [UIView animateWithDuration:0.2
                     animations:^{
        self.webView.alpha = 1.0f;
    }
                     completion:^(BOOL finished) {
        self.webView.alpha = 1.0f;
        [self triggerWebViewEvent:HPKWebViewEventDidShow para1:nil para2:nil];
    }];
}

#pragma mark -

- (void)triggerWebViewEvent:(HPKWebViewEvent)event para1:(NSObject *)para1 para2:(NSObject *)para2{
    
    SEL protocolSelector = _getHPKWebViewProtocolByEventType(event);
    if (!protocolSelector) {
        HPKFatalLog(@"HPKWebViewComponent trigger invalid event:%@", @(event));
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.originalDelegate respondsToSelector:protocolSelector]) {
        [self.originalDelegate performSelector:protocolSelector withObject:para1 withObject:para2];
    }
#pragma clang diagnostic pop
    
    for (__kindof NSObject<HPKDefaultWebViewProtocol> *delegate in self.navigationDelegates) {
        
        if (delegate == self.originalDelegate) {
            continue;
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([delegate respondsToSelector:protocolSelector]) {
            [delegate performSelector:protocolSelector withObject:para1 withObject:para2];
        }
#pragma clang diagnostic pop
    }
}

@end
