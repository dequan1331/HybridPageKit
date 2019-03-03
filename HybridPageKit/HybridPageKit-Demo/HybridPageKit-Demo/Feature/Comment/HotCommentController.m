//
// HotCommentController.m
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

#import "HotCommentController.h"
#import "ArticleModel.h"

#import "HotCommentModel.h"
#import "HotCommentView.h"

@interface HotCommentController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign, readwrite)CGFloat lastLoadContentSizeHeight;
@property (nonatomic, strong, readwrite)HotCommentView *hotCommentView;
@property (nonatomic, weak, readwrite) HotCommentModel *hotCommentModel;

@end

@implementation HotCommentController

- (void)dealloc{
    if (_hotCommentView) {
        [_hotCommentView removeObserver:self forKeyPath:@"contentSize"];
    }
}

#pragma mark -

- (nullable NSArray<Class> *)supportComponentModelClass {
    return @[[HotCommentModel class]];
}

- (nullable HPKView *)unReusableComponentViewWithModel:(HPKModel *)componentModel {
    if (!_hotCommentView) {
        _hotCommentView = [[HotCommentView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
        _hotCommentView.delegate = self;
        _hotCommentView.dataSource = self;
        [_hotCommentView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self.hotCommentView;
}

- (void)didReceiveArticleContent:(ArticleModel *)articleModel{
    _hotCommentModel = articleModel.hotCommentModel;
}

- (void)webViewDidShow:(__kindof HPKWebView *)webView {
    // 如果是单独接口异步加载评论，在此执行
    // 防止接口和布局影响webview渲染，提高内容页展示速度
}

//component scroll
- (void)scrollViewWillPrepareComponentView:(HPKView *)componentView
                            componentModel:(HPKModel *)componentModel {
    [_hotCommentView layoutWithData:_hotCommentModel];
}

- (void)containerScrollViewDidScroll:(UIScrollView *)containerScrollView{
    //底部评论预加载
    CGFloat preloadThreshold = [UIScreen mainScreen].bounds.size.height /3;
    if (_lastLoadContentSizeHeight < containerScrollView.contentSize.height && containerScrollView.contentSize.height - containerScrollView.contentOffset.y - containerScrollView.frame.size.height < preloadThreshold) {
        __weak typeof(self)wself = self;
        [_hotCommentModel loadMoreHotCommentsWithCompletionBlock:^{
            __strong __typeof(wself) strongSelf = wself;
            [strongSelf.hotCommentView layoutWithData:strongSelf.hotCommentModel];
        }];
        _lastLoadContentSizeHeight = containerScrollView.contentSize.height;
    }
}

#pragma mark -

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",[_hotCommentModel.hotCommentArray objectAtIndex:row],@(row)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 50.f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 5)];
    view.backgroundColor = [UIColor colorWithRed:234.f / 255.f green:234.f / 255.f blue:234.f / 255.f alpha:1.f];
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIActivityIndicatorView *indicatorView  = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    [indicatorView startAnimating];
    [view addSubview:indicatorView];
    
    return view;
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _hotCommentModel.hotCommentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotCommentView"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"HotCommentView"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    [self.pageHandler relayoutWithComponentChange];
}

@end
