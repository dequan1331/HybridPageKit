//
// MediaView.m
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


#import "MediaView.h"
@interface MediaView ()
@property (nonatomic, strong, readwrite) CALayer *topLine;
@property (nonatomic, strong, readwrite) UIImageView *mediaIcon;
@property (nonatomic, strong, readwrite) UILabel *mediaName;
@property (nonatomic, strong, readwrite) UILabel *mediaDes;
@end
@implementation MediaView

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
        [self.layer addSublayer:({
            _topLine = [[CALayer alloc]init];
            _topLine.backgroundColor = [UIColor colorWithRed:234.f / 255.f green:234.f / 255.f blue:234.f / 255.f alpha:1.f].CGColor;
            _topLine.frame = CGRectMake(0, 0, frame.size.width, 5);
            _topLine;
        })];
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

- (void)layoutWithData:(MediaModel *)mediaModel {
    _topLine.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 5);

    [_mediaIcon setImage:[UIImage imageNamed:@"icon.png"]];

    [_mediaName setText:mediaModel.mediaName];
    [_mediaName sizeToFit];
    _mediaName.frame = CGRectMake(_mediaIcon.frame.origin.x +  _mediaIcon.frame.size.width + 10, _mediaIcon.frame.origin.y + 7, _mediaName.frame.size.width, _mediaName.frame.size.height);

    [_mediaDes setText:mediaModel.mediaDes];
    [_mediaDes sizeToFit];
    _mediaDes.frame = CGRectMake(_mediaName.frame.origin.x, _mediaName.frame.origin.y + _mediaName.frame.size.height + 10, _mediaDes.frame.size.width, _mediaDes.frame.size.height);
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(_mediaDes.frame) + 20);
}

- (CGFloat)componentHeight{
    return self.frame.size.height;
}

@end
