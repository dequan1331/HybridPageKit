//
//  HPKWebViewPool.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKWebViewPool.h"
#import "HPKWebView.h"

@interface HPKWebViewPool ()
@property(nonatomic, strong, readwrite) dispatch_semaphore_t lock;
@property(nonatomic, strong, readwrite) NSMutableSet<__kindof HPKWebView *> *visiableWebViewSet;
@property(nonatomic, strong, readwrite) NSMutableSet<__kindof HPKWebView *> *reusableWebViewSet;

@end

@implementation HPKWebViewPool

+ (HPKWebViewPool *)shareInstance {
    static dispatch_once_t once;
    static HPKWebViewPool *webViewPool = nil;
    dispatch_once(&once,^{
                    webViewPool = [[HPKWebViewPool alloc] init];
                  });
    return webViewPool;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
    self = [super init];
    if(self){
        _visiableWebViewSet = [NSSet set].mutableCopy;
        _reusableWebViewSet = [NSSet set].mutableCopy;
        
        _lock = dispatch_semaphore_create(1);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_clearReusableWebViews)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (__kindof HPKWebView *)getReusedWebViewForHolder:(id)holder{
    if (!holder) {
        NSLog(@"HPKWebViewPool must have a holder");
        return nil;
    }
    
    [self _tryCompactWeakHolders];
    
    HPKWebView *webView;
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (_reusableWebViewSet.count > 0) {
        webView = (HPKWebView *)[_reusableWebViewSet anyObject];
        [_reusableWebViewSet removeObject:webView];
        [_visiableWebViewSet addObject:webView];
        [webView webViewWillReuse];
    } else {
        webView = [[HPKWebView alloc] initWithFrame:CGRectZero];
        [_visiableWebViewSet addObject:webView];
    }
    webView.holderObject = holder;
    dispatch_semaphore_signal(_lock);

    return webView;
}

- (void)recycleReusedWebView:(__kindof HPKWebView *)webView{
    if (!webView) {
        return;
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([_visiableWebViewSet containsObject:webView]) {
        [webView webViewEndReuse];
        [_visiableWebViewSet removeObject:webView];
        [_reusableWebViewSet addObject:webView];

    } else {
        if (![_reusableWebViewSet containsObject:webView]) {
            NSLog(@"HPKWebViewPool reuse a webView in no where");
        }
    }
    dispatch_semaphore_signal(_lock);
}

- (void)cleanReusableViews{
     [self _clearReusableWebViews];
}

#pragma mark - safe dealloc

- (void)_tryCompactWeakHolders {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSMutableSet<HPKWebView *> *shouldreusedWebViewSet = [NSMutableSet set];
    for (HPKWebView *webView in _visiableWebViewSet) {
        if (!webView.holderObject) {
            [shouldreusedWebViewSet addObject:webView];
        }
    }
    for (HPKWebView *webView in shouldreusedWebViewSet) {
        [webView webViewEndReuse];
        [_visiableWebViewSet removeObject:webView];
        [_reusableWebViewSet addObject:webView];
    }
    dispatch_semaphore_signal(_lock);
}

- (void)_clearReusableWebViews {
    [self _tryCompactWeakHolders];
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_reusableWebViewSet removeAllObjects];
    dispatch_semaphore_signal(_lock);
    NSLog(@"HPKWebViewPool remove all reusable webViews");
    
    [WKWebView safeClearAllCache];
    NSLog(@"HPKWebViewPool clean all cache");
}

@end
