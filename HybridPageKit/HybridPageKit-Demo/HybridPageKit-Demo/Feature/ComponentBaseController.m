//
// ComponentBaseController.m
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


#import "ComponentBaseController.h"
#import "WebComponentController.h"
#import "NativeComponentController.h"
#import "NestingWebViewController.h"
#import "NestingBannerController.h"

@interface ComponentBaseController ()

@property (nonatomic, weak, readwrite) UIViewController *viewController;

@end

@implementation ComponentBaseController

- (instancetype)initWithController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        _viewController = controller;
    }
    return self;
}

- (HPKPageHandler *)pageHandler {
    if ([_viewController isKindOfClass:[WebComponentController class]]) {
        return ((WebComponentController *)_viewController).webComponentHandler;
    } else if ([_viewController isKindOfClass:[NativeComponentController class]]) {
        return ((NativeComponentController *)_viewController).componentHandler;
    } else if ([_viewController isKindOfClass:[NestingWebViewController class]]) {
        return ((NestingWebViewController *)_viewController).componentHandler;
    } else if ([_viewController isKindOfClass:[NestingBannerController class]]) {
        return ((NestingBannerController *)_viewController).componentHandler;
    }
    return nil;
}

@end
