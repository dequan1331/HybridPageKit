//
//  UIKit + HPK.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HPKLayout)

@property (nonatomic, copy, readwrite) NSString  *HPKId;

@property(nonatomic,assign,readwrite) CGFloat hpk_width;
@property(nonatomic,assign,readwrite) CGFloat hpk_height;
@property(nonatomic,assign,readwrite) CGFloat hpk_top;
@property(nonatomic,assign,readwrite) CGFloat hpk_left;

@end

@interface UIScrollView (HPKLayout)

@property(nonatomic,assign,readwrite) CGFloat hpk_contentSizeWidth;
@property(nonatomic,assign,readwrite) CGFloat hpk_contentSizeHeight;
@property(nonatomic,assign,readwrite) CGFloat hpk_contentOffsetX;
@property(nonatomic,assign,readwrite) CGFloat hpk_contentOffsetY;

@end

typedef NS_ENUM(NSInteger,HPKComponentState) {
    kHPKComponentStateNone,        //准备区之外
    kHPKComponentStatePrepare,     //在准备区域
    kHPKComponentStateVisible,     //在可视区域
};

@interface NSObject (HPKComponent)
@property(nonatomic, assign, readwrite) HPKComponentState oldState;   //页面滚动复用标志位
@property(nonatomic, assign, readwrite) HPKComponentState newState;   //页面滚动复用标志位
@end
