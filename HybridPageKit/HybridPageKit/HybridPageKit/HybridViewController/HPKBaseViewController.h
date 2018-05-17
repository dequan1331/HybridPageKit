//
//  HPKBaseViewController.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPKDefs.h"

@interface HPKBaseViewController : UIViewController

@property(nonatomic,copy,readwrite)NSArray<HPKController *> *componentControllerArray;

#pragma mark - trigger event
- (void)triggerEvent:(HPKComponentEvent)event;
- (void)triggerEvent:(HPKComponentEvent)event para1:(NSObject *)para1;
- (void)triggerEvent:(HPKComponentEvent)event para1:(NSObject *)para1 para2:(NSObject *)para2;

@end
