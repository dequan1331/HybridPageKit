//
//  AdController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "AdController.h"
#import "HPKAbstractViewController.h"
#import "ArticleModel.h"
#import "HPKWebViewHandler.h"
#import "AdModel.h"
#import "AdView.h"

@interface AdController()
@property(nonatomic,weak,readwrite) __kindof HPKAbstractViewController *controller;
@property(nonatomic,weak,readwrite) __kindof HPKWebView *webView;
@property(nonatomic,weak,readwrite)AdModel *adModel;
@end

@implementation AdController
-(BOOL)shouldResponseWithComponentView:(__kindof UIView *)componentView
                         componentModel:(HPKModel *)componentModel{
    return [componentView class] == [AdView class] && [componentModel class] == [AdModel class];
}

- (void)controllerInit:(__kindof HPKAbstractViewController *)controller{
    _controller = controller;
}

//data
- (void)controller:(__kindof HPKAbstractViewController *)controller
    didReceiveData:(NSObject *)data{
    
    if([data isKindOfClass:[ArticleModel class]]){
        for (NSObject *component in ((ArticleModel *)data).webViewComponents) {
            if ([component isKindOfClass:[AdModel class]]) {
                self.adModel = (AdModel *)component;
                break;
            }
        }
    }  
}

//webview
- (void)webViewDidFinishNavigation:(__kindof HPKWebView *)webView{
    _webView = webView;
}

//component scroll
- (void)scrollViewWillDisplayComponentView:(__kindof UIView *)componentView
                            componentModel:(HPKModel *)componentModel{
    [((AdView *)componentView) layoutWithData:(AdModel *)componentModel];
}

- (void)scrollViewRelayoutComponentView:(__kindof UIView *)componentView
                         componentModel:(HPKModel *)componentModel{
    [((AdView *)componentView) layoutWithData:(AdModel *)componentModel];
}

- (void)scrollViewWillPrepareComponentView:(__kindof UIView *)componentView
                            componentModel:(HPKModel *)componentModel{
    
    __weak typeof(self) wself = self;
    [self.adModel getAsyncDataWithCompletionBlock:^{
        //异步获取数据后更新布局
        __strong __typeof(wself) strongSelf = wself;
        [strongSelf.controller reLayoutWebViewComponentsWithIndex:strongSelf.adModel.index componentSize:strongSelf.adModel.frame.size];
    }];
}

@end
