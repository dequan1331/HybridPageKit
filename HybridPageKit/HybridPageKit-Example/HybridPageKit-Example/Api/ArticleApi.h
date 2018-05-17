//
//  ArticleApi.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ArticleApiType) {
    kArticleApiTypeArticle,
    kArticleApiTypeShortArticle,
    kArticleApiTypeAD,
    kArticleApiTypeHotComment,
};

typedef void (^ArticleApiCompletionBlock)(NSDictionary *responseDic, NSError *error);

@interface ArticleApi : NSObject

- (instancetype) initWithApiType:(ArticleApiType)type
                 completionBlock:(ArticleApiCompletionBlock)completionBlock;

- (void)cancel;

@end
