//
//  ImageView.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "ImageView.h"

@implementation ImageView
-(void)layoutWithData:(ImageModel *)imageModel{
    [self setImage:[UIImage imageNamed:@"iconImage.png"]];
}
@end
