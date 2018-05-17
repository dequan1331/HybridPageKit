//
//  TitleView.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "TitleView.h"

@interface TitleView ()
@property(nonatomic,strong,readwrite)UILabel *titleLabel;
@property(nonatomic,strong,readwrite)UILabel *timeLabel;
@property(nonatomic,strong,readwrite)CALayer *bottomLine;
@end

@implementation TitleView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            _titleLabel = [[UILabel alloc]init];
            _titleLabel.textColor = [UIColor blackColor];
            _titleLabel.font = [UIFont systemFontOfSize:36.f];
            _titleLabel;
        })];
        
        [self addSubview:({
            _timeLabel = [[UILabel alloc]init];
            _timeLabel.textColor = [UIColor grayColor];
            _timeLabel.font = [UIFont systemFontOfSize:14.f];
            _timeLabel;
        })];
        
        [self.layer addSublayer:({
            _bottomLine = [[CALayer alloc]init];
            _bottomLine.backgroundColor = [UIColor lightGrayColor].CGColor;
            _bottomLine.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
            _bottomLine;
        })];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _bottomLine.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
}

-(void)layoutWithData:(TitleModel *)titleModel{
    
    [_titleLabel setText:titleModel.title];
    [_titleLabel sizeToFit];
    
    [_timeLabel setText:[NSString stringWithFormat:@"%@",[NSDate date]]];
    [_timeLabel sizeToFit];
    _timeLabel.frame = CGRectMake(0, _titleLabel.frame.size.height + 20, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
}
@end
