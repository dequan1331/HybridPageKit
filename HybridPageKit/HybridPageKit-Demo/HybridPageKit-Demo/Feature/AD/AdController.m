//
// AdController.m
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

#import "AdController.h"
#import "ArticleModel.h"
#import "AdModel.h"
#import "AdView.h"

@interface AdController ()
@property (nonatomic, strong, readwrite) AdModel *adModel;
@end

@implementation AdController

- (nullable NSArray<Class> *)supportComponentModelClass {
    return @[[AdModel class]];
}

- (nullable Class)reusableComponentViewClassWithModel:(HPKModel *)componentModel {
    return [AdView class];
}

- (void)didReceiveArticleContent:(ArticleModel *)articleModel {
    _adModel = [[AdModel alloc] init];

    __weak typeof(self)wself = self;
    [_adModel getAsyncDataWithCompletionBlock:^{
        __strong __typeof(wself) strongSelf = wself;
        [strongSelf.pageHandler layoutWithAddComponentModel:strongSelf.adModel];
    }];
}

- (void)scrollViewWillPrepareComponentView:(HPKView *)componentView
                            componentModel:(HPKModel *)componentModel {
    [((AdView *)componentView) layoutWithData:(AdModel *)componentModel];

    [((AdModel *)componentModel) setComponentFrame:CGRectMake(0, 0, componentView.frame.size.width, componentView.frame.size.height)];
    [self.pageHandler relayoutWithComponentChange];
}

@end
