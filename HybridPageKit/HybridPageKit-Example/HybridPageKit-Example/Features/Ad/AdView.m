//
//  AdView.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "AdView.h"

@interface AdView ()
@property(nonatomic,strong,readwrite)UIImageView * adIcon;
@property(nonatomic,strong,readwrite)UILabel * adName;
@property(nonatomic,strong,readwrite)UILabel * adDes;
@end

@implementation AdView

+(CGFloat)getAdViewHeightWithModel:(AdModel *)adModel{
    return 100.f;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        [self addSubview:({
            _adIcon = [[UIImageView alloc]initWithFrame:CGRectMake(8, 20, 60, 60)];
            _adIcon.layer.masksToBounds = YES;
            _adIcon.layer.cornerRadius = 30.f;
            _adIcon;
        })];
        [self addSubview:({
            _adName = [[UILabel alloc]init];
            _adName.textColor = [UIColor blackColor];
            _adName.font = [UIFont systemFontOfSize:18.f];
            _adName;
        })];
        
        [self addSubview:({
            _adDes = [[UILabel alloc]init];
            _adDes.textColor = [UIColor grayColor];
            _adDes.font = [UIFont systemFontOfSize:14.f];
            _adDes;
        })];
    }
    return self;
}

-(void)layoutWithData:(AdModel *)adModel{
    [_adIcon setImage:[UIImage imageNamed:@"iconImage.png"]];
    
    [_adName setText:adModel.title];
    [_adName sizeToFit];
    _adName.frame = CGRectMake( _adIcon.frame.origin.x +  _adIcon.frame.size.width + 10, _adIcon.frame.origin.y +7, _adName.frame.size.width, _adName.frame.size.height);
    
    [_adDes setText:adModel.desc];
    [_adDes sizeToFit];
    _adDes.frame = CGRectMake(_adName.frame.origin.x, _adName.frame.origin.y + _adName.frame.size.height + 10, _adDes.frame.size.width, _adDes.frame.size.height);
}

@end
