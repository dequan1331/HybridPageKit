//
//  HPKWebViewHandler.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//
#import <WebKit/WebKit.h>
#import "HPKAbstractViewController.h"
#import "HPKWebView.h"

@interface HPKWebViewHandler : NSObject<WKNavigationDelegate>

@property(nonatomic, strong, readwrite)HPKWebView *webView;

- (instancetype)initWithController:(__kindof HPKAbstractViewController *)controller
                      webViewFrame:(CGRect)webViewFrame;

@end
