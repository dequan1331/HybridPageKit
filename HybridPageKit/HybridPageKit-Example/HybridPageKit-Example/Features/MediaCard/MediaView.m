//
//  MediaView.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "MediaView.h"
@interface MediaView()
@property(nonatomic,strong,readwrite)UIImageView * mediaIcon;
@property(nonatomic,strong,readwrite)UILabel * mediaName;
@property(nonatomic,strong,readwrite)UILabel * mediaDes;
@end
@implementation MediaView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:({
            _mediaIcon = [[UIImageView alloc]initWithFrame:CGRectMake(8, 20, 60, 60)];
            _mediaIcon.layer.masksToBounds = YES;
            _mediaIcon.layer.cornerRadius = 30.f;
            _mediaIcon;
        })];
        [self addSubview:({
            _mediaName = [[UILabel alloc]init];
            _mediaName.textColor = [UIColor blackColor];
            _mediaName.font = [UIFont systemFontOfSize:18.f];
            _mediaName;
        })];
        
        [self addSubview:({
            _mediaDes = [[UILabel alloc]init];
            _mediaDes.textColor = [UIColor grayColor];
            _mediaDes.font = [UIFont systemFontOfSize:14.f];
            _mediaDes;
        })];
    }
    return self;
}

-(void)layoutWithData:(MediaModel *)mediaModel{
    [_mediaIcon setImage:[UIImage imageNamed:@"iconImage.png"]];
    
    [_mediaName setText:mediaModel.mediaName];
    [_mediaName sizeToFit];
    _mediaName.frame = CGRectMake( _mediaIcon.frame.origin.x +  _mediaIcon.frame.size.width + 10, _mediaIcon.frame.origin.y +7, _mediaName.frame.size.width, _mediaName.frame.size.height);
    
    [_mediaDes setText:mediaModel.mediaDes];
    [_mediaDes sizeToFit];
    _mediaDes.frame = CGRectMake(_mediaName.frame.origin.x, _mediaName.frame.origin.y + _mediaName.frame.size.height + 10, _mediaDes.frame.size.width, _mediaDes.frame.size.height);
}

@end
