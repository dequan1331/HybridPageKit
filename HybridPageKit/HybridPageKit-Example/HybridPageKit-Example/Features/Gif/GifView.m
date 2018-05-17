//
//  GifView.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "GifView.h"

@implementation GifView

-(void)layoutWithData:(GifModel *)gifModel{
    self.animationImages = @[[UIImage imageNamed:@"gif1.jpeg"],[UIImage imageNamed:@"gif2.jpeg"]];
    self.animationDuration = 0.5;
}

-(void)startPlay{
    [self startAnimating];
}

-(void)stopPlay{
    [self stopAnimating];
}
@end
