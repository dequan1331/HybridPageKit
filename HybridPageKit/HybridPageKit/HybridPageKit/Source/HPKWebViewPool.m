//
// HPKWebViewPool.m
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


#import "HPKWebViewPool.h"
#import "_HPKUtils.h"
#import "WKWebView + HPKReusable.h"

@interface HPKWebViewPool ()
@property (nonatomic, strong, readwrite) dispatch_semaphore_t lock;
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NSMutableSet< __kindof HPKWebView *> *> *dequeueWebViews;
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NSMutableSet< __kindof HPKWebView *> *> *enqueueWebViews;
@end

@implementation HPKWebViewPool

+ (HPKWebViewPool *)sharedInstance {
    static dispatch_once_t once;
    static HPKWebViewPool *singleton;
    dispatch_once(&once,
                  ^{
        singleton = [[HPKWebViewPool alloc] init];
    });
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dequeueWebViews = @{}.mutableCopy;
        _enqueueWebViews = @{}.mutableCopy;
        _lock = dispatch_semaphore_create(1);
        //memory warning 时清理全部
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearAllReusableWebViews)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.dequeueWebViews removeAllObjects];
    [self.enqueueWebViews removeAllObjects];
    self.dequeueWebViews = nil;
    self.enqueueWebViews = nil;
}

#pragma mark - public method

- (__kindof HPKWebView *)dequeueWebViewWithClass:(Class)webViewClass webViewHolder:(NSObject *)webViewHolder {
    if (![webViewClass isSubclassOfClass:[HPKWebView class]]) {
        HPKErrorLog(@"HPKViewPool dequeue with invalid class:%@", webViewClass);
        return nil;
    }

    //auto recycle
    [self _tryCompactWeakHolderOfWebView];

    __kindof HPKWebView *dequeueWebView = [self _getWebViewWithClass:webViewClass];
    dequeueWebView.holderObject = webViewHolder;
    return dequeueWebView;
}

- (void)enqueueWebView:(__kindof HPKWebView *)webView {
    if (!webView) {
        HPKErrorLog(@"HPKViewPool enqueue with invalid view:%@", webView);
        return;
    }
    [webView removeFromSuperview];
    if (webView.reusedTimes >= [[HPKPageManager sharedInstance] webViewMaxReuseTimes] || webView.invalid) {
        [self removeReusableWebView:webView];
    } else {
        [self _recycleWebView:webView];
    }
}

- (void)reloadAllReusableWebViews {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    for (NSMutableSet *viewSet in _enqueueWebViews.allValues) {
        for (__kindof HPKWebView *webView in viewSet) {
            [webView componentViewWillEnterPool];
        }
    }
    dispatch_semaphore_signal(_lock);
}

- (void)clearAllReusableWebViews {
    //auto recycle
    [self _tryCompactWeakHolderOfWebView];

    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_enqueueWebViews removeAllObjects];
    dispatch_semaphore_signal(_lock);
}

- (void)removeReusableWebView:(__kindof HPKWebView *)webView {
    if (!webView) {
        return;
    }

    if ([webView respondsToSelector:@selector(componentViewWillEnterPool)]) {
        [webView componentViewWillEnterPool];
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);

    NSString *webViewClassString = NSStringFromClass([webView class]);

    if ([[_dequeueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet =  [_dequeueWebViews objectForKey:webViewClassString];
        [viewSet removeObject:webView];
    }

    if ([[_enqueueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet =  [_enqueueWebViews objectForKey:webViewClassString];
        [viewSet removeObject:webView];
    }
    dispatch_semaphore_signal(_lock);
}

- (void)clearAllReusableWebViewsWithClass:(Class)webViewClass {
    NSString *webViewClassString = NSStringFromClass(webViewClass);

    if (!webViewClassString || webViewClassString.length <= 0) {
        return;
    }

    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([[_enqueueWebViews allKeys] containsObject:webViewClassString]) {
        [_enqueueWebViews removeObjectForKey:webViewClassString];
    }
    dispatch_semaphore_signal(_lock);
}

#pragma mark - private method

- (void)_tryCompactWeakHolderOfWebView {
    NSDictionary *dequeueWebViewsTmp = _dequeueWebViews.copy;
    if (dequeueWebViewsTmp && dequeueWebViewsTmp.count > 0) {
        for (NSMutableSet *viewSet in dequeueWebViewsTmp.allValues) {
            NSSet *webViewSetTmp = viewSet.copy;
            for (__kindof HPKWebView *webView in webViewSetTmp) {
                if (!webView.holderObject) {
                    [self enqueueWebView:webView];
                }
            }
        }
    }
}

- (void)_recycleWebView:(__kindof HPKWebView *)webView {
    if (!webView) {
        return;
    }

    //进入回收池前清理
    if ([webView respondsToSelector:@selector(componentViewWillEnterPool)]) {
        [webView componentViewWillEnterPool];
    }

    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSString *webViewClassString = NSStringFromClass([webView class]);
    if ([[_dequeueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet =  [_dequeueWebViews objectForKey:webViewClassString];
        [viewSet removeObject:webView];
    } else {
        dispatch_semaphore_signal(_lock);
        HPKFatalLog(@"HPKWebViewPool recycle invalid view");
    }

    if ([[_enqueueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet =  [_enqueueWebViews objectForKey:webViewClassString];

        if (viewSet.count < [HPKPageManager sharedInstance].componentsMaxReuseCount) {
            [viewSet addObject:webView];
        } else {
        }
    } else {
        NSMutableSet *viewSet = [[NSSet set] mutableCopy];
        [viewSet addObject:webView];
        [_enqueueWebViews setValue:viewSet forKey:webViewClassString];
    }

    dispatch_semaphore_signal(_lock);
}

- (__kindof HPKWebView *)_getWebViewWithClass:(Class)webViewClass {
    NSString *webViewClassString = NSStringFromClass(webViewClass);

    if (!webViewClassString || webViewClassString.length <= 0) {
        return nil;
    }

    __kindof HPKWebView *webView;

    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);

    if ([[_enqueueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet =  [_enqueueWebViews objectForKey:webViewClassString];
        if (viewSet && viewSet.count > 0) {
            webView = [viewSet anyObject];
            if (![webView isMemberOfClass:webViewClass]) {
                HPKFatalLog(@"HPKWebViewPool webViewClassString: %@ already has webview of class:%@, params is %@", webViewClassString, NSStringFromClass([webView class]), NSStringFromClass(webViewClass));
                return nil;
            }
            [viewSet removeObject:webView];
        }
    }

    if (!webView) {
        webView = [[webViewClass alloc] initWithFrame:CGRectZero];
    }

    if ([[_dequeueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet =  [_dequeueWebViews objectForKey:webViewClassString];
        [viewSet addObject:webView];
    } else {
        NSMutableSet *viewSet = [[NSSet set] mutableCopy];
        [viewSet addObject:webView];
        [_dequeueWebViews setValue:viewSet forKey:webViewClassString];
    }
    dispatch_semaphore_signal(_lock);

    //出回收池前初始化
    if ([webView respondsToSelector:@selector(componentViewWillLeavePool)]) {
        [webView componentViewWillLeavePool];
    }

    return webView;
}

@end
