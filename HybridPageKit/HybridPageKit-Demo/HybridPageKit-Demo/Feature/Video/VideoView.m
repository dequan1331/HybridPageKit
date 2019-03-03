//
// VideoView.m
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


#import "VideoView.h"

@interface VideoView()
@property(nonatomic,strong,readwrite)UIImageView *playButton;
@end

@implementation VideoView

IMP_HPKViewProtocol()

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleToFill;
        self.backgroundColor = [UIColor colorWithRed:234.f / 255.f green:234.f / 255.f blue:234.f / 255.f alpha:1.f];

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
    [self setImage:[UIImage imageNamed:@"gif1.jpeg"]];
}

@end
