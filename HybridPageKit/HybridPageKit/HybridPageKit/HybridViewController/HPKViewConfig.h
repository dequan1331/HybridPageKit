//
//  HPKViewConfig.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPKViewConfig : NSObject

/**
 *  Auto scroll to this position when finish load page.
 *  Default is Zero
 */
@property(nonatomic,assign,readwrite) CGFloat lastReadPostion;

/**
 *  Max waitting runloops when auto scroll to last read position.
 *  Default is 50
 */
@property(nonatomic,assign,readwrite) CGFloat scrollWaitMaxRunloops;

/**
 *  Native extension components gap.
 *  Default is 10px
 */
@property(nonatomic,assign,readwrite) CGFloat componentsGap;

/**
 *  Scroll workRange
 *  Default is [UIScreen mainScreen].bounds.size.height/2
 */
@property(nonatomic,assign,readwrite) CGFloat scrollWorkRange;

/**
 *  webView Component PlaceHolder Dom Class string
 */
@property(nonatomic,copy,readwrite)NSString *webViewComponentPlaceHolderDomClass;

/**
 *  webview add custom script
 */
@property(nonatomic,copy,readwrite)NSArray<NSString *> *documentStartScriptArray;
@property(nonatomic,copy,readwrite)NSArray<NSString *> *documentEndScriptArray;

/**
 *  whether the controller include webview
 */
@property(nonatomic,assign,readwrite)BOOL needWebView;

@end
