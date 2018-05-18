//
//  SingleWebViewController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "SingleWebViewController.h"
#import "ArticleApi.h"
#import "ArticleModel.h"
#import "HtmlRenderHandler.h"

@interface SingleWebViewController()<WKNavigationDelegate>
@property(nonatomic,strong,readwrite)ArticleApi *api;
@property(nonatomic,strong,readwrite)ArticleModel *articleModel;
@end

@implementation SingleWebViewController

- (instancetype)init{
    self = [super initWithConfigBuilder:^(HPKViewConfig *defaultConfig) {
        defaultConfig.needWebView = YES;
        defaultConfig.webViewComponentPlaceHolderDomClass = HPKWebViewHandlerComponentClass;
    }];
    if (self) {
        [self _getRemoteData];
    }
    return self;
}

- (void)dealloc{
    if (_api) {
        [_api cancel];
        _api = nil;
    }
}

#pragma mark -
- (NSArray<HPKController *> *)getValidComponentControllers{
    return @[
             [[AdController alloc]init],
             [[VideoController alloc]init],
             [[GifController alloc]init],
             [[ImageController alloc]init],
             [[TitleController alloc]init]
             ];
}

-(void)_getRemoteData{
    __weak typeof(self) wself = self;
    _api = [[ArticleApi alloc]initWithApiType:kArticleApiTypeArticle completionBlock:^(NSDictionary *responseDic, NSError *error) {
        __strong __typeof(wself) strongSelf = wself;
        strongSelf.articleModel = [[ArticleModel alloc]initWithDic:responseDic];
        [strongSelf _renderAndLoadData];
    }];
}

- (void)_renderAndLoadData{
    __weak typeof(self) wself = self;
    [[HtmlRenderHandler shareInstance] asyncRenderHTMLString:self.articleModel.contentTemplateString
                                              componentArray:self.articleModel.webViewComponents
                                               completeBlock:^(NSString *finalHTMLString, NSError *error) {
        __strong __typeof(wself) strongSelf = wself;
        [strongSelf setArticleDetailModel:strongSelf.articleModel
                             htmlTemplate:finalHTMLString
                  webviewExternalDelegate:strongSelf
                        webViewComponents:strongSelf.articleModel.webViewComponents
                      extensionComponents:nil];
    }];
}

#pragma mark -
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    // custom webviewe delegate
}
@end
