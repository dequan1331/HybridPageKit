//
//  WKWebView + DeleteMenuItems.h
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WKWebView (DeleteMenuItems)
/**
 *  Fix WKWebView MenuItems
 *  Delete System Items Without cut/copy/paste/delete
 */
+ (void)fixWKWebViewMenuItems;
@end
