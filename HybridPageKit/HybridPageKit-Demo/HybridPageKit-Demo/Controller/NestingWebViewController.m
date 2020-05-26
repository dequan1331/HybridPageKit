//
// NestingWebViewController.m
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

#import "NestingWebViewController.h"
#import "ArticleModel.h"
#import "ArticleFeatureDef.h"

@interface NestingWebViewController ()<HPKDefaultWebViewProtocol,UIScrollViewDelegate>
@property (nonatomic, strong, readwrite) ArticleModel *articleModel;
@property (nonatomic, strong, readwrite) UIScrollView *containerScrollView;
@end

@implementation NestingWebViewController

- (instancetype)init {
    return [self initWithUseCustomComparator:NO];
}

- (instancetype)initWithUseCustomComparator:(BOOL)useCustomComparator {
    self = [super init];
    if (self) {
        _componentHandler = [[HPKPageHandler alloc] init];
        if (useCustomComparator) {
            [_componentHandler setCustomComponentModelsComparator:[self _buildCustomComparator]];
        }
        [_componentHandler configWithViewController:self componentsControllers:@[[[VideoController alloc]initWithController:self],
                                                                                 [[GifController alloc]initWithController:self],
                                                                                 [[ImageController alloc]initWithController:self],
                                                                                 [[TitleController alloc]initWithController:self],
                                                                                 [[AdController alloc]initWithController:self],
                                                                                 [[MediaController alloc]initWithController:self],
                                                                                 [[RelateNewsController alloc]initWithController:self],
                                                                                 [[HotCommentController alloc]initWithController:self]]];
    }
    return self;
}

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _getRemoteDataAndLoad];

    [self.view addSubview:({
        _containerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
        _containerScrollView.backgroundColor = [UIColor whiteColor];
        _containerScrollView.delegate = self;
        _containerScrollView;
    })];

    [_componentHandler handleHybridPageWithContainerScrollView:_containerScrollView defaultWebViewClass:[HPKWebView class] defaultWebViewIndex:kHPKDemoComponentIndexWebView webComponentDomClass:@"web-component" webComponentIndexKey:@"component-index"];
    _componentHandler.webView.navigationDelegate = [_componentHandler replaceExtensionDelegateWithOriginalDelegate:self];  
}

#pragma mark -

- (void)_getRemoteDataAndLoad {
    __weak typeof(self)wself = self;
    _articleModel = [[ArticleModel alloc] init];
    [_articleModel loadArticleContentWithFinishBlock:^{
        __strong __typeof(wself) strongSelf = wself;
        [strongSelf.componentHandler.webView loadHTMLString:strongSelf.articleModel.contentTemplateString baseURL:nil];
        [strongSelf.componentHandler triggerBroadcastSelector:@selector(didReceiveArticleContent:) para1:strongSelf.articleModel para2:nil];
    }];
}

- (NSComparator)_buildCustomComparator {
    static NSDictionary<NSString *, NSString *> *sortedIndex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sortedIndex = @{
            @(kHPKDemoComponentIndexAd).stringValue      : @"5",
            @(kHPKDemoComponentIndexRelate).stringValue  : @"3",
            @(kHPKDemoComponentIndexMedia).stringValue   : @"4",
        };
    });
    return ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *index1 = [obj1 isKindOfClass:[NSString class]] ? (NSString *)obj1 : @"";
        NSString *index2 = [obj2 isKindOfClass:[NSString class]] ? (NSString *)obj2 : @"";
        
        index1 = [sortedIndex objectForKey:index1] ?: index1;
        index2 = [sortedIndex objectForKey:index2] ?: index2;
        
        if (index1.integerValue < index2.integerValue) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    };
}

#pragma mark -
- (void)webViewDidFinishNavigation:(WKNavigation *)navigation {
    // custom webviewe delegate
    [_componentHandler layoutWithWebComponentModels:self.articleModel.webViewComponents];
    [_componentHandler layoutWithComponentModels:self.articleModel.extensionComponents];
}
#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_componentHandler triggerBroadcastSelector:@selector(containerScrollViewDidScroll:) para1:scrollView para2:nil];
}

@end
