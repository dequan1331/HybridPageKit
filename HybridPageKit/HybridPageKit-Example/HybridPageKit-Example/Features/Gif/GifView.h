//
//  GifView.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//
#import "GifModel.h"

@interface GifView : UIImageView

-(void)layoutWithData:(GifModel *)gifModel;
-(void)startPlay;
-(void)stopPlay;
@end
