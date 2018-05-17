//
//  ArticleApi.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "ArticleApi.h"

@interface ArticleApi()
@property(nonatomic,strong,readwrite) NSURLSessionTask *task;
@end

@implementation ArticleApi

- (instancetype) initWithApiType:(ArticleApiType)type
                 completionBlock:(ArticleApiCompletionBlock)completionBlock{
    self = [super init];
    if (self) {
        
        
        NSData *contentData = [self _getContentStringWithType:type];
        NSDictionary *responseDic = nil;
        
        if (contentData) {
            id obj = [NSJSONSerialization JSONObjectWithData:contentData options:kNilOptions error:nil];
            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                responseDic = (NSDictionary *)obj;
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((type == kArticleApiTypeAD|| type == kArticleApiTypeHotComment)? 0.6f : 0.f) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completionBlock(responseDic,nil);
        });
    }
    return self;
}

- (void)cancel{
    
}

#pragma mark -

- (NSData *)_getContentStringWithType:(ArticleApiType)type{

    NSString *filePath = @"";
    
    if (type == kArticleApiTypeArticle) {
        filePath = [[NSBundle mainBundle] pathForResource:@"articleContent" ofType:@"txt"];
    } else if(type == kArticleApiTypeAD){
        filePath = [[NSBundle mainBundle] pathForResource:@"adContent" ofType:@"txt"];
    } else if(type == kArticleApiTypeHotComment){
        filePath = [[NSBundle mainBundle] pathForResource:@"hotCommentContent" ofType:@"txt"];
    } else if(type == kArticleApiTypeShortArticle){
        filePath = [[NSBundle mainBundle] pathForResource:@"shortArticleContent" ofType:@"txt"];
    }

    return (filePath.length <= 0) ? nil : [[NSFileManager defaultManager] contentsAtPath:filePath];;
}

@end
