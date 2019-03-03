//
// NestingBannerController.m
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

#import "NestingBannerController.h"
#import "ArticleModel.h"

@interface NestingBannerController ()<UIScrollViewDelegate>
@property (nonatomic, strong, readwrite) UILabel *bannerView;
@property (nonatomic, strong, readwrite) UIScrollView *containerScrollView;
@property (nonatomic, strong, readwrite) ArticleModel *articleModel;
@end

@implementation NestingBannerController
- (instancetype)init {
    self = [super init];
    if (self) {
        _componentHandler = [[HPKPageHandler alloc] init];
        [_componentHandler configWithViewController:self componentsControllers:@[[[AdController alloc]initWithController:self],
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

    [self.view addSubview:({
        _bannerView  = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200.f)];
        _bannerView.backgroundColor = [UIColor whiteColor];
        _bannerView.textAlignment = NSTextAlignmentCenter;
        _bannerView.numberOfLines = 0;
        _bannerView.font = [UIFont systemFontOfSize:40.f];
        _bannerView.text = @"HybridPageKit \n BannerView";
        _bannerView.textColor = [UIColor colorWithRed:28.f / 255.f green:135.f / 255.f blue:219.f / 255.f alpha:1.f];
        [_bannerView.layer addSublayer:({
            CALayer *bottomLine = [[CALayer alloc]init];
            bottomLine.frame = CGRectMake(0, _bannerView.bounds.size.height - 1, _bannerView.bounds.size.width, 1.f);
            bottomLine.backgroundColor = [UIColor lightGrayColor].CGColor;
            bottomLine;
        })];
        _bannerView;
    })];

    [self.view addSubview:({
        _containerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_bannerView.frame), self.view.bounds.size.width, self.view.bounds.size.height - _bannerView.frame.size.height - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
        _containerScrollView.backgroundColor = [UIColor whiteColor];
        _containerScrollView.delegate = self;
        _containerScrollView;
    })];

    [self _getRemoteDataAndLoad];
    
    [_componentHandler handleSingleScrollView:_containerScrollView];
}
#pragma mark -

- (void)_getRemoteDataAndLoad {
    __weak typeof(self)wself = self;
    _articleModel = [[ArticleModel alloc] init];
    [_articleModel loadArticleContentWithFinishBlock:^{
        __strong __typeof(wself) strongSelf = wself;
        [strongSelf.componentHandler triggerBroadcastSelector:@selector(didReceiveArticleContent:) para1:strongSelf.articleModel para2:nil];
        [strongSelf.componentHandler layoutWithComponentModels:strongSelf.articleModel.extensionComponents];
    }];
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_componentHandler triggerBroadcastSelector:@selector(containerScrollViewDidScroll:) para1:scrollView para2:nil];
}

@end
