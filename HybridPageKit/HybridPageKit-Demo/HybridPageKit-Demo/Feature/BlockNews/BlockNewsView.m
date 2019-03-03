//
// BlockNewsView.m
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


#import "BlockNewsView.h"

@interface BlockNewsView ()
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) CALayer *topLine;

@end

@implementation BlockNewsView

IMP_HPKViewProtocol()

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self.layer addSublayer:({
            _topLine = [[CALayer alloc]init];
            _topLine.backgroundColor = [UIColor colorWithRed:234.f / 255.f green:234.f / 255.f blue:234.f / 255.f alpha:1.f].CGColor;
            _topLine.frame = CGRectMake(0, 0, frame.size.width, 5);
            _topLine;
        })];
        
        [self addSubview:({
            _titleLabel = [[UILabel alloc]init];
            _titleLabel.textColor = [UIColor blackColor];
            _titleLabel.font = [UIFont systemFontOfSize:20.f];
            _titleLabel;
        })];
    }
    return self;
}

- (void)layoutWithTitle:(NSString *)title {
    [_titleLabel setText:title];
    [_titleLabel sizeToFit];
    _titleLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _topLine.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 5);
}

#pragma mark -

- (CGFloat)componentHeight{
    return self.frame.size.height;
}

@end
