//
//  WKWebView + SafeScrollTo.h
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^SafeScrollToCompletionBlock)(BOOL success , NSInteger loopTimes);

@interface WKWebView (SafeScrollTo)
/**
 *  WKWebView Safe ScrollTo Specific Offset Without Blank Screen
 *
 *  @param offset               webView Offset
 *  @param maxRunloops          max wait runloops
 *  @param completionBlock      complete block
 */
- (void)scrollToOffset:(CGFloat)offset
           maxRunloops:(NSUInteger)maxRunloops
       completionBlock:(SafeScrollToCompletionBlock)completionBlock;

@end
