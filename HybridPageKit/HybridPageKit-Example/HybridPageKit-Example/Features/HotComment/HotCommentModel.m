//
//  HotCommentModel.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HotCommentModel.h"
#import "HotCommentView.h"
#import "ArticleApi.h"
#import "HotCommentController.h"

@interface HotCommentModel()
@property(nonatomic,copy,readwrite)NSString *index;
@property(nonatomic,copy,readwrite) NSArray * hotCommentArray;
@property(nonatomic,assign,readwrite)CGRect frame;
@property(nonatomic,strong,readwrite)ArticleApi *loadMoreApi;
@property(nonatomic,copy,readwrite)HotCommentModelLoadCompletionBlock completionBlock;
@property(nonatomic,assign,readwrite)BOOL hasMore;

@end
@implementation HotCommentModel

HPKProtocolImp(_index,_frame,HotCommentView,HotCommentController,nil,YES);

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _index = [dic objectForKey:@"index"];
        _hasMore = YES;
        [self setHotComments:[dic objectForKey:@"commentArray"]];
    }
    return self;
}

-(void)dealloc{
    if (_loadMoreApi) {
        [_loadMoreApi cancel];
        _loadMoreApi = nil;
    }
    _completionBlock = nil;
}

-(void)loadMoreHotCommentsWithCompletionBlock:(HotCommentModelLoadCompletionBlock)completionBlock{
    
    if (!completionBlock) {
        return;
    }
    
    if (_loadMoreApi) {
        [_loadMoreApi cancel];
        _loadMoreApi = nil;
    }
    
    _completionBlock = [completionBlock copy];
    
    __weak typeof(self) wself = self;
    _loadMoreApi = [[ArticleApi alloc] initWithApiType:kArticleApiTypeHotComment completionBlock:^(NSDictionary *responseDic, NSError *error) {
        __strong __typeof(wself) strongSelf = wself;
        NSMutableArray *arrayTmp = strongSelf.hotCommentArray.mutableCopy;
        for (NSString * comment in [responseDic objectForKey:@"hotComment"]) {
            [arrayTmp addObject:[NSString stringWithFormat:@"%@ - %@",comment,@(arrayTmp.count + 1)]];
        }
        [strongSelf setHotComments:arrayTmp.copy];
        strongSelf.hasMore = strongSelf.hotCommentArray.count <= 100;
        
        if(strongSelf.completionBlock){
            strongSelf.completionBlock();
        }
    }];
}
#pragma mark -

-(void)setHotComments:(NSArray *)hotComments{
    _hotCommentArray = hotComments;
    _frame = CGRectMake(_frame.origin.x, _frame.origin.y, [UIScreen mainScreen].bounds.size.width, MIN(hotComments.count * kHotCommentViewCellHeight, [UIScreen mainScreen].bounds.size.height - 64));
}

@end
