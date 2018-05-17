//
//  HotCommentController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HotCommentController.h"
#import "ArticleModel.h"
#import "HPKAbstractViewController.h"
#import "HotCommentModel.h"
#import "HotCommentView.h"

@interface HotCommentController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,weak,readwrite) __kindof HPKAbstractViewController *controller;
@property(nonatomic,weak,readwrite)HotCommentModel *hotCommentModel;
@property(nonatomic,weak,readwrite)HotCommentView *hotCommentView;

@end

@implementation HotCommentController

- (void)pullToRefresh{
    __weak typeof(self) wself = self;
    [self.hotCommentModel loadMoreHotCommentsWithCompletionBlock:^{
        __strong __typeof(wself) strongSelf = wself;
        [strongSelf.hotCommentView reloadData];
        [strongSelf.controller reLayoutExtensionComponents];
        [strongSelf.hotCommentView stopRefreshLoadingWithMoreData:strongSelf.hotCommentModel.hasMore];
    }];
}

#pragma mark -
-(BOOL)shouldResponseWithComponentView:(__kindof UIView *)componentView
                         componentModel:(HPKModel *)componentModel{
    return [componentView class] == [HotCommentView class] && [componentModel class] == [HotCommentModel class];
}

- (void)controllerInit:(__kindof HPKAbstractViewController *)controller{
    _controller = controller;
}

//data
- (void)controller:(__kindof HPKAbstractViewController *)controller
    didReceiveData:(NSObject *)data{
    if([data isKindOfClass:[ArticleModel class]]){
        for (NSObject *component in ((ArticleModel *)data).extensionComponents) {
            if ([component isKindOfClass:[HotCommentModel class]]) {
                self.hotCommentModel = (HotCommentModel *)component;
                break;
            }
        }
    }
}

- (void)webViewDidShow:(__kindof HPKWebView *)webView{
    // 如果是单独接口异步加载评论，在此执行
    // 防止接口和布局影响webview渲染，提高内容页展示速度
}

//component scroll
- (void)scrollViewWillDisplayComponentView:(__kindof UIView *)componentView
                            componentModel:(HPKModel *)componentModel{
    _hotCommentView = (HotCommentView *)componentView;
    _hotCommentView.delegate = self;
    _hotCommentView.dataSource = self;
    __weak typeof(self) wself = self;
    [((HotCommentView *)componentView) layoutWithData:(HotCommentModel *)componentModel setPullBlock:^{
        __strong __typeof(wself) strongSelf = wself;
        [strongSelf pullToRefresh];
    }];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.textLabel.text = [_hotCommentModel.hotCommentArray objectAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kHotCommentViewCellHeight;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _hotCommentModel.hotCommentArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotCommentView"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"HotCommentView"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

@end
