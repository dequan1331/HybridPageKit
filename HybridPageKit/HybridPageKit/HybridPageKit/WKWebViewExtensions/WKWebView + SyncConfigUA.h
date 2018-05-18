//
//  WKWebView + SyncConfigUA.h
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef NS_ENUM (NSInteger, ConfigUAType){
    kConfigUATypeReplace,     //replace all UA string
    kConfigUATypeAppend,      //append to original UA string
};

@interface WKWebView (SyncConfigUA)
/**
 *  Sync Config UA Without WKWebView
 *
 *  @param type            replace or append original UA
 *  @param customString    custom UA string
 */
+ (void)configCustomUAWithType:(ConfigUAType)type
                      UAString:(NSString *)customString;

@end
