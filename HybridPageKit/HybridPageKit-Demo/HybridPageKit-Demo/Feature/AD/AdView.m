//
// AdView.m
//
// Copyright (c) 2019 dequanzhu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "AdView.h"

@interface AdView ()
@property(nonatomic,strong,readwrite)UIImageView * adIcon;
@property(nonatomic,strong,readwrite)UILabel * adName;
@property(nonatomic,strong,readwrite)UILabel * adDes;
@property (nonatomic, strong, readwrite) CALayer *topLine;
@end

@implementation AdView

IMP_HPKViewProtocol()  

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        [self.layer addSublayer:({
            _topLine = [[CALayer alloc]init];
            _topLine.backgroundColor = [UIColor colorWithRed:234.f / 255.f green:234.f / 255.f blue:234.f / 255.f alpha:1.f].CGColor;
            _topLine;
        })];
        
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
    
    _topLine.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 5);

    [_adIcon setImage:[UIImage imageNamed:@"icon.png"]];
    
    [_adName setText:adModel.title];
    [_adName sizeToFit];
    _adName.frame = CGRectMake( _adIcon.frame.origin.x +  _adIcon.frame.size.width + 10, _adIcon.frame.origin.y +7, _adName.frame.size.width, _adName.frame.size.height);
    
    [_adDes setText:adModel.desc];
    [_adDes sizeToFit];
    _adDes.frame = CGRectMake(_adName.frame.origin.x, _adName.frame.origin.y + _adName.frame.size.height + 10, _adDes.frame.size.width, _adDes.frame.size.height);
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(_adDes.frame) + 20);
}

@end
