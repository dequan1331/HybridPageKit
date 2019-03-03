//
// WebComponentController.m
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


#import "WebComponentController.h"
#import "ArticleModel.h"

@interface WebComponentController ()<WKNavigationDelegate>

@property (nonatomic, strong, readwrite) HPKWebView *webView;

@property (nonatomic, strong, readwrite) ArticleModel *articleModel;
@end

@implementation WebComponentController

- (instancetype)init {
    self = [super init];
    if (self) {
        _webComponentHandler = [[HPKPageHandler alloc] init];
        [_webComponentHandler configWithViewController:self componentsControllers:@[[[VideoController alloc]initWithController:self],
                                                                                    [[GifController alloc]initWithController:self],
                                                                                    [[ImageController alloc]initWithController:self]]];
    }
    return self;
}

- (void)dealloc {
    [[HPKPageManager sharedInstance] enqueueWebView:self.webView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _getRemoteDataAndLoad];
    
    [self.view addSubview:({
        _webView = [[HPKPageManager sharedInstance] dequeueWebViewWithClass:[HPKWebView class] webViewHolder:self];
        _webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navigationController.navigationBar.frame));
        _webView.navigationDelegate = self;
        _webView;
    })];

    [_webComponentHandler handleSingleWebView:_webView webComponentDomClass:@"web-component" webComponentIndexKey:@"component-index"];
}

#pragma mark -

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [_webComponentHandler layoutWithWebComponentModels:self.articleModel.webViewComponents];
}

#pragma mark -

- (void)_getRemoteDataAndLoad {
    __weak typeof(self)wself = self;
    _articleModel = [[ArticleModel alloc] init];
    [_articleModel loadArticleContentWithFinishBlock:^{
        __strong __typeof(wself) strongSelf = wself;
        [strongSelf.webView loadHTMLString:strongSelf.articleModel.contentTemplateString baseURL:nil];
    }];
}

@end
