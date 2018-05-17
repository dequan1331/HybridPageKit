//
//  TitleModel.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "TitleModel.h"
#import "TitleView.h"
#import "TitleController.h"

@interface TitleModel ()
@property(nonatomic,copy,readwrite)NSString *title;
@property(nonatomic,copy,readwrite)NSString *index;
@property(nonatomic,assign,readwrite)CGRect frame;
@end
@implementation TitleModel

HPKProtocolImp(_index,_frame,TitleView,TitleController,nil,NO);

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _title = [dic objectForKey:@"title"];
        _index = [dic objectForKey:@"index"];
        _frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTitleViewHeight);
    }
    return self;
}

@end
