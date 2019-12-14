//
// HPKPageManager.h
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


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "HPKWebView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, HPKLogLevel) {
    kHPKLogLevelInfo,   //普通信息，输出关键节点Log
    kHPKLogLevelError,  //错误信息，
    kHPKLogLevelFatal,  //严重错误信息，debug建议Crash
};

/**
 日志Log回调函数，业务层处理
 */
typedef void (^HPKLogCallBack)(NSString *logString, HPKLogLevel logLevel);

/**
 * HPKPageManager 全局控制
 */
@interface HPKPageManager : NSObject

+ (HPKPageManager *)sharedInstance;

/**
 业务层自定义log输出CallBack
 */
@property (nonatomic, copy, readwrite) HPKLogCallBack logCallBack;

/**
 webview渲染完成是否有展示动画
 默认为YES
 */
@property (nonatomic, assign, readwrite) BOOL showWebViewWithAnimation;

/**
 滚动时预加载的距离
 默认为预加载屏幕高度一半
 */
@property (nonatomic, assign, readwrite) CGFloat componentsPrepareWorkRange;

/**
 每种类型View最大缓存数量
 默认为10个
 */
@property (nonatomic, assign, readwrite) NSInteger componentsMaxReuseCount;

/**
 webview进入回收复用池前加载的url，用于刷新webview和容错
 默认为空
 */
@property (nonatomic, copy, readwrite) NSString *webViewReuseLoadUrlStr;

/**
 底层页判断ContentSize是否可以滚动到上次阅读位置，最大runloop查询次数
 默认为50
 */
@property (nonatomic, assign, readwrite) NSInteger webViewShowMaxRetryTimes;

/**
 webview最大重用次数
 默认为最大无限制
 */
@property (nonatomic, assign, readwrite) NSInteger webViewMaxReuseTimes;

@end

//_______________________________________________________________________________________________________________
//_______________________________________________________________________________________________________________

@interface HPKPageManager (HPKReusableWebView)

/**
 获得一个可复用的webview

 @param webViewClass webview的自定义class
 @param webViewHolder webview的持有者，用于自动回收webview
 */
- (nullable __kindof HPKWebView *)dequeueWebViewWithClass:(Class)webViewClass webViewHolder:(NSObject *)webViewHolder;

/**
 回收可复用的WKWebView

 @param webView 可复用的webView
 */
- (void)enqueueWebView:(nullable __kindof HPKWebView *)webView;

/**
 回收并销毁WKWebView，并且将之从回收池里删除

 @param webView 可复用的webView
 */
- (void)removeReusableWebView:(nullable __kindof HPKWebView *)webView;

/**
 销毁全部在回收池中的WebView
 */
- (void)clearAllReusableWebViews;

/**
 销毁在回收池中特定Class的WebView

 @param webViewClass 可复用的webView的类型
 */
- (void)clearAllReusableWebViewsWithClass:(Class)webViewClass;

/**
 重新刷新在回收池中的WebView
 */
- (void)reloadAllReusableWebViews;

@end

typedef NS_ENUM (NSInteger, HPKWebViewUAConfigType) {
    kHPKWebViewUAConfigTypeReplace,     //replace all UA string
    kHPKWebViewUAConfigTypeAppend,      //append to original UA string
};

@interface HPKPageManager (HPKWebView)

/**
 设置全局WebView UA

 @param type replace or append
 @param customString 自定义UA字符串
 */
+ (void)configCustomUAWithType:(HPKWebViewUAConfigType)type
                      UAString:(NSString *)customString API_AVAILABLE(ios(9.0));

/**
 清除全部的WKWebViewcache

 @param includeiOS8 iOS9以下没有系统函数，删除缓存相关系统文件
 */
+ (void)safeClearAllCacheIncludeiOS8:(BOOL)includeiOS8;

/**
 修正WKWebViewMenuItems无法删除部分按钮的bug
 */
+ (void)fixWKWebViewMenuItems;

/**
 禁止WKWebView双击
 */
+ (void)disableWebViewDoubleClick;

@end

NS_ASSUME_NONNULL_END
