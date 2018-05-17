//
//  WKWebView + ExternalNavigationDelegates.h
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WKWebView (ExternalNavigationDelegates)

- (void) useExternalNavigationDelegate;
- (void) unUseExternalNavigationDelegate;

@property(nonatomic, weak) id<WKNavigationDelegate> mainNavigationDelegate;

- (void)addExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (void)removeExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (BOOL)containsExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (void)clearExternalNavigationDelegates;


@end
