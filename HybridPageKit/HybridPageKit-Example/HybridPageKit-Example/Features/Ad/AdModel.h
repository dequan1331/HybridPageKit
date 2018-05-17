//
//  AdModel.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

typedef void (^AdModelLoadCompletionBlock)(void);

@interface AdModel : NSObject<HPKModelProtocol>
@property(nonatomic,copy,readonly)NSString *index;
@property(nonatomic,copy,readonly)NSString *imageUrl;
@property(nonatomic,copy,readonly)NSString *title;
@property(nonatomic,copy,readonly)NSString *desc;
@property(nonatomic,assign,readonly)CGRect frame;

- (instancetype)initWithIndex:(NSString *)index valueDic:(NSDictionary *)valueDic;

- (void)getAsyncDataWithCompletionBlock:(AdModelLoadCompletionBlock)completionBlock;

@end
