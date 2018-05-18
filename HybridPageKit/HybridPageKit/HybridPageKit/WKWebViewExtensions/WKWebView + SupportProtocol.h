//
//  WKWebView + SupportProtocol.h
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WKWebView (SupportProtocol)
/**
 *  WKWebView Support Protocol Like UIWebView
 *
 *  @param supportHTTP         support protocol for HTTP & HTTPS
 *  @param customSchemeArray   support protocol fro custom scheme
 */
+ (void) supportProtocolWithHTTP:(BOOL)supportHTTP
               customSchemeArray:(NSArray<NSString *> *)customSchemeArray;

@end
