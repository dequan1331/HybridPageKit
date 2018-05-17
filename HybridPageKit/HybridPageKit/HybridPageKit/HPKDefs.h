//
//  HPKDefs.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

@class HPKAbstractViewController;
@class HPKWebView;

#import "HPKModelProtocol.h"

#define HPKModel NSObject<HPKModelProtocol>
#define HPKController NSObject<HPKComponentControllerDelegate>

@protocol HPKComponentControllerDelegate

@required
- (BOOL)shouldResponseWithComponentView:(__kindof UIView *)componentView
                         componentModel:(HPKModel *)componentModel;

@optional
//controller
- (void)controllerInit:(__kindof HPKAbstractViewController *)controller;
- (void)controllerViewDidLoad:(__kindof HPKAbstractViewController *)controller;
- (void)controllerViewWillAppear:(__kindof HPKAbstractViewController *)controller;
- (void)controllerViewDidAppear:(__kindof HPKAbstractViewController *)controller;
- (void)controllerViewWillDisappear:(__kindof HPKAbstractViewController *)controller;
- (void)controllerViewDidDisappear:(__kindof HPKAbstractViewController *)controller;

//data
- (void)controller:(__kindof HPKAbstractViewController *)controller
    didReceiveData:(NSObject *)data;

//webview
- (void)webViewDidFinishNavigation:(__kindof HPKWebView *)webView;
- (void)webViewDidShow:(__kindof HPKWebView *)webView;
- (void)webViewScrollViewDidScroll:(__kindof HPKWebView *)webView;

//component scroll
- (void)scrollViewWillDisplayComponentView:(__kindof UIView *)componentView
                            componentModel:(HPKModel *)componentModel;

- (void)scrollViewEndDisplayComponentView:(__kindof UIView *)componentView
                           componentModel:(HPKModel *)componentModel;

- (void)scrollViewWillPrepareComponentView:(__kindof UIView *)componentView
                            componentModel:(HPKModel *)componentModel;

- (void)scrollViewEndPrepareComponentView:(__kindof UIView *)componentView
                           componentModel:(HPKModel *)componentModel;

- (void)scrollViewRelayoutComponentView:(__kindof UIView *)componentView
                         componentModel:(HPKModel *)componentModel;
@end

typedef NS_ENUM(NSInteger, HPKComponentEvent) {
    //controller
    kHPKComponentEventControllerInit,
    kHPKComponentEventControllerViewDidLoad,
    kHPKComponentEventControllerViewWillAppear,
    kHPKComponentEventControllerViewDidAppear,
    kHPKComponentEventControllerViewWillDisappear,
    kHPKComponentEventControllerViewDidDisappear,
    //data
    kHPKComponentEventControllerDidReceiveData,
    //webview
    kHPKComponentEventWebViewDidFinishNavigation,
    kHPKComponentEventWebViewDidShow,
    kHPKComponentEventWebViewScrollViewDidScroll,
    //component scroll
    kHPKComponentScrollEventIndexBegin,
    kHPKComponentEventWillDisplayComponentView,
    kHPKComponentEventEndDisplayComponentView,
    kHPKComponentEventWillPrepareComponentView,
    kHPKComponentEventEndPrepareComponentView,
    kHPKComponentEventRelayoutComponentView,
    kHPKComponentScrollEventIndexEnd,
};

static inline SEL _getHPKComponentControllerDelegateByEventType(HPKComponentEvent event) {
    SEL mapping[] =
    {   [kHPKComponentEventControllerInit] = @selector(controllerInit:),
        [kHPKComponentEventControllerViewDidLoad] = @selector(controllerViewDidLoad:),
        [kHPKComponentEventControllerViewWillAppear] = @selector(controllerViewWillAppear:),
        [kHPKComponentEventControllerViewDidAppear] = @selector(controllerViewDidAppear:),
        [kHPKComponentEventControllerViewWillDisappear] = @selector(controllerViewWillDisappear:),
        [kHPKComponentEventControllerViewDidDisappear] = @selector(controllerViewDidDisappear:),
        [kHPKComponentEventControllerDidReceiveData] = @selector(controller:didReceiveData:),
        [kHPKComponentEventWebViewDidFinishNavigation] = @selector(webViewDidFinishNavigation:),
        [kHPKComponentEventWebViewDidShow] = @selector(webViewDidShow:),
        [kHPKComponentEventWebViewScrollViewDidScroll] = @selector(webViewScrollViewDidScroll:),
        [kHPKComponentEventWillDisplayComponentView] = @selector(scrollViewWillDisplayComponentView:componentModel:),
        [kHPKComponentEventEndDisplayComponentView] = @selector(scrollViewEndDisplayComponentView:componentModel:),
        [kHPKComponentEventWillPrepareComponentView] = @selector(scrollViewWillPrepareComponentView:componentModel:),
        [kHPKComponentEventEndPrepareComponentView] = @selector(scrollViewEndPrepareComponentView:componentModel:),
        [kHPKComponentEventRelayoutComponentView] =
        @selector(scrollViewRelayoutComponentView:componentModel:)
    };
    return mapping[event];
}
