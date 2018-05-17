//
//  TitleModel.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//
#import "HPKModelProtocol.h"

@interface TitleModel : NSObject <HPKModelProtocol>
@property(nonatomic,copy,readonly)NSString *title;

- (instancetype)initWithDic:(NSDictionary *)dic;
@end
