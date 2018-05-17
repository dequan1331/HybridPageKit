//
//  FoldedController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "FoldedController.h"
#import "HPKAbstractViewController.h"
#import "FoldedView.h"
#import "FoldedModel.h"

@interface FoldedController()
@property(nonatomic,weak,readwrite) __kindof HPKAbstractViewController *controller;
@property(nonatomic,weak,readwrite)FoldedModel *foldedModel;
@end

@implementation FoldedController

-(BOOL)shouldResponseWithComponentView:(__kindof UIView *)componentView
                        componentModel:(HPKModel *)componentModel{
    return [componentView class] == [FoldedView class] && [componentModel class] == [FoldedModel class];
}

- (void)controllerInit:(__kindof HPKAbstractViewController *)controller{
    _controller = controller;
}

- (void)scrollViewWillPrepareComponentView:(__kindof UIView *)componentView
                            componentModel:(HPKModel *)componentModel{
    
    _foldedModel = (FoldedModel *)componentModel;
    
    __weak typeof(self) wself = self;
    [((FoldedView *)componentView) layoutWithData:_foldedModel clickBlock:^(CGFloat height) {
        __strong __typeof(wself) strongSelf = wself;
        [strongSelf.foldedModel setComponentHeight:height];
        [strongSelf.controller reLayoutExtensionComponents];
    }];
}

@end
