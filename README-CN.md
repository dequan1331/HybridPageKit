# HybridPageKit

[英文](./README.md) | [扩展阅读](https://dequan1331.github.io/) | [Extended Reading](https://dequan1331.github.io/index-en.html) 

>**HybridPageKit**是一个针对新闻类App高性能、易扩展、组件化的通用内容页实现框架。
>
>基于[ReusableNestingScrollview](https://github.com/dequan1331/ReusableNestingScrollview)、[WKWebViewExtension](https://github.com/dequan1331/WKWebViewExtension)、以及[扩展阅读](https://dequan1331.github.io/)中关于内容页架构和性能的探索。

<br>

<div>
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Hybrid.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Short.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Banner.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Folded.gif" width="20%">
</div>

## 配置 & 安装

1.	CocoaPods
		
		-> HybridPageKit (0.1)
		   A high-performance、high-extensibility、easy integration framework for Hybrid content page. Support most content page types of News App.
		   pod 'HybridPageKit', '~> 0.1'
		   - Homepage: https://github.com/dequan1331/HybridPageKit
		   - Source:   https://github.com/dequan1331/HybridPageKit.git
		   - Versions: 0.1 [master repo]
		   - Subspecs:
		     - HybridPageKit/WKWebViewExtension (0.1)
		     - HybridPageKit/ScrollReuseHandler (0.1)
		    
2. Cloning the repository


##	特性

>	强烈建议阅读[iOS新闻类App内容页技术探索](https://dequan1331.github.io/)

*  集成简单，几十行代码完成新闻类App的内容展示页框架，满足绝大多数使用场景
*  易于扩展，组件化管理高内聚低耦合，功能模块高度独立
* 	使用并扩展WKWebView，在提高系统稳定性的同时，进行更加友好和全面的扩展
* 	自动实现WKWebView全局复用、Native组件滚动复用、全局复用
*  	WebView中元素Native化实现，数据驱动，极大减少开发和维护成本，提升首屏速度
*  	统一页面内滚动复用管理逻辑，简单易于集成和扩展，线程安全

## 子项目

*	[WKWebViewExtension](https://github.com/dequan1331/WKWebViewExtension) : 一系列WKWebView的扩展。提供自定义长按MenuItems Bug修复、支持NSURLProtocol、清理iOS 8浏览器缓存等功能。
* 	[ReusableNestingScrollview](https://github.com/dequan1331/ReusableNestingScrollview) : 无需继承特殊ScrollView，无需继承特殊Model，状态丰富的，支持WKWebView、UIWebView、UIScrollView等滚动视图中subViews复用和回收组件。
*	[iOS新闻类App内容页技术探索](https://dequan1331.github.io/)

##	快速使用


1.基于后台下发模板-数据分离的数据结构
					
```json
{
//内容HTML
"articleContent": "<!DOCTYPE html><html><head></head><body><P>TEXTTEXTTEXTTEXTTEXTTEXT</P><P>{{IMG_0}}</P><P>TEXTTEXTTEXTTEXTTEXTTEXT</P><P>{{IMG_1}}</P><P>TEXTTEXTTEXTTEXTTEXTTEXT</P><P>{{IMG_2}}</P><P>The End</P></body></html>",

//内容HTML中的非文字组件数据
"articleAttributes": {
	"IMG_0": {
	    "url": "http://127.0.0.1:8080?type=3",
	    "width": "340",
	    "height": "200"
	},
	"IMG_1": {
	    "url": "http://127.0.0.1:8080?type=3",
	    "width": "340",
	    "height": "200"
	},
	"IMG_2": {
	    "url": "http://127.0.0.1:8080?type=3",
	    "width": "340",
	    "height": "200"
	},
},  

//扩展区域中的组件数据
"articleRelateNews": {
    "index":"1",
    "newsArray" : [
        "扩展阅读区 - RelateNews - 1",
        "扩展阅读区 - RelateNews - 2",
        "扩展阅读区 - RelateNews - 3",
        "扩展阅读区 - RelateNews - 4",
    ],
}, 

//扩展区域中的组件数据
"articleComment": {
    "index":"2",
    "commentArray" : [
        "相关评论区 - Comment - 1",
        "相关评论区 - Comment - 2",
        "相关评论区 - Comment - 3",
        "相关评论区 - Comment - 4",
    ],
},  
}
```

2.生成对应UI组件的Model、View、Controller

```objc
//Model实现RNSModelProtocol协议
@interface ImageModel :  NSObject<RNSModelProtocol>
//解析index
@property(nonatomic,copy,readwrite)NSString *index;
//保存当前组件的size
@property(nonatomic,assign,readwrite)CGRect frame;
@end

@implementation ImageModel
//实现RNSModelProtocol协议，对应传入Index，Frame，组件对应View，组件对应Controller，自定义context
RNSProtocolImp(_index,_frame, ImageView, ImageController, nil);
//解析数据
- (instancetype)initWithDictionary:(NSDictionary *)dic{}
@end

//自定义组件view
@interface ImageView : UIImageView
@end
```

3.生成UI组件对应的Controller，处理控制逻辑

```objc

//组件管理逻辑，实现HPKComponentControllerDelegate协议
@interface ImageController : NSObject<HPKComponentControllerDelegate>
@end

@implementation ImageController
//选择性实现HPKComponentControllerDelegate中的方法，进行自定义业务逻辑处理
- (BOOL)shouldResponseWithComponentView:(__kindof UIView *)componentView
                         componentModel:(RNSModel *)componentModel{}
- (void)scrollViewWillDisplayComponentView:(__kindof UIView *)componentView
    componentModel:(RNSModel *)componentModel{}

@end
```


4.内容页继承HPKViewController,返回支持组件Controller

```objc

@interface HybridViewController : HPKViewController
@end

@implementation HybridViewController
// 返回支持的UI组件类型
- (NSArray<NSObject<HPKComponentControllerDelegate> *> *)getValidComponentControllers{
    return @[
             [[ImageController alloc]init],
             ];
}
@end
```

5.填充数据渲染页面

```objc

- (void)setArticleDetailModel:(NSObject *)model                              //内容页数据，透传
                 htmlTemplate:(NSString *)htmlTemplate                       //内容页mustache格式HTML模板
      webviewExternalDelegate:(id<WKNavigationDelegate>)externalDelegate     //WebView external delegate，设置为self
            webViewComponents:(NSArray<NSObject<RNSModelProtocol> *> *)webViewComponents        //webview上的UI组件数据Model
          extensionComponents:(NSArray<NSObject<RNSModelProtocol> *> *)extensionComponents;     //extension区域上的UI组件数据Model

```

## 证书

All source code is licensed under the [MIT License](https://github.com/dequan1331/HybridPageKit/blob/master/LICENSE).

## 联系方式

<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/contact.png">


