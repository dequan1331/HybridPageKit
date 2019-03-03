//
// ArticleModel.m
//
// Copyright (c) 2019 dequanzhu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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

@interface ArticleModel ()

@property (nonatomic, copy, readwrite) NSString *articleIdStr;

@property (nonatomic, copy, readwrite) NSString *contentTemplateString;
@property (nonatomic, strong, readwrite) NSArray<HPKModel *> *WebViewComponents;
@property (nonatomic, strong, readwrite) NSArray<HPKModel *> *ExtensionComponents;

@end

@implementation ArticleModel

#pragma mark -

- (void)loadArticleContentWithFinishBlock:(ArticleModelLoadFinishBlock)finishBlock {
    NSDictionary *responseDic = nil;
    NSData *contentData = [[NSFileManager defaultManager] contentsAtPath:[[NSBundle mainBundle] pathForResource:@"articleContent" ofType:@"txt"]];
    id obj = [NSJSONSerialization JSONObjectWithData:contentData options:kNilOptions error:nil];
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        responseDic = (NSDictionary *)obj;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self _parseArticleContentWithDic:responseDic];
        if (finishBlock) {
            finishBlock();
        }
    });
}

#pragma mark -

- (void)_parseArticleContentWithDic:(NSDictionary *)dic {
    _contentTemplateString = [dic objectForKey:@"articleContent"];
    _articleIdStr = [dic objectForKey:@"articleId"];
    [self _parserWebViewComponentWithDic:dic];
    [self _parserNativeComponentWithDic:dic];
}

- (void)_parserNativeComponentWithDic:(NSDictionary *)dic {
    MediaModel *mediaModel = [[MediaModel alloc]initWithDic:[dic objectForKey:@"articleMedia"]];
    _hotCommentModel = [[HotCommentModel alloc]initWithDic:[dic objectForKey:@"articleHotComment"]];
    RelateNewsModel *relateModel = [[RelateNewsModel alloc]initWithDic:[dic objectForKey:@"articleRelateNews"]];
    TitleModel *titleModel = [[TitleModel alloc]initWithDic:[dic objectForKey:@"articleTitle"]];

    _extensionComponents = @[mediaModel, _hotCommentModel, relateModel, titleModel];
}

- (void)_parserWebViewComponentWithDic:(NSDictionary *)dic {
    NSMutableArray<HPKModel *> *tmpArray = @[].mutableCopy;

    dic = [dic objectForKey:@"components"];

    if (!dic || dic.count <= 0) {
        return;
    }

    for (NSString *index in dic.allKeys) {
        NSDictionary *componentValue = [dic objectForKey:index];
        if ([index hasPrefix:@"IMG_"]) {
            ImageModel *imageModel = [[ImageModel alloc]initWithValueDic:componentValue];
            [imageModel setComponentIndex:index];
            [tmpArray addObject:imageModel];
        } else if ([index hasPrefix:@"GIF_"]) {
            GifModel *gifModel = [[GifModel alloc]initWithValueDic:componentValue];
            [gifModel setComponentIndex:index];
            [tmpArray addObject:gifModel];
        } else if ([index hasPrefix:@"VIDEO_"]) {
            VideoModel *videoModel = [[VideoModel alloc]initWithValueDic:componentValue];
            [videoModel setComponentIndex:index];
            [tmpArray addObject:videoModel];
        }
    }

    _webViewComponents = tmpArray.copy;
}

@end
