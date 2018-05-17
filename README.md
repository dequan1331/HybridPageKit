# HybridPageKit

[Extended Reading](https://dequan1331.github.io/index-en.html) | [中文](./README-CN.md) | [扩展阅读](https://dequan1331.github.io/)

>**HybridPageKit** is a easy integration framework for Content pages of News App
>
>Base on [ReusableNestingScrollview](https://github.com/dequan1331/ReusableNestingScrollview)、[WKWebViewExtension](https://github.com/dequan1331/WKWebViewExtension)、and the details metioned in [Extended Reading](https://dequan1331.github.io/index-en.html).

<br>
<div>
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Hybrid.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Short.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Banner.gif" width="20%">
<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/Folded.gif" width="20%">
</div>


## Install

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


##	Features

>	Strongly Recommended to read [iOS News App Content Page Technology Overview](https://dequan1331.github.io/index-en.html)

*	Easy integration，dozens of lines of code can be completed hybrid content page of News App.
*	High-extensibility, component-based and POP content page architecture.
*	Use and Extend WKWebView, stable、few bugs、 support more features.
*	Reuse of WKWebView, reuse of component Views.
* 	Convert all non-Text components of WebView into Native. 
*  	High-performance and thread safety.

##	Sub repo

*	[WKWebViewExtension](https://github.com/dequan1331/WKWebViewExtension) : An extension for WKWebView. Providing menuItems delete 、support protocol 、clear cache of iOS8 and so on.
* 	[ReusableNestingScrollview](https://github.com/dequan1331/ReusableNestingScrollview) : An scrollView handler for UIScrollView & WKWebView and other scrollViews. Providing scrollview`s subViews reusable.
*	[iOS News App Content Page Technology Overview](https://dequan1331.github.io/index-en.html)

#	Usage


1.Base on data-template separation data.
					
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

2.create Model & View & Controller of component

```objc
//component model implement RNSModelProtocol 
@interface ImageModel :  NSObject<RNSModelProtocol>
@end
@implementation ImageModel
RNSProtocolImp(_index,_frame, ImageView, ImageController, nil);
@end

//component view
@interface ImageView : UIImageView
@end

//component controller implement HPKComponentControllerDelegate
@interface ImageController : NSObject<HPKComponentControllerDelegate>
@end
@implementation ImageController
	//optional implement method of delegate
@end
```

3.conteng page inherit HPKViewController、simple config and registe component controller
```objc
@interface HybridViewController : HPKViewController
@end

@implementation HybridViewController
//return component controller
- (NSArray<NSObject<HPKComponentControllerDelegate> *> *)getValidComponentControllers{
    return @[
             [[ImageController alloc]init],
             ];
}
@end
```

5.render page

```objc

- (void)setArticleDetailModel:(NSObject *)model                              //data
                 htmlTemplate:(NSString *)htmlTemplate                       //html template
      webviewExternalDelegate:(id<WKNavigationDelegate>)externalDelegate     //WebView external delegate，maybe self
            webViewComponents:(NSArray<NSObject<RNSModelProtocol> *> *)webViewComponents        //component models in webView
          extensionComponents:(NSArray<NSObject<RNSModelProtocol> *> *)extensionComponents;     //component models in native extension area

```

## Licenses

All source code is licensed under the [MIT License](https://github.com/dequan1331/HybridPageKit/blob/master/LICENSE).

## Contact

<img src="https://raw.githubusercontent.com/dequan1331/HybridPageKit/master/README-IMAGE/contact.png">


