//
//  WKWebView + SafeClearCache.h
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WKWebView (SafeClearCache)
/**
 *  WKWebView Clear All Cache Include iOS8
 */
+ (void)safeClearAllCache;

@end
