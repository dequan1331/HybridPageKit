//
//  HPKJavascriptUtils.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HPKJavascriptUtils : NSObject

//js string
+ (NSString *)getWebViewContentHeightWithContainerWidth:(int)width;

+ (NSString *)setComponentJSWithWithDomClass:(NSString *)domClass
                                       index:(NSString *)index
                               componentSize:(CGSize)componentSize;

+ (NSString *)getComponentFrameJsWithDomClass:(NSString *)domClass;


@end
