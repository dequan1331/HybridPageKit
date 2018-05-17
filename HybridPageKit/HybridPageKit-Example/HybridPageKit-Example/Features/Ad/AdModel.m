//
//  AdModel.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "AdModel.h"
#import "AdView.h"
#import "ArticleApi.h"
#import "AdController.h"

@interface AdModel ()
@property(nonatomic,copy,readwrite)NSString *index;
@property(nonatomic,copy,readwrite)NSString *imageUrl;
@property(nonatomic,copy,readwrite)NSString *title;
@property(nonatomic,copy,readwrite)NSString *desc;
@property(nonatomic,assign,readwrite)CGRect frame;
@property(nonatomic,copy,readwrite)AdModelLoadCompletionBlock completionBlock;
@property(nonatomic,strong,readwrite)ArticleApi *adApi;
@end

@implementation AdModel

HPKProtocolImp(_index,_frame,AdView,AdController,nil,NO);

- (instancetype)initWithIndex:(NSString *)index valueDic:(NSDictionary *)valueDic{
    self = [super init];
    if (self) {
        _index = index;
    }
    return self;
}

-(void)dealloc{
    if (_adApi) {
        [_adApi cancel];
        _adApi = nil;
    }
    _completionBlock = nil;
}

- (void)getAsyncDataWithCompletionBlock:(AdModelLoadCompletionBlock)completionBlock{
    
    if (!completionBlock) {
        return;
    }
    
    if (_adApi) {
        [_adApi cancel];
        _adApi = nil;
    }
    
    _completionBlock = [completionBlock copy];
    
    __weak typeof(self) wself = self;
    _adApi = [[ArticleApi alloc]initWithApiType:kArticleApiTypeAD completionBlock:^(NSDictionary *responseDic, NSError *error) {
        __strong __typeof(wself) strongSelf = wself;
        strongSelf.title = [responseDic objectForKey:@"title"];
        strongSelf.imageUrl = [responseDic objectForKey:@"image"];
        strongSelf.desc = [responseDic objectForKey:@"subTitle"];
        strongSelf.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [AdView getAdViewHeightWithModel:self]);
        
        if (strongSelf.completionBlock) {
            strongSelf.completionBlock();
        }
    }];
}

@end
