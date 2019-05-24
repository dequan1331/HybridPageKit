# HybridPageKit

![GitHub](https://img.shields.io/github/license/dequan1331/HybridPageKit.svg)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/HybridPageKit.svg)
![GitHub closed issues](https://img.shields.io/github/issues-closed/dequan1331/HybridPagekit.svg)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/dequan1331/HybridPageKit.svg)

[Extended Reading](https://dequan1331.github.io/index-en.html) | [中文](./README-CN.md) | [扩展阅读](https://dequan1331.github.io/)

>**HybridPageKit** is a easy integration framework for Content pages of News App
>
>Base on the details metioned in [Extended Reading](https://dequan1331.github.io/index-en.html).

<br>
<div>
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Hybrid.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Short.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Banner.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Folded.gif" width="20%">
</div>


## Install

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


##	Features

>	Strongly Recommended to read [iOS News App Content Page Technology Overview](https://dequan1331.github.io/index-en.html)

*	Protocol oriented，dozens of lines of code can be completed hybrid content page of News App.
*	High-extensibility, component-based and POP content page architecture.
*	Use and Extend WKWebView, stable、few bugs、 support more features.
*	Reuse of WKWebView, reuse of component Views.
* 	Convert all non-Text components of WebView into Native. 
*  	High-performance and thread safety.

##	Related Links

*	[iOS News App Content Page Technology Overview](https://dequan1331.github.io/index-en.html)

#	Usage


1. Base on data-template separation data.
					
```json
{
//Content HTML
"articleContent": "<!DOCTYPE html><html><head></head><body><P>TEXTTEXTTEXTTEXTTEXTTEXT</P><P>{{IMG_0}}</P><P>TEXTTEXTTEXTTEXTTEXTTEXT</P><P>{{IMG_1}}</P><P>TEXTTEXTTEXTTEXTTEXTTEXT</P><P>{{IMG_2}}</P><P>The End</P></body></html>",

//non-Text component data of webView
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

//component data of Native Extension area
"articleRelateNews": {
    "index":"1",
    "newsArray" : [
        "Extension Reading area - RelateNews - 1",
        "Extension Reading area - RelateNews - 2",
        "Extension Reading area - RelateNews - 3",
        "Extension Reading area - RelateNews - 4",
    ],
}, 

//component data of Native Extension area
"articleComment": {
    "index":"2",
    "commentArray" : [
        "Comment area - Comment - 1",
        "Comment area - Comment - 2",
        "Comment area - Comment - 3",
        "Comment area - Comment - 4",
    ],
},  
}
```

2. create Model & View

```objc
//Model 
@interface VideoModel : NSObject<HPKModelProtocol>
...
IMP_HPKModelProtocol(@"");

//View 
@interface VideoView : UIImageView<HPKViewProtocol>
...
IMP_HPKViewProtocol()

```

3. create component Controller

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

4. implement simple content page

```objc
...
_componentHandler = [[HPKPageHandler alloc] initWithViewController:self componentsControllers:@[VideoController ...];
...
[_componentHandler handleSingleScrollView:[[UIScrollView alloc] initWithFrame:self.view.bounds]];
...
[_componentHandler layoutWithComponentModels:@[VideoModel ...]];
...
```

5. implement hybrid content page

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

## Licenses

All source code is licensed under the [MIT License](https://github.com/dequan1331/HybridPageKit/blob/master/LICENSE).
