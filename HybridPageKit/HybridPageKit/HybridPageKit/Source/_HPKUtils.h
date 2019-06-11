//
// _HPKUtils.h
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


#ifndef _HPKUtils_h
#define _HPKUtils_h

#import "HPKPageManager.h"

#define HPKInfoLog(logformat, ...) \
    [[HPKPageManager sharedInstance] logWithErrorLevel:kHPKLogLevelInfo logFormat:(logformat), ## __VA_ARGS__];

#define HPKErrorLog(logformat, ...) \
    [[HPKPageManager sharedInstance] logWithErrorLevel:kHPKLogLevelError logFormat:(logformat), ## __VA_ARGS__];

#define HPKFatalLog(logformat, ...) \
    [[HPKPageManager sharedInstance] logWithErrorLevel:kHPKLogLevelFatal logFormat:(logformat), ## __VA_ARGS__];

@interface HPKPageManager (_utils)
- (void)logWithErrorLevel:(HPKLogLevel)errorLevel logFormat:(NSString *)logFormat, ... NS_FORMAT_FUNCTION(2, 3);
@end

typedef void (^HPKKVOCallback)(NSObject *oldValue, NSObject *newValue);
@interface NSObject (HPKKVO)

- (void)safeAddObserver:(id)observer keyPath:(NSString *)keyPath callback:(HPKKVOCallback)callback;
- (void)safeRemoveObserver:(id)observer keyPath:(NSString *)keyPath;
- (void)safeRemoveAllObserver;
@end

#pragma mark -

#define isiOS13Beta1 \
    ([@"13.0" isEqualToString:[[UIDevice currentDevice] systemVersion]])

#endif /* _HPKUtils_h */
