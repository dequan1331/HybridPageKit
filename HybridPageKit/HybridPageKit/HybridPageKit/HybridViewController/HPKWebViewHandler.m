//
//  HPKWebViewHandler.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKWebViewHandler.h"
#import "HPKAbstractViewController.h"
#import "WKWebViewExtensionsDef.h"
#import "HPKWebViewPool.h"
#import "HPKURLProtocol.h"

#define HPKWebViewHandlerComponentClass @"HPK-Component-PlaceHolder"

@interface HPKWebViewHandler()
@property(nonatomic,weak,readwrite)__kindof HPKAbstractViewController *controller;
@property(nonatomic,assign,readwrite)CGSize lastWebViewContentSize;

@end

@implementation HPKWebViewHandler

- (instancetype)initWithController:(__kindof HPKAbstractViewController *)controller
                      webViewFrame:(CGRect)webViewFrame{
    self = [super init];
    if (self) {
        _controller = controller;
        [self _initWebViewWithFrame:webViewFrame];
    }
    return self;
}

- (void)dealloc{
    [_webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [[HPKWebViewPool shareInstance] recycleReusedWebView:_webView];
}

#pragma mark -

- (void)_initWebViewWithFrame:(CGRect)frame {
    _webView = [[HPKWebViewPool shareInstance] getReusedWebViewForHolder:self];
    _webView.frame = frame;
    [HPKWebView fixWKWebViewMenuItems];
    [_webView useExternalNavigationDelegate];
    [_webView setMainNavigationDelegate:self];
    [HPKWebView supportProtocolWithHTTP:NO
                      customSchemeArray:@[HPKURLProtocolHandleScheme]
                       urlProtocolClass:[HPKURLProtocol class]];
    [_webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    _webView.scrollView.scrollEnabled = NO;
}


#pragma mark -

+ (NSString *)getWebViewContentHeightWithContainerWidth:(int)width{
    if (width <= 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"document.documentElement.offsetHeight * %d / document.documentElement.clientWidth", width];
}

+ (NSString *)getComponentFrameJs{
    return [NSString stringWithFormat:@"function HPKGetAllComponentFrame(){var componentFrameDic=[];var list= document.getElementsByClassName('%@');for(var i=0;i<list.length;i++){var dom = list[i];componentFrameDic.push({'index':dom.getAttribute('data-index'),'top':dom.offsetTop,'left':dom.offsetLeft,'width':dom.clientWidth,'height':dom.clientHeight});}return componentFrameDic;}",HPKWebViewHandlerComponentClass];
}
+ (NSString *)componentHtmlTemplate{
    return [NSString stringWithFormat:@"<div class='%@' style='width:{{width}}px;height:{{height}}px' data-index='{{componentIndex}}'></div>",HPKWebViewHandlerComponentClass];
}
+ (NSString *)setComponentJSWithIndex:(NSString *)index
                        componentSize:(CGSize)componentSize{
    if (!index) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"var dom=$(\".HPK-Component-PlaceHolder[data-index='%@']\");dom.width('%@px');dom.height('%@px');",index,@(componentSize.width),@(componentSize.height)];
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    CGSize newSize = [((NSValue *)[change objectForKey:NSKeyValueChangeNewKey]) CGSizeValue];
        
    if(!CGSizeEqualToSize(newSize,_lastWebViewContentSize)){
        _lastWebViewContentSize = newSize;
        [self.controller reLayoutWebViewComponents];
    }
}

#pragma mark -
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
    [self.controller triggerEvent:kHPKComponentEventWebViewDidFinishNavigation para1:webView];
    __weak typeof(self) wself = self;
    [webView scrollToOffset:MAX(0.f, _controller.viewConfig.lastReadPostion)
                maxRunloops:MAX(10.f,_controller.viewConfig.scrollWaitMaxRunloops)
            completionBlock:^(BOOL success, NSInteger loopTimes) {
                __strong __typeof(wself) strongSelf = wself;
                [strongSelf.controller triggerEvent:kHPKComponentEventWebViewDidShow para1:webView];
                [strongSelf.controller reLayoutWebViewComponents];
            }];
}
@end
