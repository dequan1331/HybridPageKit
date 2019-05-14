//
// HPKPageHandler.m
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

#import "HPKPageHandler.h"
#import "HPKScrollProcessor.h"
#import "_HPKAspects.h"
#import "_HPKUtils.h"
#import "HPKDefaultWebViewControl.h"
#import "HPKWebViewExtensionDelegate.h"

NSString *const kHPKWebViewComponentIndex = @"index";
NSString *const kHPKWebViewComponentHeight = @"height";
NSString *const kHPKWebViewComponentWidth = @"width";
NSString *const kHPKWebViewComponentLeft = @"left";
NSString *const kHPKWebViewComponentTop = @"top";

typedef NS_ENUM (NSInteger, HPKControllerEvent) {
    //controller
    kHPKControllerEventViewWillAppear,
    kHPKControllerEventViewDidAppear,
    kHPKControllerEventViewWillDisappear,
    kHPKControllerEventViewDidDisappear,
    kHPKControllerEventReceiveMemoryWarning,
    kHPKControllerEventApplicationDidBecomeActive,
    kHPKControllerEventApplicationWillResignActive,
};

static inline SEL _getHPKControllerProtocolByEventType(HPKControllerEvent event) {
    SEL mapping[] = {
        [kHPKControllerEventViewWillAppear] = @selector(controllerViewWillAppear),
        [kHPKControllerEventViewDidAppear] = @selector(controllerViewDidAppear),
        [kHPKControllerEventViewWillDisappear] = @selector(controllerViewWillDisappear),
        [kHPKControllerEventViewDidDisappear] = @selector(controllerViewDidDisappear),
        [kHPKControllerEventReceiveMemoryWarning] = @selector(controllerReceiveMemoryWarning),
        [kHPKControllerEventApplicationDidBecomeActive] = @selector(applicationDidBecomeActive),
        [kHPKControllerEventApplicationWillResignActive] = @selector(applicationWillResignActive),
    };
    return mapping[event];
}

@interface HPKPageHandler ()

@property (nonatomic, weak, readwrite) __kindof UIViewController *weakController;
@property (nonatomic, weak, readwrite) __kindof UIScrollView *containerScrollView;
@property (nonatomic, weak, readwrite) __kindof WKWebView *webView;

@property (nonatomic, strong, readwrite) HPKScrollProcessor *contentViewScrollHandler; //components滚动管理
@property (nonatomic, strong, readwrite) HPKScrollProcessor *webViewScrollHandler;     //webComponents滚动管理

@property (nonatomic, strong, readwrite) HPKDefaultWebViewControl *defaultWebViewControl;  //默认webview的生成与管理
@property (nonatomic, strong, readwrite) HPKWebViewExtensionDelegate *extensionDelegate;   //webview extension delegate

@property (nonatomic, copy, readwrite) NSArray<HPKModel *> *componentModels;
@property (nonatomic, copy, readwrite) NSArray<HPKModel *> *webComponentModels;

@property (nonatomic, copy, readwrite) NSArray<HPKController *> *componentControllers;
@property (nonatomic, strong, readwrite) NSMapTable<NSString *, HPKController *> *componentControllerMap;

@property (nonatomic, copy, readwrite) NSString *componentDomClassStr;
@property (nonatomic, copy, readwrite) NSString *componentIndexKeyStr;

@end

@implementation HPKPageHandler

#pragma mark - lift cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_handleReceiveMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    self.weakController = nil;
    self.containerScrollView = nil;
    self.webViewScrollHandler = nil;
    self.contentViewScrollHandler = nil;
    self.componentControllerMap = nil;
    self.componentControllers = nil;
    self.extensionDelegate = nil;
    //noti and KVO
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public method

- (void)configWithViewController:(__kindof UIViewController *)viewController
           componentsControllers:(NSArray<HPKController *> *)componentsControllers {
    [self _configViewController:viewController];
    [self _configComponentsControllers:componentsControllers];
}

- (void)handleSingleScrollView:(__kindof UIScrollView *)scrollView {
    if (!scrollView) {
        HPKFatalLog(@"HPKPageHandler handle scrollview wiht invalid params!");
        return;
    }

    self.containerScrollView = scrollView;
    //components
    __weak typeof(self)_self = self;
    self.contentViewScrollHandler = [[HPKScrollProcessor alloc] initWithScrollView:self.containerScrollView
                                                                       layoutType:kHPKLayoutTypeAutoCalculateFrame
                                                              scrollDelegateBlock:^NSObject<HPKControllerProtocol> *(HPKModel *model, BOOL isGetViewEvent) {
        __strong typeof(_self) self = _self;
        //默认的WebView特殊处理下
        if (isGetViewEvent && self.defaultWebViewControl && model == self.defaultWebViewControl.defaultWebViewModel) {
            return self.defaultWebViewControl;
        } else {
            return [self.componentControllerMap objectForKey:NSStringFromClass([model class])];
        }
    }];
}

- (void)handleSingleWebView:(__kindof WKWebView *)webView
       webComponentDomClass:(NSString *)webComponentDomClass
       webComponentIndexKey:(NSString *)webComponentIndexKey {
    if (!webView) {
        HPKFatalLog(@"HPKPageHandler handle webview wiht invalid params!");
        return;
    }

    self.webView = webView;
    __weak typeof(self)_self = self;
    self.webViewScrollHandler = [[HPKScrollProcessor alloc] initWithScrollView:webView.scrollView
                                                                   layoutType:kHPKLayoutTypeManualCalculateFrame
                                                          scrollDelegateBlock:^NSObject<HPKControllerProtocol> *(HPKModel *model, BOOL isGetViewEvent) {
        __strong typeof(_self) self = _self;
        return [self.componentControllerMap objectForKey:NSStringFromClass([model class])];
    }];

    _componentDomClassStr = webComponentDomClass;
    _componentIndexKeyStr = webComponentIndexKey;
}

- (void)handleHybridPageWithContainerScrollView:(__kindof UIScrollView *)containerScrollView
                            defaultWebViewClass:(Class)defaultWebViewClass
                            defaultWebViewIndex:(NSInteger)defaultWebViewIndex
                           webComponentDomClass:(NSString *)webComponentDomClass
                           webComponentIndexKey:(NSString *)webComponentIndexKey {
    if (!containerScrollView) {
        HPKFatalLog(@"HPKPageHandler handle hybrid page wiht invalid params!");
        return;
    }

    [self handleSingleScrollView:containerScrollView];

    _defaultWebViewControl = [[HPKDefaultWebViewControl alloc] initWithDetailHandler:self defaultWebViewClass:defaultWebViewClass defaultWebViewIndex:defaultWebViewIndex];

    self.webView = _defaultWebViewControl.defaultWebView;
    self.containerScrollView = containerScrollView;

    [self handleSingleWebView:self.webView webComponentDomClass:webComponentDomClass webComponentIndexKey:webComponentIndexKey];
}

- (NSObject<WKNavigationDelegate> *)replaceExtensionDelegateWithOriginalDelegate:(nullable NSObject<HPKDefaultWebViewProtocol> *)originalDelegate {
    if (!self.webView) {
        HPKFatalLog(@"HPKPageHandler should first init webview");
        return nil;
    }

    _extensionDelegate = [[HPKWebViewExtensionDelegate alloc] initWithOriginalDelegate:originalDelegate navigationDelegates:[self allComponentControllers]];

    __weak typeof(self)_self = self;
    [_extensionDelegate configWebView:self.webView contentSizeChangeBlock:^(NSValue *newValue, NSValue *oldValue) {
        __strong typeof(_self) self = _self;
        CGSize newSize = [newValue CGSizeValue];
        CGSize oldSize = [oldValue CGSizeValue];
        if (!CGSizeEqualToSize(oldSize, newSize)) {
            [self relayoutWithWebComponentChange];
            [self relayoutWithComponentChange];
        }
        [self.defaultWebViewControl webviewContentSizeChange:self.webView newSize:newSize oldSize:oldSize];
    }];

    return _extensionDelegate;
}

#pragma mark -

- (void)relayoutWithComponentChange {
    [self.contentViewScrollHandler relayoutWithComponentFrameChange];
}

- (void)relayoutWithWebComponentChange {
    [self layoutWithWebComponentModels:_webComponentModels];
}

- (void)layoutWithComponentModels:(NSArray<HPKModel *> *)componentModels {
    if (!componentModels) {
        componentModels = @[];
    }

    if (_defaultWebViewControl && _defaultWebViewControl.defaultWebViewModel) {
        NSMutableArray *componentModelsTmp = componentModels.mutableCopy;
        [componentModelsTmp addObject:_defaultWebViewControl.defaultWebViewModel];
        _componentModels = [componentModelsTmp copy];
        [self.contentViewScrollHandler layoutWithComponentModels:_componentModels];
    } else {
        _componentModels = componentModels;
        [self.contentViewScrollHandler layoutWithComponentModels:_componentModels];
    }
}

- (void)layoutWithAddComponentModel:(HPKModel *)componentModel {
    if (!componentModel) {
        return;
    }

    if (!_componentModels) {
        _componentModels = @[];
    }

    NSMutableArray *componentModelsTmp = _componentModels.mutableCopy;
    [componentModelsTmp addObject:componentModel];
    _componentModels = [componentModelsTmp copy];
    [self.contentViewScrollHandler layoutWithComponentModels:_componentModels];
}

- (void)layoutWithWebComponentModels:(NSArray<HPKModel *> *)componentModels {
    if (!componentModels || componentModels.count <= 0) {
        if (_extensionDelegate) {
            //如果使用delegate扩展，广播方法
            [_extensionDelegate triggerRelayoutWebComponentEvent];
        }
        return;
    }

    self.webComponentModels = componentModels;

    NSString *jsStr = [self _detectComponentsFrameJS];

    if (!jsStr || jsStr.length <= 0) {
        return;
    }

    [self.webView safeAsyncEvaluateJavaScriptString:jsStr completionBlock:^(NSObject *result) {
        __unused __attribute__((objc_ownership(strong))) __typeof__(self) self_retain_ = self;

        if (![result isKindOfClass:[NSArray class]]) {
            return;
        }

        NSArray *componentsFrameArray = (NSArray *)result;

        for (NSObject *frameInfoObj in componentsFrameArray) {
            if (![frameInfoObj isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            NSDictionary *frameInfo = (NSDictionary *)frameInfoObj;
            NSString *componentId = [[frameInfo objectForKey:kHPKWebViewComponentIndex] isKindOfClass:[NSString class]] ? (NSString *)[frameInfo objectForKey:kHPKWebViewComponentIndex] : @"";
            CGRect componentRect = CGRectMake([frameInfo[kHPKWebViewComponentLeft] isKindOfClass:[NSNumber class]] ?
                                              ((NSNumber *)frameInfo[kHPKWebViewComponentLeft]).floatValue : 0.f,
                                              [frameInfo[kHPKWebViewComponentTop] isKindOfClass:[NSNumber class]] ?
                                              ((NSNumber *)frameInfo[kHPKWebViewComponentTop]).floatValue : 0.f,
                                              [frameInfo[kHPKWebViewComponentWidth] isKindOfClass:[NSNumber class]] ?
                                              ((NSNumber *)frameInfo[kHPKWebViewComponentWidth]).floatValue : 0.f,
                                              [frameInfo[kHPKWebViewComponentHeight] isKindOfClass:[NSNumber class]] ?
                                              ((NSNumber *)frameInfo[kHPKWebViewComponentHeight]).floatValue : 0.f);

            [self.webComponentModels enumerateObjectsUsingBlock:^(NSObject<HPKModelProtocol> *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                HPKModel *model = obj;
                if (componentId && [[model componentIndex] isEqualToString:componentId]) {
                    [model setComponentFrame:componentRect];
                    *stop = YES;
                }
            }];
        }
        [self.webViewScrollHandler layoutWithComponentModels:self.webComponentModels];
    }];

    if (_extensionDelegate) {
        //如果使用delegate扩展，广播方法
        [_extensionDelegate triggerRelayoutWebComponentEvent];
    }
}

- (void)reLayoutWebViewComponentsWithNode:(NSObject *)node
                            componentSize:(CGSize)componentSize
                               marginLeft:(CGFloat)marginLeft {
    if (ISHPKModel(node)) {
        if (!CGSizeEqualToSize([((HPKModel *)node) componentFrame].size, componentSize)) {
            NSString *jsStr = [self _setComponentJSWithWithIndex:((HPKModel *)node).componentIndex componentSize:componentSize left:marginLeft];

            if (!jsStr || jsStr.length <= 0) {
                return;
            }

            [self.webView safeAsyncEvaluateJavaScriptString:jsStr
                                            completionBlock:^(NSObject *result) {
                __unused __attribute__((objc_ownership(strong))) __typeof__(self) self_retain_ = self;
                [self relayoutWithWebComponentChange];
            }];
        }
    }
}

- (NSArray<HPKModel *> *)allVisibleComponentModels {
    return [self.contentViewScrollHandler getVisibleComponentModels] ? : @[];
}

- (NSArray<HPKModel *> *)allVisibleWebComponentModels {
    return [self.webViewScrollHandler getVisibleComponentModels] ? : @[];
}

- (NSArray<HPKView *> *)allVisibleComponentViews {
    return [self.contentViewScrollHandler getVisibleComponentViews] ? : @[];
}

- (NSArray<HPKView *> *)allVisibleWebComponentViews {
    return [self.webViewScrollHandler getVisibleComponentViews] ? : @[];
}

- (NSArray<HPKController *> *)allComponentControllers {
    return _componentControllers;
}

- (void)getAllWebComponentDomFrameWithCompletionBlock:(HPKWebViewJSCompletionBlock)completionBlock{
    NSString *jsStr = [self _detectComponentsFrameJS];
    if (!jsStr || jsStr.length <= 0) {
        HPKFatalLog(@"HPKPageHandler get all web component failed %@, %@",_componentDomClassStr ,_componentIndexKeyStr);
        return;
    }
    [self.webView safeAsyncEvaluateJavaScriptString:jsStr completionBlock:completionBlock];
}

#pragma mark -

- (void)triggerEvent:(HPKControllerEvent)event {
    SEL protocolSelector = _getHPKControllerProtocolByEventType(event);
    if (!protocolSelector) {
        HPKFatalLog(@"HPKPageHandler trigger invalid event:%@", @(event));
        return;
    }

    for (__kindof NSObject<HPKControllerProtocol> *component in _componentControllers) {
        [self _componentController:component performSelector:protocolSelector withObject:nil withObject:nil];
    }
}

- (void)triggerSelector:(SEL)selector toComponentController:(HPKController *)toComponentController para1:(NSObject *)para1 para2:(NSObject *)para2 {
    if (!selector || !toComponentController) {
        return;
    }
    [self _componentController:toComponentController performSelector:selector withObject:para1 withObject:para2];
}

- (void)triggerBroadcastSelector:(SEL)selector para1:(NSObject *)para1 para2:(NSObject *)para2 {
    if (!selector) {
        return;
    }

    for (__kindof NSObject<HPKControllerProtocol> *component in _componentControllers) {
        [self _componentController:component performSelector:selector withObject:para1 withObject:para2];
    }
}

- (void)scrollToContentOffset:(CGPoint)toContentOffset animated:(BOOL)animated {
    [self.contentViewScrollHandler scrollToContentOffset:toContentOffset animated:animated];
}

- (void)scrollToComponentView:(HPKView *)elementView
                     atOffset:(CGFloat)offsetY
                     animated:(BOOL)animated {
    [self.contentViewScrollHandler scrollToComponentView:elementView atOffset:offsetY animated:animated];
}

- (void)resetDefaultWebView {
    HPKInfoLog(@"HPKPageHandler begin reset default webview");
    [_contentViewScrollHandler removeComponentModelAndRelayout:_defaultWebViewControl.defaultWebViewModel];
    [_defaultWebViewControl resetWebView];
    [_contentViewScrollHandler addComponentModelAndRelayout:_defaultWebViewControl.defaultWebViewModel];
    self.webView = _defaultWebViewControl.defaultWebView;
    __weak typeof(self)_self = self;
    self.webViewScrollHandler = [[HPKScrollProcessor alloc] initWithScrollView:self.webView.scrollView
                                                                   layoutType:kHPKLayoutTypeManualCalculateFrame
                                                          scrollDelegateBlock:^NSObject<HPKControllerProtocol> *(HPKModel *model, BOOL isGetViewEvent) {
                                                              __strong typeof(_self) self = _self;
                                                              return [self.componentControllerMap objectForKey:NSStringFromClass([model class])];
                                                          }];
}

- (void)setLastReadPositionY:(CGFloat)positionY {
    __weak typeof(self)_self = self;
    [_extensionDelegate configWebViewLastReadPositionY:positionY scrollBlock:^(CGPoint offset) {
        __strong typeof(_self) self = _self;
        CGPoint scrollToOffset = CGPointMake(offset.x, MIN(offset.y, self.containerScrollView.contentSize.height - self.containerScrollView.frame.size.height));
        [self scrollToContentOffset:scrollToOffset animated:NO];
    }];
}

#pragma mark - private method

- (void)_configViewController:(__kindof UIViewController *)viewController {
    self.weakController = viewController;

    __weak typeof(self)_self = self;
    [self.weakController HPK_aspect_hookSelector:@selector(viewWillAppear:)
                                    withOptions:AspectPositionAfter
                                     usingBlock:^(id<HPK_AspectInfo> info, BOOL animated) {
        __strong typeof(_self) self = _self;
        [self triggerEvent:kHPKControllerEventViewWillAppear];
    } error:nil];
    [self.weakController HPK_aspect_hookSelector:@selector(viewDidAppear:)
                                    withOptions:AspectPositionAfter
                                     usingBlock:^(id<HPK_AspectInfo> info, BOOL animated) {
        __strong typeof(_self) self = _self;
        [self triggerEvent:kHPKControllerEventViewDidAppear];
    } error:nil];
    [self.weakController HPK_aspect_hookSelector:@selector(viewWillDisappear:)
                                    withOptions:AspectPositionAfter
                                     usingBlock:^(id<HPK_AspectInfo> info, BOOL animated) {
        __strong typeof(_self) self = _self;
        [self triggerEvent:kHPKControllerEventViewWillDisappear];
    } error:nil];
    [self.weakController HPK_aspect_hookSelector:@selector(viewDidDisappear:)
                                    withOptions:AspectPositionAfter
                                     usingBlock:^(id<HPK_AspectInfo> info, BOOL animated) {
        __strong typeof(_self) self = _self;
        [self triggerEvent:kHPKControllerEventViewDidDisappear];
    } error:nil];
}

- (void)_configComponentsControllers:(NSArray<HPKController *> *)componentsControllers {
    if (!componentsControllers || componentsControllers.count <= 0) {
        HPKFatalLog(@"HPKPageHandler config wiht invalid params!");
        return;
    }

    _componentControllers = [componentsControllers copy];
    _componentControllerMap = [NSMapTable strongToWeakObjectsMapTable];

    for (NSObject *control in componentsControllers) {
        //数据校验
        if (!ISHPKControl(control)) {
            HPKFatalLog(@"HPKPageHandler has invalid components controls ");
            continue;
        }

        HPKController *componentControl;
        if ([control isKindOfClass:[HPKController class]]) {
            componentControl = (HPKController *)control;
        }

        if ([componentControl respondsToSelector:@selector(supportComponentModelClass)]) {
            NSArray<Class> *modelClass = [componentControl supportComponentModelClass];
            for (Class cls in modelClass) {
                NSString *classString = NSStringFromClass(cls);
                if ([[[_componentControllerMap keyEnumerator] allObjects] containsObject:classString]) {
                    HPKFatalLog(@"HPKHandler invalid support model class");
                }
                [_componentControllerMap setObject:componentControl forKey:classString];
            }
        }
    }
}

- (void)_componentController:(HPKController *)componentController
             performSelector:(SEL)aSelector
                  withObject:(NSObject *)object1
                  withObject:(NSObject *)object2 {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([componentController respondsToSelector:aSelector]) {
        [componentController performSelector:aSelector withObject:object1 withObject:object2];
    }
#pragma clang diagnostic pop
}

- (void)_handleReceiveMemoryWarning {
    [self triggerEvent:kHPKControllerEventReceiveMemoryWarning];
}

- (void)_handleBecomeActive {
    [self triggerEvent:kHPKControllerEventApplicationDidBecomeActive];
}

- (void)_handleResignActive {
    [self triggerEvent:kHPKControllerEventApplicationWillResignActive];
}

- (NSString *)_detectComponentsFrameJS {
    if (!_componentDomClassStr || !_componentIndexKeyStr) {
        return nil;
    }
    //通过className和attribute取frame
    return [NSString stringWithFormat:@"(function(){var componentFrameDic=[];var list= document.getElementsByClassName('%@');for(var i=0;i<list.length;i++){var dom = list[i];componentFrameDic.push({'%@':dom.getAttribute('%@'),'%@':dom.offsetTop,'%@':dom.offsetLeft,'%@':dom.clientWidth,'%@':dom.clientHeight});}return componentFrameDic;}())", _componentDomClassStr, kHPKWebViewComponentIndex, _componentIndexKeyStr, kHPKWebViewComponentTop, kHPKWebViewComponentLeft, kHPKWebViewComponentWidth, kHPKWebViewComponentHeight];
}

- (NSString *)_setComponentJSWithWithIndex:(NSString *)index componentSize:(CGSize)componentSize left:(CGFloat)left {
    if (!_componentDomClassStr || !_componentIndexKeyStr || index.length <= 0) {
        return nil;
    }
    //通过className和attribute设置frame
    return [NSString stringWithFormat:@"[].forEach.call(document.getElementsByClassName('%@'), function (dom) {if(dom.getAttribute('%@') == '%@'){dom.style.width='%@px';dom.style.height='%@px';%@}});", _componentDomClassStr, _componentIndexKeyStr, index, @(componentSize.width), @(componentSize.height), ((left != 0.f) ? [NSString stringWithFormat:@"dom.style.marginLeft='%@px';", @(left)] : @"")];
}

@end
