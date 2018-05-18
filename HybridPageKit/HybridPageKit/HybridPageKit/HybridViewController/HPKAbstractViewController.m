//
//  HPKAbstractViewController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKAbstractViewController.h"
#import "HPKWebViewHandler.h"
#import "HPKContainerScrollView.h"
#import "HPKComponentHandler.h"
#import "HPKJavascriptUtils.h"
#import "UIKit + HPK.h"

@interface HPKAbstractViewController()<WKNavigationDelegate,UIScrollViewDelegate>
//container view
@property(nonatomic,strong,readwrite)HPKContainerScrollView *containerScrollView;
@property(nonatomic,strong,readwrite)HPKComponentHandler *containerViewScrollViewhandler;
@property(nonatomic,copy,readwrite)NSArray<HPKModel *> *sortedExtensionComponents;
//webview
@property(nonatomic,assign,readwrite)BOOL needWebView;
@property(nonatomic,strong,readwrite)HPKWebViewHandler *webViewHandler;
@property(nonatomic,strong,readwrite)HPKComponentHandler *webViewScrollViewhandler;
@property(nonatomic,copy,readwrite)NSArray<HPKModel *> *webViewComponents;

@property(nonatomic,assign,readwrite)CGFloat topInsetOffset;
@property(nonatomic,assign,readwrite)CGFloat bottomViewOriginY;
@property(nonatomic,assign,readwrite)CGFloat componentsOffsetY;

@property(nonatomic,strong,readwrite) HPKViewConfig *viewConfig;
@end

@implementation HPKAbstractViewController

- (instancetype)initWithConfigBuilder:(HPKViewConfigBuilderBlock)viewConfigBuilder{
    self = [super init];
    if (self) {
        self.componentControllerArray = [self getValidComponentControllers];
        _viewConfig = [[HPKViewConfig alloc] init];
        if(viewConfigBuilder){
            viewConfigBuilder(_viewConfig);
        }
        _needWebView = (_viewConfig.needWebView) ? YES : NO;
        _topInsetOffset = 0.f;
        _bottomViewOriginY = 0.f;
        _componentsOffsetY = 0.f;
        
        [self triggerEvent:kHPKComponentEventControllerInit para1:self];
    }
    return self;
}

-(void)dealloc{
    
    if (_needWebView) {
        _webViewScrollViewhandler = nil;
        _webViewComponents = nil;
    }
    _containerViewScrollViewhandler = nil;
    _containerScrollView = nil;
    _sortedExtensionComponents = nil;
}


#pragma mark -

- (NSArray<HPKController *> *)getValidComponentControllers{
    return @[];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.view addSubview:({
        __weak typeof(self) wself = self;
        
        // container scrollview 嵌套滚动处理
        _containerScrollView = [[HPKContainerScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64) layoutBlock:^{
            __strong __typeof(wself) strongSelf = wself;
            [strongSelf _handleTopWebViewScroll];
            [strongSelf _handleBottomScrollViewScroll];
        }];
        
        // container scrollview上组件滚动复用处理
        _containerViewScrollViewhandler = [[HPKComponentHandler alloc]initWithScrollView:_containerScrollView externalScrollViewDelegate:self scrollWorkRange:0.f componentViewStateChangeBlock: ^(HPKComponentViewState state, HPKModel *componentItem, __kindof UIView *componentView) {
            __strong __typeof(wself) strongSelf = wself;
            [strongSelf _triggerComponentEventWithState:state componentItem:componentItem componentView:componentView];
        }];
        _containerScrollView;
    })];
    
    if (_needWebView) {
        [_containerScrollView addSubview:({
            _webViewHandler = [[HPKWebViewHandler alloc] initWithController:self webViewFrame:CGRectMake(0, 0, _containerScrollView.bounds.size.width, _containerScrollView.bounds.size.height)];
            _webViewHandler.webView;
        })];
        
        // webView上Native组件滚动复用处理
        __weak typeof(self) wself = self;
        _webViewScrollViewhandler = [[HPKComponentHandler alloc]initWithScrollView:_webViewHandler.webView.scrollView externalScrollViewDelegate:nil scrollWorkRange:self.viewConfig.scrollWorkRange componentViewStateChangeBlock:^(HPKComponentViewState state, HPKModel *componentItem, __kindof UIView *componentView) {
            __strong __typeof(wself) strongSelf = wself;
            [strongSelf _triggerComponentEventWithState:state componentItem:componentItem componentView:componentView];
        }];
    }
}

#pragma mark -

// hybrid view controller
- (void)setArticleDetailModel:(NSObject *)model
                 htmlTemplate:(NSString *)htmlTemplate
      webviewExternalDelegate:(id<WKNavigationDelegate>)externalDelegate
            webViewComponents:(NSArray<HPKModel *> *)webViewComponents
          extensionComponents:(NSArray<HPKModel *> *)extensionComponents{
    
    [_webViewHandler.webView addExternalNavigationDelegate:externalDelegate];
    
    [self _setArticleDetailModel:model
               webViewComponents:webViewComponents
             extensionComponents:extensionComponents];
    
    [_webViewHandler.webView loadHTMLString:htmlTemplate baseURL:nil];
}

// banner view controller & components view controller
- (void)setArticleDetailModel:(NSObject *)model
               topInsetOffset:(CGFloat)topInsetOffset
          extensionComponents:(NSArray<HPKModel *> *)extensionComponents{
    
    _topInsetOffset = MAX(topInsetOffset, 0.f);
    
    [self _setArticleDetailModel:model webViewComponents:nil extensionComponents:extensionComponents];
    [self reLayoutExtensionComponents];
}


- (void)reLayoutWebViewComponentsWithIndex:(NSString *)index
                             componentSize:(CGSize)componentSize{
    if (!index) {
        return;
    }
    __weak typeof(self) wself = self;
    [_webViewHandler.webView safeAsyncEvaluateJavaScriptString:[HPKJavascriptUtils setComponentJSWithWithDomClass:self.viewConfig.webViewComponentPlaceHolderDomClass index:index componentSize:componentSize]
                                               completionBlock:^(NSObject *result) {
        __strong __typeof(wself) strongSelf = wself;
        [strongSelf reLayoutWebViewComponents];
    }];
}


- (void)reLayoutExtensionComponents{
    [self _reLayoutExtensionComponentsWithScrollOffset:_componentsOffsetY];
}
- (void)reLayoutWebViewComponents{
    __weak typeof(self) wself = self;
    [_webViewHandler.webView safeAsyncEvaluateJavaScriptString:[HPKJavascriptUtils getComponentFrameJsWithDomClass:self.viewConfig.webViewComponentPlaceHolderDomClass] completionBlock:^(NSObject *result) {
        __strong __typeof(wself) strongSelf = wself;
        if (![result isKindOfClass:[NSArray class]]) {
            return;
        }
        [strongSelf _reLayoutWebViewComponentsWithFrameArray:(NSArray *)result];
    }];
}


#pragma mark - scrollView delegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    //暂时禁止点击statusbar自动滚动到顶部
    return NO;
}

#pragma mark - private method

- (void)_handleTopWebViewScroll{
    
    if (!self.needWebView) {
        return;
    }
    
    CGFloat webViewContentSizeY = _webViewHandler.webView.scrollView.hpk_contentSizeHeight - _webViewHandler.webView.hpk_height;
    CGFloat offsetY = self.containerScrollView.hpk_contentOffsetY;
    CGFloat webViewNewOffset = 0.f;
    
    if (webViewContentSizeY == 0 && offsetY == 0) {
        return;
    }
    
    if (offsetY < 0) {
        // 容错-快速滚动到顶部
        _webViewHandler.webView.scrollView.hpk_contentOffsetY = 0.f;
        return;
    }
    
    if (offsetY <= webViewContentSizeY) {
        webViewNewOffset = offsetY;
    }else if(_webViewHandler.webView.scrollView.hpk_contentOffsetY < webViewContentSizeY){
        // 容错-快速滚动到底部
        webViewNewOffset = webViewContentSizeY;
    }else{
        return;
    }
    
    _webViewHandler.webView.hpk_top = webViewNewOffset;
    _webViewHandler.webView.scrollView.hpk_contentOffsetY = webViewNewOffset;
    [self reLayoutExtensionComponents];
}

- (void)_handleBottomScrollViewScroll{
    
    if (self.containerScrollView.hpk_contentOffsetY <= 0) {
        return;
    }
    
    HPKModel *bottomComponentModel = [self.sortedExtensionComponents lastObject];
    
    __kindof UIView *bottomComponentView = [self.containerViewScrollViewhandler getComponentViewByItem:bottomComponentModel];
    
    if (![bottomComponentView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    __kindof UIScrollView *bottomScrollView = (UIScrollView *)bottomComponentView;
    CGFloat bottomViewHeight = [bottomComponentModel getComponentFrame].size.height;
    CGFloat bottomOffset = 0.f;
    
    if (bottomScrollView.hpk_contentSizeHeight <= _containerScrollView.hpk_height) {
        return;
    }
    
    
    if (bottomScrollView.hpk_contentOffsetY >= bottomScrollView.hpk_contentSizeHeight - bottomViewHeight) {
        // 容错-快速滚动到底部
        if (self.containerScrollView.hpk_contentOffsetY >= self.containerScrollView.hpk_contentSizeHeight - self.containerScrollView.hpk_height) {
            
            if ([bottomComponentModel enablePullToLoad]) {
                bottomScrollView.hpk_top = self.containerScrollView.hpk_contentOffsetY;
                bottomScrollView.hpk_contentOffsetY = self.containerScrollView.hpk_contentOffsetY - _bottomViewOriginY;
                _componentsOffsetY = self.containerScrollView.hpk_contentOffsetY - _bottomViewOriginY;
            }else{
                bottomScrollView.hpk_contentOffsetY = bottomScrollView.hpk_contentSizeHeight - bottomScrollView.hpk_height;
            }
            return;
        }
    }
    
    if (self.containerScrollView.hpk_contentOffsetY <= _bottomViewOriginY) {
        // 容错-快速滚动到bottomView之上
        if (bottomScrollView.hpk_contentOffsetY == 0) {
            return;
        }
        bottomOffset = 0;
    }else {
        bottomOffset = self.containerScrollView.hpk_contentOffsetY - _bottomViewOriginY;
    }
    
    [self _reLayoutExtensionComponentsWithScrollOffset:bottomOffset];
    bottomScrollView.hpk_contentOffsetY = bottomOffset;
}

- (void)_reLayoutWebViewComponentsWithFrameArray:(NSArray *)frameArray{
    
    //更新Frame
    for (HPKModel *component in self.webViewComponents) {
        CGRect frame = CGRectZero;
        NSString *key = [component getUniqueId];
        for (NSDictionary *dic in frameArray) {
            if ([[dic objectForKey:@"index"] isEqualToString:key]) {
                frame = CGRectMake(((NSString *)[dic objectForKey:@"left"]).floatValue, ((NSString *)[dic objectForKey:@"top"]).floatValue,((NSString *)[dic objectForKey:@"width"]).floatValue,((NSString *)[dic objectForKey:@"height"]).floatValue);
                break;
            }
        }
        [component setComponentFrame:frame];
    }
    __weak typeof(self) wself = self;
    // 重新布局Native元素位置
    [self.webViewScrollViewhandler reloadComponentViewsWithProcessBlock:^NSDictionary<NSString *,HPKModel *> *(NSDictionary<NSString *,HPKModel *> *componentItemDic) {
        __strong __typeof(wself) strongSelf = wself;
        NSMutableDictionary *dic = @{}.mutableCopy;
        for (HPKModel *component in strongSelf.webViewComponents) {
            [dic setObject:component forKey:[component getUniqueId]];
        }
        return dic.copy;
    }];
    
    //计算WebView ContentSize后，布局Extension Area，防止高度小于一屏
    [_webViewHandler.webView evaluateJavaScript:[HPKJavascriptUtils getWebViewContentHeightWithContainerWidth:(int)self.containerScrollView.bounds.size.width] completionHandler:^(id data, NSError * _Nullable error) {
        __strong __typeof(wself) strongSelf = wself;
        CGFloat height = [data floatValue];
        strongSelf.webViewHandler.webView.frame = CGRectMake(0, 0, strongSelf.containerScrollView.bounds.size.width, MIN(height, strongSelf.containerScrollView.bounds.size.height));
        [strongSelf reLayoutExtensionComponents];
    }];
}

- (void)_reLayoutExtensionComponentsWithScrollOffset:(CGFloat)offset{
    
    if(!_sortedExtensionComponents || _sortedExtensionComponents.count <= 0){
        if (_needWebView && _webViewHandler.webView) {
            _containerScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,_webViewHandler.webView.scrollView.contentSize.height);
        }
        return;
    }
    _componentsOffsetY = offset;
    CGFloat bottom = (_needWebView ? (_webViewHandler.webView.frame.origin.y + _webViewHandler.webView.frame.size.height) : _topInsetOffset)
    + self.viewConfig.componentsGap + _componentsOffsetY;
    
    for (int i = 0; i < _sortedExtensionComponents.count; i++) {
        HPKModel *component = [_sortedExtensionComponents objectAtIndex:i];
        [component setComponentOriginY:bottom];
        bottom += [component getComponentFrame].size.height + self.viewConfig.componentsGap;
        
        if (i == _sortedExtensionComponents.count - 1) {
            _bottomViewOriginY = [component getComponentFrame].origin.y - offset;
        }
    }
    
    __weak typeof(self) wself = self;
    [_containerViewScrollViewhandler reloadComponentViewsWithProcessBlock:^NSDictionary<NSString *,HPKModel *> *(NSDictionary<NSString *,HPKModel *> *componentItemDic) {
        __strong __typeof(wself) strongSelf = wself;
        NSMutableDictionary *dic = @{}.mutableCopy;
        for (HPKModel *component in strongSelf.sortedExtensionComponents) {
            [dic setObject:component forKey:[component getUniqueId]];
        }
        strongSelf.containerScrollView.hpk_contentSizeHeight = bottom;
        return dic.copy;
    }];
}

-(void)_setArticleDetailModel:(NSObject *)model
            webViewComponents:(NSArray<HPKModel *> *)webViewComponents
          extensionComponents:(NSArray<HPKModel *> *)extensionComponents{
    
    [self triggerEvent:kHPKComponentEventControllerDidReceiveData para1:self para2:model];
    _webViewComponents = [[self _filterComponents:webViewComponents] copy];
    _sortedExtensionComponents = [[self _filterComponents:extensionComponents] sortedArrayUsingComparator:^NSComparisonResult(id<HPKModelProtocol> obj1, id<HPKModelProtocol> obj2) {
        return ([obj1 getUniqueId] < [obj2 getUniqueId]) ? NSOrderedAscending : NSOrderedDescending;
    }];
}

-(NSArray *)_filterComponents:(NSArray *)components{
    return [components objectsAtIndexes:
            [components indexesOfObjectsPassingTest:^BOOL(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        for(NSObject *controller in self.componentControllerArray){
            if ([controller isKindOfClass:[obj getComponentControllerClass]]) {
                return YES;
            }
        }
        return NO;
    }]];
}


#pragma mark - component event trigger

-(void)_triggerComponentEventWithState:(HPKComponentViewState)state
                         componentItem:(HPKModel *)componentItem
                         componentView:(__kindof UIView *)componentView{
    
    HPKComponentEvent event;
    if (state == kHPKComponentViewWillPreparedComponentView) {
        event = kHPKComponentEventWillPrepareComponentView;
    }else if(state == kHPKComponentViewWillDisplayComponentView){
        event = kHPKComponentEventWillDisplayComponentView;
    }else if(state == kHPKComponentViewEndDisplayComponentView){
        event = kHPKComponentEventEndDisplayComponentView;
    }else if(state == kHPKComponentViewEndPreparedComponentView){
        event = kHPKComponentEventEndPrepareComponentView;
    }else if(state == kHPKComponentViewReLayoutPreparedAndVisibleComponentView){
        event = kHPKComponentEventRelayoutComponentView;
    }else{
        return;
    }
    
    [self triggerEvent:event para1:componentView para2:componentItem];
}

@end
