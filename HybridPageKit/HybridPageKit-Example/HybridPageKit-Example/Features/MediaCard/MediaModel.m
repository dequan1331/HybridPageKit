//
//  MediaModel.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "MediaModel.h"
#import "MediaView.h"
#import "MediaController.h"

@interface MediaModel()
@property(nonatomic,copy,readwrite)NSString *index;
@property(nonatomic,copy,readwrite)NSString *mediaId;
@property(nonatomic,copy,readwrite)NSString *mediaIcon;
@property(nonatomic,copy,readwrite)NSString *mediaName;
@property(nonatomic,copy,readwrite)NSString *mediaDes;
@property(nonatomic,assign,readwrite)CGRect frame;
@end
@implementation MediaModel

HPKProtocolImp(_index,_frame,MediaView,MediaController,nil,NO);

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _index = [dic objectForKey:@"index"];
        _mediaId = [dic objectForKey:@"mediaId"];
        _mediaIcon = [dic objectForKey:@"mediaIcon"];
        _mediaName = [dic objectForKey:@"mediaName"];
        _mediaDes = [dic objectForKey:@"mediaDescribe"];

        _frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100.f);
    }
    return self;
}
@end
