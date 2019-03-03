//
// TitleView.m
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


#import "TitleView.h"

@interface TitleView ()
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UILabel *timeLabel;
@end

@implementation TitleView

IMP_HPKViewProtocol()

- (instancetype)initWithFrame:(CGRect)frame {
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
    }
    return self;
}

- (void)layoutWithData:(TitleModel *)titleModel {
    [_titleLabel setText:titleModel.title];
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(8, 20, _titleLabel.frame.size.width, _titleLabel.frame.size.height);

    [_timeLabel setText:[NSString stringWithFormat:@"%@", [NSDate date]]];
    [_timeLabel sizeToFit];
    _timeLabel.frame = CGRectMake(8, _titleLabel.frame.size.height + 30, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(_timeLabel.frame) + 10);
}

- (CGFloat)componentHeight {
    return self.frame.size.height;
}

@end
