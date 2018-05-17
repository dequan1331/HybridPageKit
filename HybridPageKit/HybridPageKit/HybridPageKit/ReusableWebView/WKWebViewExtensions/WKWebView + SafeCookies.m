//
//  WKWebView + SafeCookies.m
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "WKWebView + SafeCookies.h"
#import "WKWebView + SafeEvaluateJS.h"
#import <objc/runtime.h>

@interface WKWebView()
@property(nonatomic,strong,readwrite)NSMutableDictionary<NSString *, NSString *> *HPKCookieDic;
@end

@implementation WKWebView (SafeCookies)

- (void)setHPKCookieDic:(NSMutableDictionary *)HPKCookieDic{
    objc_setAssociatedObject(self, @"HPKCookieDic", HPKCookieDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)HPKCookieDic{
    NSMutableDictionary *HPKCookieDic = objc_getAssociatedObject(self, @"HPKCookieDic");
    if (!HPKCookieDic) {
        HPKCookieDic = @{}.mutableCopy;
    }
    return HPKCookieDic;
}

- (void)setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expiresDate:(NSDate *)expiresDate{
    if(!name || name.length <=0){
        return;
    }
    
    NSMutableString *cookieScript = [[NSMutableString alloc] init];
    [cookieScript appendFormat:@"document.cookie='%@=%@;",name,value];
    if(domain || domain.length > 0){
        [cookieScript appendFormat:@"domain=%@;",domain];
    }
    if(path || path.length > 0){
        [cookieScript appendFormat:@"path=%@;",path];
    }
    
    [[self HPKCookieDic] setValue:cookieScript.copy forKey:name];
    
    if([expiresDate timeIntervalSince1970] != 0){
        [cookieScript appendFormat:@"expires='+(new Date(%@).toUTCString());", @(([expiresDate timeIntervalSince1970]) * 1000)];
    }
    [cookieScript appendFormat:@"\n"];

    [self safeAsyncEvaluateJavaScriptString:cookieScript.copy];
}

- (void)deleteCookiesWithName:(NSString *)name{
    if(!name || name.length <=0){
        return;
    }
    
    if (![[[self HPKCookieDic] allKeys] containsObject:name]) {
        return;
    }

    NSMutableString *cookieScript = [[NSMutableString alloc] init];
    
    [cookieScript appendString:[[self HPKCookieDic] objectForKey:name]];
    [cookieScript appendFormat:@"expires='+(new Date(%@).toUTCString());\n",@(0)];
    
    [[self HPKCookieDic] removeObjectForKey:name];
    [self safeAsyncEvaluateJavaScriptString:cookieScript.copy];
}

- (NSSet<NSString *> *)getAllCustomCookiesName{
    return [[self HPKCookieDic] allKeys].copy;
}
- (void)deleteAllCustomCookies{
    for (NSString *cookieName in [[self HPKCookieDic] allKeys]) {
        [self deleteCookiesWithName:cookieName];
    }
}

@end
