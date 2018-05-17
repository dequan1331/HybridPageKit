//
//  HPKBaseViewController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKAbstractViewController.h"

@implementation HPKBaseViewController

-(void)dealloc{
    _componentControllerArray = nil;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self triggerEvent:kHPKComponentEventControllerViewDidLoad];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self triggerEvent:kHPKComponentEventControllerViewWillAppear];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self triggerEvent:kHPKComponentEventControllerViewDidAppear];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self triggerEvent:kHPKComponentEventControllerViewWillDisappear];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self triggerEvent:kHPKComponentEventControllerViewDidDisappear];
}


#pragma mark -

- (void)triggerEvent:(HPKComponentEvent)event {
    [self triggerEvent:event para1:nil];
}
- (void)triggerEvent:(HPKComponentEvent)event para1:(NSObject *)para1{
    [self triggerEvent:event para1:para1 para2:nil];
}
- (void)triggerEvent:(HPKComponentEvent)event para1:(NSObject *)para1 para2:(NSObject *)para2{
    
    SEL protocolSelector = _getHPKComponentControllerDelegateByEventType(event);
    if (!protocolSelector) {
        NSAssert(NO, @"HPKAbstractViewController trigger invalid event:%@", @(event));
        return;
    }
    
    BOOL isComponentScrollEvent = event > kHPKComponentScrollEventIndexBegin && event < kHPKComponentScrollEventIndexEnd;
    
    for (__kindof HPKController *component in _componentControllerArray) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (isComponentScrollEvent) {
            SEL sel = @selector(shouldResponseWithComponentView:componentModel:);
            if([component respondsToSelector:sel] && ![component performSelector:sel withObject:para1 withObject:para2]){
                continue;
            }
        }
        if ([component respondsToSelector:protocolSelector]) {
            [component performSelector:protocolSelector withObject:para1 withObject:para2];
        }
#pragma clang diagnostic pop
    }
}

@end
