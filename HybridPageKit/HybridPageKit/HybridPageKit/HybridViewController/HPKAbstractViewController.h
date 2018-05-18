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

typedef void (^HPKViewConfigBuilderBlock)(HPKViewConfig * defaultConfig);
/**
 *
 */
@interface HPKAbstractViewController : HPKBaseViewController


@property(nonatomic,strong,readonly) HPKViewConfig *viewConfig;

- (instancetype)initWithConfigBuilder:(HPKViewConfigBuilderBlock)viewConfigBuilder;

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
