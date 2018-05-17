//
//  HPKViewConfig.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKViewConfig.h"

@implementation HPKViewConfig
- (instancetype)init{
    self = [super init];
    if (self) {
        _lastReadPostion = 0.f;
        _componentsGap = 10.f;
        _scrollWaitMaxRunloops = 50.f;
        _scrollWorkRange = [UIScreen mainScreen].bounds.size.height/2;
    }
    return self;
}
@end
