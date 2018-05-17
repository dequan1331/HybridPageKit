//
//  TitleController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "TitleController.h"
#import "TitleView.h"
#import "TitleModel.h"

@implementation TitleController
-(BOOL)shouldResponseWithComponentView:(__kindof UIView *)componentView
                         componentModel:(HPKModel *)componentModel{
    return [componentView class] == [TitleView class] && [componentModel class] == [TitleModel class];
}
- (void)scrollViewWillPrepareComponentView:(__kindof UIView *)componentView
                            componentModel:(HPKModel *)componentModel{
    [((TitleView *)componentView) layoutWithData:(TitleModel *)componentModel];
}

@end
