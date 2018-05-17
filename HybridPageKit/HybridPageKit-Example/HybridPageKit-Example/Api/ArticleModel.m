//
//  ArticleModel.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "ArticleModel.h"
#import "MediaModel.h"
#import "TitleModel.h"
#import "ImageModel.h"
#import "GifModel.h"
#import "VideoModel.h"
#import "AdModel.h"
#import "HotCommentModel.h"
#import "RelateNewsModel.h"
#import "FoldedModel.h"

@interface ArticleModel()

@property(nonatomic,copy,readwrite)NSString *articleIdStr;

//template
@property(nonatomic,copy,readwrite)NSString *contentTemplateString;

//component
@property(nonatomic,strong,readwrite)NSArray<HPKModel *> *WebViewComponents;
@property(nonatomic,strong,readwrite)NSArray<HPKModel *> *ExtensionComponents;


@end

@implementation ArticleModel

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _contentTemplateString = [dic objectForKey:@"articleContent"];
        _articleIdStr = [dic objectForKey:@"articleId"];
                
        [self _parserWebViewComponentWithDic:dic];
        
        _extensionComponents = @[[[MediaModel alloc]initWithDic:[dic objectForKey:@"articleMedia"]],
                                  [[HotCommentModel alloc]initWithDic:[dic objectForKey:@"articleHotComment"]],
                                  [[RelateNewsModel alloc]initWithDic:[dic objectForKey:@"articleRelateNews"]],
                                  [[FoldedModel alloc]initWithDic:[dic objectForKey:@"articleFoldedInfo"]]];
    }
    return self;
}

#pragma mark -

-(void)_parserWebViewComponentWithDic:(NSDictionary *)dic{

    NSMutableArray<HPKModel *> *tmpArray = @[].mutableCopy;
    
    [tmpArray addObject:[[TitleModel alloc]initWithDic:[dic objectForKey:@"articleTitle"]]];
    
    dic = [dic objectForKey:@"articleAttributes"];
    
    if (!dic || dic.count <= 0) {
        return;
    }
    

    for (NSString *index in dic.allKeys) {
        NSDictionary *componentValue = [dic objectForKey:index];
        if ([index hasPrefix:@"IMG_"]) {
            [tmpArray addObject:[[ImageModel alloc]initWithIndex:index valueDic:componentValue]];
        }else if([index hasPrefix:@"GIF_"]){
            [tmpArray addObject:[[GifModel alloc]initWithIndex:index valueDic:componentValue]];
        }else if([index hasPrefix:@"VIDEO_"]){
            [tmpArray addObject:[[VideoModel alloc]initWithIndex:index valueDic:componentValue]];
        }else if([index hasPrefix:@"AD_"]){
            [tmpArray addObject:[[AdModel alloc] initWithIndex:index valueDic:componentValue]];
        }else if ([index hasPrefix:@"Title"]){
            //[tmpDic setObject:[[TitleModel alloc] initWithIndex:index valueDic:componentValue] forKey:index];
        }
    }
    
    _webViewComponents = tmpArray.copy;
}

@end
