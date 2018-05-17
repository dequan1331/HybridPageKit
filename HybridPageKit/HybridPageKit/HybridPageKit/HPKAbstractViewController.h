//
//  HPKAbstractViewController.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "HPKBaseViewController.h"
#import "HPKViewConfig.h"

typedef NS_ENUM(NSInteger,HPKViewControllerType){
    kHPKViewControllerTypeHybrid,       // webView area + native Extension area
    kHPKViewControllerTypeNative,       // only native Extension area
};

/**
 *
 */
@interface HPKAbstractViewController : HPKBaseViewController


@property(nonatomic,strong,readwrite) HPKViewConfig *viewConfig;


- (instancetype)initWithType:(HPKViewControllerType)type;


#pragma mark -

- (NSArray<HPKController *> *)getValidComponentControllers;

#pragma mark -  set data and render

// hybrid view controller
- (void)setArticleDetailModel:(NSObject *)model
                 htmlTemplate:(NSString *)htmlTemplate
      webviewExternalDelegate:(id<WKNavigationDelegate>)externalDelegate
            webViewComponents:(NSArray<HPKModel *> *)webViewComponents
          extensionComponents:(NSArray<HPKModel *> *)extensionComponents;

// banner view controller & components view controller
- (void)setArticleDetailModel:(NSObject *)model
               topInsetOffset:(CGFloat)topInsetOffset
          extensionComponents:(NSArray<HPKModel *> *)extensionComponents;


#pragma mark - layout
- (void)reLayoutWebViewComponentsWithIndex:(NSString *)index
                             componentSize:(CGSize)componentSize;
- (void)reLayoutWebViewComponents;

- (void)reLayoutExtensionComponents;


@end
