//
//  HPKComponentViewPool.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKComponentViewPool.h"
#import "UIKit + HPK.h"

@interface HPKComponentViewPool ()

@property(nonatomic,strong,readwrite)dispatch_semaphore_t lock;
@property(nonatomic,strong,readwrite)NSMutableDictionary<NSString *,NSMutableSet< __kindof UIView *> *> *dequeueViews;
@property(nonatomic,strong,readwrite)NSMutableDictionary<NSString *,NSMutableSet< __kindof UIView *> *> *enqueueViews;

@end

@implementation HPKComponentViewPool

+ (HPKComponentViewPool *)shareInstance {
    static dispatch_once_t once;
    static HPKComponentViewPool *componentPool = nil;
    dispatch_once(&once,^{
        componentPool = [[HPKComponentViewPool alloc] init];
    });
    return componentPool;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        _dequeueViews = @{}.mutableCopy;
        _enqueueViews = @{}.mutableCopy;
        _lock = dispatch_semaphore_create(1);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearAllReusableComponentViews)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.dequeueViews removeAllObjects];
    [self.enqueueViews removeAllObjects];
    self.dequeueViews = nil;
    self.enqueueViews = nil;
}
#pragma mark - public method

- (__kindof UIView *)dequeueComponentViewWithIdentifier:(NSString*)identifier
                                              viewClass:(Class)viewClass{
    
    if(![viewClass isSubclassOfClass:[UIView class]]){
        NSAssert(NO, @"HPKComponentViewPool dequeue invalid view class:%@",viewClass);
    }
    
    __kindof UIView *dequeueView = [self _getViewOfClass:viewClass];
    [dequeueView setHPKId:identifier];
    return dequeueView;
}

- (void)enqueueComponentView:(__kindof UIView *)componentView{
    
    if(!componentView){
        return;
    }
    [componentView removeFromSuperview];
    [componentView setHPKId:@""];
    [self _recycleView:componentView];
}


- (void)clearAllReusableComponentViews{
    
    //auto recycle
    [self _tryCompactWeakSuperView:nil];
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_enqueueViews removeAllObjects];
    dispatch_semaphore_signal(_lock);
}

- (void)enqueueAllComponentViewOfSuperView:(__kindof UIView *)superView{
    [self _tryCompactWeakSuperView:superView];
}

- (NSDictionary *)getDequeueViewsDic{
    return self.dequeueViews.copy;
}
- (NSDictionary *)getEnqueueViewsDic{
    return self.enqueueViews.copy;
}

#pragma mark - private method

- (void)_tryCompactWeakSuperView:(__kindof UIView*)superView {
    
    NSDictionary *dequeueViewsTmp = _dequeueViews.copy;
    if(dequeueViewsTmp && dequeueViewsTmp.count > 0){
        for (NSMutableSet *viewSet in dequeueViewsTmp.allValues) {
            NSSet *viewSetTmp = viewSet.copy;
            for (__kindof UIView *view in viewSetTmp) {
                if(view.superview == superView || !view.superview){
                    [view setFrame:CGRectZero];
                    [view setHPKId:@""];
                    [view removeFromSuperview];
                    [self _recycleView:view];
                }
            }
        }
    }
}

-(void)_recycleView:(__kindof UIView *)view{
    
    NSString *classStr = NSStringFromClass(view.class);
    
    if (!classStr || classStr.length <= 0) {
        return;
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if([[_dequeueViews allKeys] containsObject:classStr]){
        NSMutableSet *viewSet =  [_dequeueViews objectForKey:classStr];
        [viewSet removeObject:view];
    }else{
        dispatch_semaphore_signal(_lock);
        NSAssert(NO, @"HPKComponentViewPool recycle invalid view");
    }
    
    if([[_enqueueViews allKeys] containsObject:classStr]){
        
        NSMutableSet *viewSet =  [_enqueueViews objectForKey:classStr];
        
        if(viewSet.count < HPKComponentViewPoolMaxResuableCount){
            [viewSet addObject:view];
        }else{
        }
    }else{
        NSMutableSet *viewSet = [[NSSet set] mutableCopy];
        [viewSet addObject:view];
        [_enqueueViews setValue:viewSet forKey:classStr];
    }
    
    dispatch_semaphore_signal(_lock);
}

-(__kindof UIView *)_getViewOfClass:(Class)viewClass{
    
    __kindof UIView * view;
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    NSString *classStr = NSStringFromClass(viewClass);
    
    if (!classStr || classStr.length <= 0) {
        dispatch_semaphore_signal(_lock);
        return nil;
    }
    
    if([[_enqueueViews allKeys] containsObject:classStr]){
        NSMutableSet *viewSet =  [_enqueueViews objectForKey:classStr];
        if (viewSet && viewSet.count > 0) {
            view = [viewSet anyObject];
            [viewSet removeObject:view];
        }
    }
    
    if(!view){
        view = [[viewClass alloc] initWithFrame:CGRectZero];
    }
    
    if([[_dequeueViews allKeys] containsObject:classStr]){
        NSMutableSet *viewSet =  [_dequeueViews objectForKey:classStr];
        [viewSet addObject:view];
    }else{
        NSMutableSet *viewSet = [[NSSet set] mutableCopy];
        [viewSet addObject:view];
        [_dequeueViews setValue:viewSet forKey:classStr];
    }
    dispatch_semaphore_signal(_lock);
    
    return view;
}
@end

