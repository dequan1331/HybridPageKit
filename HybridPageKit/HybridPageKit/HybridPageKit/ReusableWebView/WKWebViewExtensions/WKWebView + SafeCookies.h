//
//  WKWebView + SafeCookies.h
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WKWebView (SafeCookies)

- (void)setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expiresDate:(NSDate *)expiresDate;

- (void)deleteCookiesWithName:(NSString *)name;

- (NSSet<NSString *> *)getAllCustomCookiesName;
- (void)deleteAllCustomCookies;

@end
