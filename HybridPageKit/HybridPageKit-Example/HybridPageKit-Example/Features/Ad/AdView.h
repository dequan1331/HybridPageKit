//
//  AdView.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//
#import "AdModel.h"

@interface AdView : UIView
+(CGFloat)getAdViewHeightWithModel:(AdModel *)adModel;
-(void)layoutWithData:(AdModel *)adModel;
@end
