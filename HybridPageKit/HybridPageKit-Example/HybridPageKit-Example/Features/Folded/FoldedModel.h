//
//  FoldedModel.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

@interface FoldedModel : NSObject<HPKModelProtocol>

@property(nonatomic,copy,readonly)NSString *index;
@property(nonatomic,copy,readonly)NSString *text;

- (instancetype)initWithDic:(NSDictionary *)dic;
@end
