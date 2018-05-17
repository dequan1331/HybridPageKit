//
//  RelateNewsModel.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "RelateNewsModel.h"
#import "RelateNewsView.h"
#import "RelateNewsController.h"

@interface RelateNewsModel()
@property(nonatomic,copy,readwrite) NSArray * relateNewsArray;
@property(nonatomic,assign,readwrite)CGRect frame;
@property(nonatomic,copy,readwrite)NSString *index;
@end
@implementation RelateNewsModel

HPKProtocolImp(_index,_frame,RelateNewsView,RelateNewsController,nil,NO);

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _index = [dic objectForKey:@"index"];
        _relateNewsArray = [dic objectForKey:@"newsArray"];
        _frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _relateNewsArray.count * kRelateNewsViewCellHeight);
    }
    return self;
}

@end
