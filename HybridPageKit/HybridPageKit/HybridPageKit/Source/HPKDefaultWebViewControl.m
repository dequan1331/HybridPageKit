//
// HPKDefaultWebViewControl.m
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


#import "HPKDefaultWebViewControl.h"
#import "HPKPageManager.h"
#import "HPKWebViewExtensionDelegate.h"
#import "HPKWebViewPool.h"
#import "HPKPageHandler.h"
#import "_HPKUtils.h"

@interface HPKDefaultWebViewModel : NSObject<HPKModelProtocol>
@end
@implementation HPKDefaultWebViewModel
IMP_HPKModelProtocol(@"")
@end

@interface HPKDefaultWebViewControl ()

@property (nonatomic, weak, readwrite) HPKPageHandler *handler;
@property (nonatomic, assign, readwrite) Class webViewClass;

@property (nonatomic, strong, readwrite) __kindof HPKWebView *defaultWebView;
@property (nonatomic, strong, readwrite) HPKModel *defaultWebViewModel;

@end

@implementation HPKDefaultWebViewControl

- (void)dealloc {
    HPKInfoLog(@"HPKDefaultWebViewControl dealloc with webview contentSize: %@, invalid: %@", NSStringFromCGSize(self.defaultWebView.scrollView.contentSize), @(self.defaultWebView.invalidForReuse));
    [[HPKWebViewPool sharedInstance] enqueueWebView:self.defaultWebView];
    if(isiOS13Beta1){
        [_defaultWebView.scrollView safeRemoveObserver:self keyPath:@"scrollEnabled"];
    }
}

- (instancetype)initWithDetailHandler:(HPKPageHandler *)detailHandler
                  defaultWebViewClass:(Class)webViewClass
                  defaultWebViewIndex:(NSInteger)defaultWebViewIndex {
    self = [super init];
    if (self) {
        self.handler = detailHandler;
        self.webViewClass = webViewClass;

        _defaultWebViewModel = [[HPKDefaultWebViewModel alloc] init];
        [_defaultWebViewModel setComponentIndex:@(defaultWebViewIndex).stringValue];

        [self _commonInitWebView];
    }
    return self;
}

- (void)resetWebView {
    //销毁当前的webview及回收池
    [_defaultWebView componentViewWillEnterPool];
    [_defaultWebView removeFromSuperview];
    [[HPKWebViewPool sharedInstance] removeReusableWebView:_defaultWebView];
    [[HPKWebViewPool sharedInstance] clearAllReusableWebViews];

    [_defaultWebViewModel resetComponentState];
    //重新创建webview
    [self _commonInitWebView];
    HPKInfoLog(@"HPKDefaultWebViewControl reset webview");
}

- (void)webviewContentSizeChange:(__kindof HPKWebView *)webView
                         newSize:(CGSize)newSize
                         oldSize:(CGSize)oldSize{
    
    if (webView != _defaultWebView) {
        return;
    }
    
    //文章长度小于一屏的，需要用js取高度，并且重新赋值
    if (newSize.height <= _defaultWebView.bounds.size.height) {
        NSString *jsString = [NSString stringWithFormat:@"document.documentElement.offsetHeight * %d / document.documentElement.clientWidth",(int)_defaultWebView.bounds.size.width];
        [_defaultWebView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (result && [result isKindOfClass:[NSNumber class]]) {
                CGFloat jsHeight = ((NSNumber *)result).floatValue;
                if (jsHeight > 0 && jsHeight < self.handler.containerScrollView.frame.size.height) {
                    //已经调整过的不重复调整
                    if(jsHeight == self.defaultWebView.frame.size.height){
                        return;
                    }
                    CGRect webViewframe = self.defaultWebView.frame;
                    webViewframe.size.height = jsHeight;
                    CGSize webViewContentSize = self.defaultWebView.scrollView.contentSize;
                    webViewContentSize.height = jsHeight;
                    self.defaultWebView.frame = webViewframe;
                    self.defaultWebView.scrollView.contentSize = webViewContentSize;
                    [self.handler relayoutWithComponentChange];
                }
            }
        }];
    }
}

#pragma mark - private method
- (void)_commonInitWebView {
    _defaultWebView = nil;
    _defaultWebView = [[HPKWebViewPool sharedInstance] dequeueWebViewWithClass:self.webViewClass webViewHolder:self];
    _defaultWebView.frame = CGRectMake(0, 0, self.handler.containerScrollView.frame.size.width, self.handler.containerScrollView.frame.size.height);
    _defaultWebView.scrollView.scrollEnabled = NO;
    
    // iOS13Beta1 WKWebView change scrollView scrollEnabled automaticlly in ‘WKWebView _didCommitLayerTree:’
    // remove later
    if(isiOS13Beta1){
        __weak typeof(self)_self = self;
        [_defaultWebView.scrollView safeAddObserver:self keyPath:@"scrollEnabled" callback:^(NSObject *oldValue, NSObject *newValue) {
            __strong typeof(_self) self = _self;
            BOOL scrollEnabled = ((NSNumber *)newValue).boolValue;
            if(scrollEnabled){
                self.defaultWebView.scrollView.scrollEnabled = NO;
            }
        }];
    }
}

#pragma mark - HPKControllerProtocol

- (nullable HPKView *)unReusableComponentViewWithModel:(HPKModel *)componentModel {
    return _defaultWebView;
}

@end
