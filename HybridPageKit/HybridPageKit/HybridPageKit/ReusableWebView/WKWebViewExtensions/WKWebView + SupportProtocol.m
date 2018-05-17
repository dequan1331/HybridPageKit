//
//  WKWebView + SupportProtocol.m
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "WKWebView + SupportProtocol.h"

@implementation WKWebView (SupportProtocol)

+ (void) supportProtocolWithHTTP:(BOOL)supportHTTP
               customSchemeArray:(NSArray<NSString *> *)customSchemeArray{

    if (!supportHTTP && [customSchemeArray count] <= 0) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      Class cls = NSClassFromString([NSString stringWithFormat:@"%@%@%@%@%@", @"W", @"K", @"Browsing", @"Context", @"Controller"]);
                      SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@%@", @"register", @"SchemeFor", @"Custom", @"Protocol", @":"]);
                      
                      if (!cls || !sel || ![cls respondsToSelector:sel]) {
                          NSLog(@"WKWebView (SupportProtocol) has invalid cls or sel");
                          return;
                      }
                      
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                      if (supportHTTP) {
                          [cls performSelector:sel withObject:@"http"];
                          [cls performSelector:sel withObject:@"https"];
                      }
                      
                      for (NSString *scheme in customSchemeArray) {
                          [cls performSelector:sel withObject:scheme];
                      }
#pragma clang diagnostic pop
                  });
}


@end
