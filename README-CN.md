# HybridPageKit

![GitHub](https://img.shields.io/github/license/dequan1331/HybridPageKit.svg)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/HybridPageKit.svg)
![GitHub closed issues](https://img.shields.io/github/issues-closed/dequan1331/HybridPagekit.svg)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/dequan1331/HybridPageKit.svg)

[英文](./README.md) | [扩展阅读](https://dequan1331.github.io/) | [Extended Reading](https://dequan1331.github.io/index-en.html) 

>**HybridPageKit**是一个针对新闻类App高性能、易扩展、组件化的通用内容页实现框架。
>
>基于[扩展阅读](https://dequan1331.github.io/)中关于内容页架构和性能的探索。

<br>

<div>
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Hybrid.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Short.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Banner.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Folded.gif" width="20%">
</div>

## 配置 & 安装

1.	CocoaPods 
```objc
//In your Podfile
pod "HybridPageKit", :testspecs => ["HybridPageKitTests"]
...
```

2. Carthage

```objc
//In your Cartfile
git "https://github.com/dequan1331/HybridPageKit.git" "master"
```

3. Cloning the repository


##	特性

>	强烈建议阅读[iOS新闻类App内容页技术探索](https://dequan1331.github.io/)

*  全部面向协议集成简单，几十行代码完成新闻类App的内容展示页框架，满足绝大多数使用场景
*  易于扩展，组件化管理高内聚低耦合，功能模块高度独立
*  使用并扩展WKWebView，在提高系统稳定性的同时，进行更加友好和全面的扩展
*  自动实现WKWebView全局复用、Native组件滚动复用、全局复用
*  WebView中元素Native化实现，数据驱动，极大减少开发和维护成本，提升首屏速度
*  统一页面内滚动复用管理逻辑，简单易于集成和扩展，线程安全


## 相关阅读

* [iOS新闻类App内容页技术探索](https://dequan1331.github.io/)


## 快速使用


1. 基于后台下发模板-数据分离的数据结构
					
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

2. 生成对应UI组件的Model、View

```objc
//Model实现HPKModelProtocol协议
@interface VideoModel : NSObject<HPKModelProtocol>
...
IMP_HPKModelProtocol(@"");

//View实现HPKModelProtocol协议
@interface VideoView : UIImageView<HPKViewProtocol>
...
IMP_HPKViewProtocol()

```

3. 生成UI组件对应的Controller，处理控制逻辑

```objc
@interface VideoController : NSObject<HPKControllerProtocol>
...
- (nullable NSArray<Class> *)supportComponentModelClass {
	return @[[VideoModel class]];
}
...
- (nullable Class)reusableComponentViewClassWithModel:(HPKModel *)componentModel {
	return [VideoView class];
}
...
- (void)scrollViewWillDisplayComponentView:(HPKView *)componentView
                    componentModel:(HPKModel *)componentModel {
...
}

- (void)controllerViewDidDisappear {
...
}
```

4. 实现简单的内容页

```objc
...
_componentHandler = [[HPKPageHandler alloc] initWithViewController:self componentsControllers:@[VideoController ...];
...
[_componentHandler handleSingleScrollView:[[UIScrollView alloc] initWithFrame:self.view.bounds]];
...
[_componentHandler layoutWithComponentModels:@[VideoModel ...]];
...
```

5. 实现复杂Hybrid类型的内容页

```objc
// in page viewController
...
_componentHandler = [[HPKPageHandler alloc] initWithViewController:self componentsControllers:@[VideoController ...];
...
[_componentHandler handleHybridPageWithContainerScrollView:[[UIScrollView alloc] initWithFrame:self.view.bounds] defaultWebViewClass:[HPKWebViewSubClass class] defaultWebViewIndex:1 webComponentDomClass:@"domClass" webComponentIndexKey:@"domAttrIndex"];
...
[_componentHandler layoutWithWebComponentModels:@[WebVideoModel ...]];
...
[_componentHandler layoutWithComponentModels:@[VideoModel ...];
...
```


## 证书

All source code is licensed under the [MIT License](https://github.com/dequan1331/HybridPageKit/blob/master/LICENSE).
