//
//  ImageController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "ImageController.h"
#import "ImageView.h"
#import "ImageModel.h"

@implementation ImageController

- (BOOL)shouldResponseWithComponentView:(__kindof UIView *)componentView
                         componentModel:(HPKModel *)componentModel{
   return [componentView class] == [ImageView class] && [componentModel class] == [ImageModel class];
}

- (void)scrollViewWillDisplayComponentView:(__kindof UIView *)componentView
    componentModel:(HPKModel *)componentModel{
    [((ImageView *)componentView) layoutWithData:(ImageModel *)componentModel];
}

@end
