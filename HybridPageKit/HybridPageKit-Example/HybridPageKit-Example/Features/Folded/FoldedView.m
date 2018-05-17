//
//  FoldedView.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "FoldedView.h"
#import "FoldedModel.h"

@interface FoldedView()

@property(nonatomic,strong,readwrite)UILabel *label;
@property(nonatomic,strong,readwrite)UIButton *button;
@property(nonatomic,copy,readwrite)FoldedViewClickBlock clickBlock;
@property(nonatomic,assign,readwrite)BOOL isExpend;
@end

@implementation FoldedView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _isExpend = NO;
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:({
            _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100.f)];
            _label.backgroundColor = [UIColor whiteColor];
            _label.textAlignment = NSTextAlignmentCenter;
            _label.numberOfLines = 0;
            _label.font = [UIFont systemFontOfSize:30.f];
            _label.textColor = [UIColor colorWithRed:28.f/255.f green:135.f/255.f blue:219.f/255.f alpha:1.f];
            _label;
        })];
        
        [self addSubview:({
            _button = [[UIButton alloc]initWithFrame:CGRectMake(0, 100.f, [UIScreen mainScreen].bounds.size.width, 30.f)];
            _button.backgroundColor = [UIColor colorWithRed:28.f/255.f green:135.f/255.f blue:219.f/255.f alpha:1.f];
            [_button setTitle:@"click to expend !" forState:UIControlStateNormal];
            _button.titleLabel.textColor = [UIColor colorWithRed:28.f/255.f green:135.f/255.f blue:219.f/255.f alpha:1.f];
            [_button addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
            _button;
        })];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _label.center = self.center;
    _button.frame = CGRectMake(_button.frame.origin.x, frame.size.height - _button.frame.size.height, _button.frame.size.width, _button.frame.size.height);
}

-(void)layoutWithData:(FoldedModel *)foldedModel
           clickBlock:(FoldedViewClickBlock)clickBlock{
    _label.text = foldedModel.text;
    _clickBlock = [clickBlock copy];
}

#pragma mark -

-(void)onClick{
    if (_isExpend) {
        [_button setTitle:@"click to expend !" forState:UIControlStateNormal];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, kFoldedViewFoldedHeight);
    }else{
        [_button setTitle:@"click to folded !" forState:UIControlStateNormal];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, kFoldedViewExpendHeight);
    }
    _isExpend = !_isExpend;
    _clickBlock(self.frame.size.height);
}

@end
