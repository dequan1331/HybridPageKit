//
//  FoldedModel.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "FoldedModel.h"
#import "FoldedController.h"
#import "FoldedView.h"

@interface FoldedModel ()
@property(nonatomic,copy,readwrite)NSString *index;
@property(nonatomic,assign,readwrite)CGRect frame;
@property(nonatomic,copy,readwrite)NSString *text;
@end

@implementation FoldedModel

HPKProtocolImp(_index,_frame,FoldedView,FoldedController,nil,NO);

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _index = [dic objectForKey:@"index"];
        _text = [dic objectForKey:@"foldedText"];
        _frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kFoldedViewFoldedHeight);
    }
    return self;
}

@end
