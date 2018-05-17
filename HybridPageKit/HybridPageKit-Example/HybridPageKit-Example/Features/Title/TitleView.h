//
//  TitleView.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//
#import "TitleModel.h"

#define kTitleViewHeight 100.f

@interface TitleView : UIView
-(void)layoutWithData:(TitleModel *)titleModel;
@end
