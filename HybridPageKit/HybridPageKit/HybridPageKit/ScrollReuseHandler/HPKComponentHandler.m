//
//  HPKComponentHandler.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKComponentHandler.h"
#import "HPKComponentViewPool.h"
#import "UIKit + HPK.h"
#import "HPKDealgateDispatcher.h"

@interface HPKComponentHandler()
@property(nonatomic, strong, readwrite) NSDictionary<NSString *, NSObject<HPKModelProtocol> *> *componentItemDic;
@property(nonatomic, strong, readwrite) NSMutableDictionary<NSString *, __kindof UIView *> *dequeueViewsDic;
@property(nonatomic, strong, readwrite) NSMutableArray <__kindof UIView *>* scrollViewSubViews;
@property(nonatomic, copy, readwrite) HPKComponentViewStateChangeBlock changeBlock;
@property(nonatomic, weak, readwrite) __kindof UIScrollView * scrollView;
@property(nonatomic, assign, readwrite) CGFloat componentWorkRange;
@property(nonatomic,readwrite,strong) HPKDealgateDispatcher *delegateDispatcher;
@end

@implementation HPKComponentHandler

- (instancetype)initWithScrollView:(__kindof UIScrollView *)scrollView
        externalScrollViewDelegate:(__weak NSObject <UIScrollViewDelegate>*)externalDelegate
                   scrollWorkRange:(CGFloat)scrollWorkRange
     componentViewStateChangeBlock:(HPKComponentViewStateChangeBlock)componentViewStateChangeBlock{
    self = [super init];
    if (self) {
        _componentItemDic = @{};
        _dequeueViewsDic = @{}.mutableCopy;
        _scrollViewSubViews = @[].mutableCopy;
        _scrollView = scrollView;
        _componentWorkRange = scrollWorkRange;
        _changeBlock = componentViewStateChangeBlock;
        
        _delegateDispatcher = [[HPKDealgateDispatcher alloc] initWithInternalDelegate:self externalDelegate:externalDelegate];
        scrollView.delegate = self.delegateDispatcher;
    }
    return self;
}

-(void)dealloc{
    _componentItemDic = nil;
    _delegateDispatcher = nil;
    
    [_dequeueViewsDic removeAllObjects];
    _dequeueViewsDic = nil;
    
    for (__kindof UIView * subView in self.scrollViewSubViews) {
        [subView removeFromSuperview];
    }
    [_scrollViewSubViews removeAllObjects];
    _scrollViewSubViews = nil;
    
    _changeBlock = nil;
    _scrollView = nil;
}

#pragma mark - public method

- (void)reloadComponentViewsWithProcessBlock:(HPKComponentProcessItemBlock)processBlock{
    
    if ([NSThread isMainThread]) {
        if(processBlock){
            _componentItemDic = [processBlock(_componentItemDic) copy];
        }
        
        [self detailComponentsDidUpdateWithOffsetTop:self.scrollView.contentOffset.y forceLayout:YES];
    }else{
        __weak typeof(self) wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(wself) strongSelf = wself;
            [strongSelf reloadComponentViewsWithProcessBlock:processBlock];
        });
    }
}

#pragma mark - public method

- (NSObject<HPKModelProtocol> *)getComponentItemByUniqueId:(NSString *)uniqueId{
    if (!uniqueId || uniqueId.length <= 0 || !self.componentItemDic || self.componentItemDic.count <= 0) {
        return nil;
    }
    return [self.componentItemDic objectForKey:uniqueId];
}

- (__kindof UIView *)getComponentViewByItem:(NSObject<HPKModelProtocol> *)item{
    if(!item || !self.dequeueViewsDic || self.dequeueViewsDic.count <= 0){
        return nil;
    }
    return [self.dequeueViewsDic objectForKey:[item getUniqueId]];
}

- (NSArray <NSObject<HPKModelProtocol> *> *)getVisiableComponentItems{
    if (!self.componentItemDic || self.componentItemDic.count <= 0) {
        return @[];
    }
    
    return  [self.componentItemDic.allValues objectsAtIndexes:
             [self.componentItemDic.allValues indexesOfObjectsPassingTest:^BOOL(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(HPKModelProtocol)]) {
            return ((NSObject<HPKModelProtocol> *)obj).newState == kHPKComponentStateVisible;
        }
        return NO;
    }]];
    
}

- (NSArray <NSObject<HPKModelProtocol> *> *)getPreparedComponentItems{
    if (!self.componentItemDic || self.componentItemDic.count <= 0) {
        return @[];
    }
    
    return [self.componentItemDic.allValues objectsAtIndexes:
            [self.componentItemDic.allValues indexesOfObjectsPassingTest:^BOOL(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(HPKModelProtocol)]) {
            return ((NSObject<HPKModelProtocol> *)obj).newState == kHPKComponentStatePrepare;
        }
        return NO;
    }]];
}

- (NSArray <NSObject<HPKModelProtocol> *>*)getAllComponentItemsWithorderByOffset:(BOOL)orderByOffset{
    
    if (!self.componentItemDic || self.componentItemDic.count <= 0) {
        return @[];
    }
    
    if(orderByOffset){
        return [self.componentItemDic.allValues sortedArrayUsingComparator:^NSComparisonResult(NSObject<HPKModelProtocol> *item1,
                                                                                               NSObject<HPKModelProtocol> *item2) {
            if ([item1 getComponentFrame].origin.y  < [item2 getComponentFrame].origin.y ){
                return (NSComparisonResult)NSOrderedAscending;
            }else{
                return (NSComparisonResult)NSOrderedDescending;
            }
        }];
    }else{
        return self.componentItemDic.allValues;
    }
}

#pragma mark -

- (void)detailComponentsDidUpdateWithOffsetTop:(CGFloat)offsetTop forceLayout:(BOOL)forceLayout{
    
    
    if (!self.componentItemDic || self.componentItemDic.count <= 0) {
        return;
    }
    
    CGFloat visibleTopLine = offsetTop;
    CGFloat visibleBottomLine = offsetTop + self.scrollView.frame.size.height;
    
    CGFloat preparedTopLine = visibleTopLine - self.componentWorkRange;
    CGFloat preparedBottomLine = visibleBottomLine + self.componentWorkRange;
    
    for (NSObject<HPKModelProtocol> *item in self.componentItemDic.allValues) {
        //in prepare
        if ([item getComponentFrame].origin.y + [item getComponentFrame].size.height > preparedTopLine && [item getComponentFrame].origin.y < preparedBottomLine) {
            //in visible
            if ([item getComponentFrame].origin.y + [item getComponentFrame].size.height > visibleTopLine && [item getComponentFrame].origin.y < visibleBottomLine) {
                item.newState = kHPKComponentStateVisible;
            }else{
                item.newState = kHPKComponentStatePrepare;
            }
        }else{
            item.newState = kHPKComponentStateNone;
        }
    }
    
    for (NSObject<HPKModelProtocol> *item in self.componentItemDic.allValues) {
        if(item.newState == item.oldState){
            if (forceLayout && item.newState != kHPKComponentStateNone) {
                __kindof UIView *view = [self getComponentViewByItem:item];
                view.frame = [item getComponentFrame];
                [self _triggerComponentEvent:kHPKComponentViewReLayoutPreparedAndVisibleComponentView withItem:item];
            }
            continue;
        }
        
        if(item.newState == kHPKComponentStateVisible && item.oldState == kHPKComponentStatePrepare){
            
            [self _triggerComponentEvent:kHPKComponentViewWillDisplayComponentView withItem:item];
            
        }else if (item.newState == kHPKComponentStateVisible && item.oldState == kHPKComponentStateNone){
            
            __kindof UIView *view = [self _dequeueViewOfItem:item];
            [_scrollView addSubview:view];
            [_scrollViewSubViews addObject:view];
            
            [self _triggerComponentEvent:kHPKComponentViewWillPreparedComponentView withItem:item];
            [self _triggerComponentEvent:kHPKComponentViewWillDisplayComponentView withItem:item];
            
            
        }else if (item.newState == kHPKComponentStatePrepare && item.oldState == kHPKComponentStateNone){
            
            [self _dequeueViewOfItem:item];
            __kindof UIView *view = [self _triggerComponentEvent:kHPKComponentViewWillPreparedComponentView withItem:item];
            [_scrollView addSubview:view];
            [_scrollViewSubViews addObject:view];
            
        }else if (item.newState == kHPKComponentStatePrepare && item.oldState == kHPKComponentStateVisible){
            
            [self _triggerComponentEvent:kHPKComponentViewEndDisplayComponentView withItem:item];
            
        }else if (item.newState == kHPKComponentStateNone && item.oldState == kHPKComponentStatePrepare){
            
            [self _triggerComponentEvent:kHPKComponentViewEndPreparedComponentView withItem:item];
            [self _enqueueViewOfItem:item];
            
        }else if (item.newState == kHPKComponentStateNone && item.oldState == kHPKComponentStateVisible){
            
            [self _triggerComponentEvent:kHPKComponentViewEndDisplayComponentView withItem:item];
            [self _triggerComponentEvent:kHPKComponentViewEndPreparedComponentView withItem:item];
            [self _enqueueViewOfItem:item];
            
        }else{
            //never
        }
        
        item.oldState = item.newState;
    }
}


#pragma mark - private method of

- (__kindof UIView *)_dequeueViewOfItem:(NSObject<HPKModelProtocol> *)item{
    
    __kindof UIView *view =  [[HPKComponentViewPool shareInstance]
                              dequeueComponentViewWithIdentifier:[item getUniqueId] viewClass:[item getComponentViewClass]];
    
    view.frame = [item getComponentFrame];
    [view setHPKId:[item getUniqueId]];
    [self.dequeueViewsDic setValue:view forKey:[item getUniqueId]];
    
    return view;
}

- (void)_enqueueViewOfItem:(NSObject<HPKModelProtocol> *)item{
    __kindof UIView *view = [self getComponentViewByItem:item];
    [view removeFromSuperview];
    [view setHPKId:@""];
    [self.dequeueViewsDic removeObjectForKey:[item getUniqueId]];
    [self.scrollViewSubViews removeObject:view];
    [[HPKComponentViewPool shareInstance] enqueueComponentView:view];
    
}

- (__kindof UIView *)_triggerComponentEvent:(HPKComponentViewState)event withItem:(NSObject<HPKModelProtocol> *)item{
    
    if(!item){
        return nil;
    }
    
    __kindof UIView * view = [self getComponentViewByItem:item];
    
    if (_changeBlock) {
        _changeBlock(event,item,view);
    }
    
    return view;
}

#pragma mark -

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self detailComponentsDidUpdateWithOffsetTop:scrollView.contentOffset.y forceLayout:NO];
}
- (void)scrollViewDidScrollTo:(CGFloat)offsetTop {
    [self detailComponentsDidUpdateWithOffsetTop:offsetTop forceLayout:NO];
}

@end
