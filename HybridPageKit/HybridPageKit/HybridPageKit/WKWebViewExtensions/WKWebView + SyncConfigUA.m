//
//  WKWebView + SyncConfigUA.m
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "WKWebView + SyncConfigUA.h"

@implementation WKWebView (SyncConfigUA)

+ (void)configCustomUAWithType:(ConfigUAType)type
                      UAString:(NSString *)customString{
    
    if (!customString || customString.length <= 0) {
        NSLog(@"WKWebView (SyncConfigUA) config with invalid string");
        return;
    }
    
    if(type == kConfigUATypeReplace){
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:customString, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    }else if (type == kConfigUATypeAppend){
        UIWebView *webView = [[UIWebView alloc] init];
        NSString *originalUserAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSString *appUserAgent =
        [NSString stringWithFormat:@"%@-%@", originalUserAgent, customString];
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:appUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    }else{
        NSLog(@"WKWebView (SyncConfigUA) config with invalid type :%@", @(type));
    }
}

@end
