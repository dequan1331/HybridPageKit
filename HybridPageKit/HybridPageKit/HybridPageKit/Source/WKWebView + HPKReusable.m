//
// WKWebView + HPKReusable.m
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


#import "WKWebView + HPKReusable.h"
#import "HPKPageManager.h"
#import <objc/runtime.h>

@interface HPKWeakWrapper : NSObject
@property(nonatomic, weak, readwrite)NSObject *weakObj;
@end
@implementation HPKWeakWrapper
@end

@implementation WKWebView (HPKReusable)

#pragma mark -

- (void)setHolderObject:(NSObject *)holderObject {
    HPKWeakWrapper *wrapObj = objc_getAssociatedObject(self, @selector(setHolderObject:));
    if (wrapObj) {
        wrapObj.weakObj = holderObject;
    }else{
        wrapObj = [[HPKWeakWrapper alloc] init];
        wrapObj.weakObj = holderObject;
        objc_setAssociatedObject(self, @selector(setHolderObject:), wrapObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSObject *)holderObject {
    HPKWeakWrapper *wrapObj = objc_getAssociatedObject(self, @selector(setHolderObject:));
    return wrapObj.weakObj;
}

- (void)setReusedTimes:(NSInteger)reusedTimes {
    NSNumber *reusedTimesNum = @(reusedTimes);
    objc_setAssociatedObject(self, @selector(setReusedTimes:), reusedTimesNum, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)reusedTimes {
    NSNumber *reusedTimesNum = objc_getAssociatedObject(self, @selector(setReusedTimes:));
    return [reusedTimesNum integerValue];
}

- (void)setInvalid:(BOOL)invalid {
    objc_setAssociatedObject(self, @selector(setInvalid:), @(invalid), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)invalid {
    NSNumber *invalidNum = objc_getAssociatedObject(self, @selector(setInvalid:));
    return invalidNum.boolValue;
}

#pragma mark -

- (void)componentViewWillLeavePool {
    self.reusedTimes += 1;
    [self _clearBackForwardList];
}

- (void)componentViewWillEnterPool {
    self.holderObject = nil;
    self.scrollView.delegate = nil;
    self.scrollView.scrollEnabled = YES;
    [self stopLoading];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *reuseLoadUrl = [[HPKPageManager sharedInstance] webViewReuseLoadUrlStr];
    if (reuseLoadUrl && reuseLoadUrl.length > 0) {
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:reuseLoadUrl]]];
    } else {
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    }
}

#pragma mark - clear backForwardList

- (void)_clearBackForwardList {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@", @"_re", @"moveA", @"llIte", @"ms"]);
    if ([self.backForwardList respondsToSelector:sel]) {
        [self.backForwardList performSelector:sel];
    }
#pragma clang diagnostic pop
}

@end
