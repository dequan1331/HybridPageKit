//
// AdModel.m
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

#import "AdModel.h"
#import "AdView.h"
#import "AdController.h"

@interface AdModel ()
@property (nonatomic, copy, readwrite) NSString *imageUrl;
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *desc;
@property (nonatomic, copy, readwrite) AdModelLoadCompletionBlock completionBlock;
@end

@implementation AdModel

IMP_HPKModelProtocol(@(kHPKDemoComponentIndexAd).stringValue);

- (void)dealloc {
    _completionBlock = nil;
}

- (void)getAsyncDataWithCompletionBlock:(AdModelLoadCompletionBlock)completionBlock {
    if (!completionBlock) {
        return;
    }

    _completionBlock = [completionBlock copy];

    NSDictionary *responseDic = nil;
    NSData *contentData = [[NSFileManager defaultManager] contentsAtPath:[[NSBundle mainBundle] pathForResource:@"articleContent" ofType:@"txt"]];
    id obj = [NSJSONSerialization JSONObjectWithData:contentData options:kNilOptions error:nil];
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        responseDic = [(NSDictionary *)obj objectForKey:@"articleAd"];
    }

    self.title = [responseDic objectForKey:@"title"];
    self.desc = [responseDic objectForKey:@"subTitle"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (completionBlock) {
            completionBlock();
        }
    });
}

@end
