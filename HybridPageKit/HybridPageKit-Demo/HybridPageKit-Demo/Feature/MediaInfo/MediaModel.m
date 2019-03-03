//
// MediaModel.m
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


#import "MediaModel.h"
#import "MediaView.h"
#import "MediaController.h"

@interface MediaModel ()
@property (nonatomic, copy, readwrite) NSString *mediaId;
@property (nonatomic, copy, readwrite) NSString *mediaIcon;
@property (nonatomic, copy, readwrite) NSString *mediaName;
@property (nonatomic, copy, readwrite) NSString *mediaDes;
@end
@implementation MediaModel

IMP_HPKModelProtocol(@(kHPKDemoComponentIndexMedia).stringValue);

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _mediaId = [dic objectForKey:@"mediaId"];
        _mediaIcon = [dic objectForKey:@"mediaIcon"];
        _mediaName = [dic objectForKey:@"mediaName"];
        _mediaDes = [dic objectForKey:@"mediaDescribe"];
    }
    return self;
}

@end
