//
//  MediaController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "MediaController.h"
#import "MediaModel.h"
#import "MediaView.h"

@implementation MediaController
-(BOOL)shouldResponseWithComponentView:(__kindof UIView *)componentView
                         componentModel:(HPKModel *)componentModel{
    return [componentView class] == [MediaView class] && [componentModel class] == [MediaModel class];
}

- (void)scrollViewWillDisplayComponentView:(__kindof UIView *)componentView
                            componentModel:(HPKModel *)componentModel{
   [((MediaView *)componentView) layoutWithData:(MediaModel *)componentModel];
}
@end
