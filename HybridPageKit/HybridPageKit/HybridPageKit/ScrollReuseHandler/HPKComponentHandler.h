//
//  HPKComponentHandler.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPKModelProtocol.h"

typedef NS_ENUM(NSInteger, HPKComponentViewState) {
    kHPKComponentViewWillPreparedComponentView,
    kHPKComponentViewWillDisplayComponentView,
    kHPKComponentViewEndDisplayComponentView,
    kHPKComponentViewEndPreparedComponentView,
    kHPKComponentViewReLayoutPreparedAndVisibleComponentView
};

typedef void (^HPKComponentViewStateChangeBlock)(HPKComponentViewState state ,NSObject<HPKModelProtocol> *componentItem ,__kindof UIView * componentView);

typedef NSDictionary<NSString *,NSObject<HPKModelProtocol> *> * (^HPKComponentProcessItemBlock)(NSDictionary<NSString *,NSObject<HPKModelProtocol> *> * componentItemDic);

@interface HPKComponentHandler : NSObject<UIScrollViewDelegate>

- (instancetype)initWithScrollView:(__kindof UIScrollView *)scrollView
        externalScrollViewDelegate:(__weak NSObject <UIScrollViewDelegate>*)externalDelegate
                   scrollWorkRange:(CGFloat)scrollWorkRange
     componentViewStateChangeBlock:(HPKComponentViewStateChangeBlock)componentViewStateChangeBlock;

- (void)reloadComponentViewsWithProcessBlock:(HPKComponentProcessItemBlock)processBlock;

#pragma mark -

- (NSObject<HPKModelProtocol> *)getComponentItemByUniqueId:(NSString *)uniqueId;
- (__kindof UIView *)getComponentViewByItem:(NSObject<HPKModelProtocol> *)item;

- (NSArray <NSObject<HPKModelProtocol> *>*)getAllComponentItemsWithorderByOffset:(BOOL)orderByOffset;
- (NSArray <NSObject<HPKModelProtocol> *>*)getVisiableComponentItems;        //返回visible的ComponentItem
- (NSArray <NSObject<HPKModelProtocol> *>*)getPreparedComponentItems;        //返回prepared的ComponentItem

@end
