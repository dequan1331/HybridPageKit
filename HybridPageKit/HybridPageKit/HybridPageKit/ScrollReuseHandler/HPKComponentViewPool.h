//
//  HPKComponentViewPool.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define HPKComponentViewPoolMaxResuableCount 10

@interface HPKComponentViewPool : NSObject

+ (HPKComponentViewPool *)shareInstance;

- (__kindof UIView *)dequeueComponentViewWithIdentifier:(NSString*)identifier
                                              viewClass:(Class)viewClass;

- (void)enqueueComponentView:(__kindof UIView *)componentView;
- (void)enqueueAllComponentViewOfSuperView:(__kindof UIView *)superView;

- (void)clearAllReusableComponentViews;

#pragma mark -

- (NSDictionary *)getDequeueViewsDic;
- (NSDictionary *)getEnqueueViewsDic;

@end

