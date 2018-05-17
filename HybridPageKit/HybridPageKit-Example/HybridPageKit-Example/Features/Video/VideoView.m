//
//  VideoView.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "VideoView.h"

@interface VideoView()
@property(nonatomic,strong,readwrite)UIImageView *playButton;
@end

@implementation VideoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            UIImage *playButton = [UIImage imageNamed:@"play.png"];
            _playButton = [[UIImageView alloc]initWithImage:playButton];
            _playButton.frame = CGRectMake(0, 0, playButton.size.width/2, playButton.size.height/2);
            _playButton.center = CGPointMake(frame.size.width/2, frame.size.height/2);
            _playButton;
        })];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _playButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

-(void)layoutWithData:(VideoModel *)videoModel{
    [self setImage:[UIImage imageNamed:@"iconImage.png"]];
}

@end
