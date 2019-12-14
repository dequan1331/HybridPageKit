//
// WKWebView + HPKExtension.m
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


#import "WKWebView + HPKExtension.h"
#import "_HPKUtils.h"
#import <objc/runtime.h>

@interface WKWebView ()
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NSString *> *cookieDic;
@end

@implementation WKWebView (HPKExtension)

#pragma mark - safe evaluate js

- (void)_safeAsyncEvaluateJavaScriptString:(NSString *)script {
    [self _safeAsyncEvaluateJavaScriptString:script completionBlock:nil];
}

- (void)_safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(_HPKWebViewJSCompletionBlock)block {
    
    if(![[NSThread currentThread] isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            //retain self
            __unused __attribute__((objc_ownership(strong))) __typeof__(self) self_retain_ = self;
            [self _safeAsyncEvaluateJavaScriptString:script completionBlock:block];
        });
        return;
    }
    
    if (!script || script.length <= 0) {
        HPKErrorLog(@"invalid script");
        if (block) {
            block(@"");
        }
        return;
    }

    [self evaluateJavaScript:script
           completionHandler:^(id result, NSError *_Nullable error) {
        //retain self
        __unused __attribute__((objc_ownership(strong))) __typeof__(self) self_retain_ = self;
               
        if (!error) {
            if (block) {
                NSObject *resultObj = @"";
                if (!result || [result isKindOfClass:[NSNull class]]) {
                    resultObj = @"";
                } else if ([result isKindOfClass:[NSNumber class]]) {
                    resultObj = ((NSNumber *)result).stringValue;
                } else if ([result isKindOfClass:[NSObject class]]){
                    resultObj = (NSObject *)result;
                } else {
                    HPKFatalLog(@"evaluate js return type:%@, js:%@",
                             NSStringFromClass([result class]),
                             script);
                }
                if (block) {
                    block(resultObj);
                }
            }
        } else {
            HPKErrorLog(@"evaluate js Error : %@ %@", error.description, script);
            if (block) {
                block(@"");
            }
        }
    }];
}

#pragma mark - Cookies

- (void)setCookieDic:(NSMutableDictionary *)cookieDic {
    objc_setAssociatedObject(self, @selector(setCookieDic:), cookieDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)cookieDic {
    return objc_getAssociatedObject(self, @selector(setCookieDic:));;
}

- (void)_setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expiresDate:(NSDate *)expiresDate
          completionBlock:(_HPKWebViewJSCompletionBlock)completionBlock {
    if (!name || name.length <= 0) {
        return;
    }

    NSMutableString *cookieScript = [[NSMutableString alloc] init];
    [cookieScript appendFormat:@"document.cookie='%@=%@;", name, value];
    if (domain || domain.length > 0) {
        [cookieScript appendFormat:@"domain=%@;", domain];
    }
    if (path || path.length > 0) {
        [cookieScript appendFormat:@"path=%@;", path];
    }
    
    if (!self.cookieDic) {
        self.cookieDic = @{}.mutableCopy;
    }

    [[self cookieDic] setValue:cookieScript.copy forKey:name];

    if (expiresDate && [expiresDate timeIntervalSince1970] != 0) {
        [cookieScript appendFormat:@"expires='+(new Date(%@).toUTCString());", @(([expiresDate timeIntervalSince1970]) * 1000)];
    }else{
        [cookieScript appendFormat:@"'"];
    }
    [cookieScript appendFormat:@"\n"];

    [self _safeAsyncEvaluateJavaScriptString:cookieScript.copy completionBlock:completionBlock];
}

- (void)_deleteCookiesWithName:(NSString *)name completionBlock:(_HPKWebViewJSCompletionBlock)completionBlock {
    if (!name || name.length <= 0) {
        return;
    }

    if (![[[self cookieDic] allKeys] containsObject:name]) {
        return;
    }

    NSMutableString *cookieScript = [[NSMutableString alloc] init];

    [cookieScript appendString:[[self cookieDic] objectForKey:name]];
    [cookieScript appendFormat:@"expires='+(new Date(%@).toUTCString());\n", @(0)];

    [[self cookieDic] removeObjectForKey:name];
    [self _safeAsyncEvaluateJavaScriptString:cookieScript.copy completionBlock:completionBlock];
}

- (NSSet<NSString *> *)_getAllCustomCookiesName {
    return [[self cookieDic] allKeys].copy;
}

- (void)_deleteAllCustomCookies {
    for (NSString *cookieName in [[self cookieDic] allKeys]) {
        [self _deleteCookiesWithName:cookieName completionBlock:nil];
    }
}

#pragma mark - UA

+ (void)configCustomUAWithType:(ConfigUAType)type
                      UAString:(NSString *)customString {
    if (!customString || customString.length <= 0) {
        HPKErrorLog(@"WKWebView (SyncConfigUA) config with invalid string");
        return;
    }

    if (type == kConfigUATypeReplace) {
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:customString, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    } else if (type == kConfigUATypeAppend) {
        
        //同步获取webview UserAgent
        NSString *originalUserAgent;
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        SEL privateUASel = NSSelectorFromString([[NSString alloc] initWithFormat:@"%@%@%@",@"_",@"user",@"Agent"]);
        if ([webView respondsToSelector:privateUASel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            originalUserAgent = [webView performSelector:privateUASel];
#pragma clang diagnostic pop
        }
        
        NSString *appUserAgent =
            [NSString stringWithFormat:@"%@-%@", originalUserAgent, customString];
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:appUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    } else {
        HPKErrorLog(@"WKWebView (SyncConfigUA) config with invalid type :%@", @(type));
    }
}

#pragma mark - clear webview cache

static inline void clearWebViewCacheFolderByType(NSString *cacheType) {
    static dispatch_once_t once;
    static NSDictionary *cachePathMap = nil;
    dispatch_once(&once,
                  ^{
        NSString *bundleId = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleIdentifierKey];
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        NSString *storageFileBasePath = [libraryPath stringByAppendingPathComponent:
                                         [NSString stringWithFormat:@"WebKit/%@/WebsiteData/", bundleId]];
        cachePathMap = @{ @"WKWebsiteDataTypeCookies":
                          [libraryPath stringByAppendingPathComponent:@"Cookies/Cookies.binarycookies"],
                          @"WKWebsiteDataTypeLocalStorage":
                          [storageFileBasePath stringByAppendingPathComponent:@"LocalStorage"],
                          @"WKWebsiteDataTypeIndexedDBDatabases":
                          [storageFileBasePath stringByAppendingPathComponent:@"IndexedDB"],
                          @"WKWebsiteDataTypeWebSQLDatabases":
                          [storageFileBasePath stringByAppendingPathComponent:@"WebSQL"] };
    });
    NSString *filePath = cachePathMap[cacheType];
    if (filePath && filePath.length > 0) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                HPKErrorLog(@"removed file fail: %@ ,error %@", [filePath lastPathComponent], error);
            }
        }
    }
}

+ (void)safeClearAllCacheIncludeiOS8:(BOOL)includeiOS8 {
    if (@available(iOS 9, *)) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                       WKWebsiteDataTypeMemoryCache,
                                       WKWebsiteDataTypeSessionStorage,
                                       WKWebsiteDataTypeDiskCache,
                                       WKWebsiteDataTypeOfflineWebApplicationCache,
                                       WKWebsiteDataTypeCookies,
                                       WKWebsiteDataTypeLocalStorage,
                                       WKWebsiteDataTypeIndexedDBDatabases,
                                       WKWebsiteDataTypeWebSQLDatabases
        ]];

        NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                                   modifiedSince:date
                                               completionHandler:^{
            HPKInfoLog(@"Clear All Cache Done");
        }];
    } else {
        if (includeiOS8) {
            NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                           @"WKWebsiteDataTypeCookies",
                                           @"WKWebsiteDataTypeLocalStorage",
                                           @"WKWebsiteDataTypeIndexedDBDatabases",
                                           @"WKWebsiteDataTypeWebSQLDatabases"
            ]];
            for (NSString *type in websiteDataTypes) {
                clearWebViewCacheFolderByType(type);
            }
        }
    }
}

#pragma mark - fix menu items

+ (void)fixWKWebViewMenuItems {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
        Class cls = NSClassFromString([NSString stringWithFormat:@"%@%@%@%@", @"W", @"K", @"Content", @"View"]);
        if (cls) {
            SEL fixSel = @selector(canPerformAction:withSender:);
            Method method = class_getInstanceMethod(cls, fixSel);

            NSCAssert(NULL != method,
                      @"Selector %@ not found in %@ methods of class %@.",
                      NSStringFromSelector(fixSel),
                      class_isMetaClass(cls) ? @"class" : @"instance",
                      cls);

            IMP originalIMP = method_getImplementation(class_getInstanceMethod(cls, fixSel));
            BOOL (*originalImplementation_)(__unsafe_unretained id, SEL, SEL, id);

            IMP newIMP = imp_implementationWithBlock( ^BOOL (__unsafe_unretained id self, SEL action, id sender) {
                if (action == @selector(cut:) || action == @selector(copy:) ||
                    action == @selector(paste:) || action == @selector(delete:)) {
                    return ((__typeof(originalImplementation_))originalIMP)(self, fixSel, action, sender);
                } else {
                    return NO;
                }
            });

            class_replaceMethod(cls, fixSel, newIMP,  method_getTypeEncoding(method));
        } else {
            HPKErrorLog(@"WKWebView (DeleteMenuItems) can not find valid class");
        }
    });
}

+ (void)disableWebViewDoubleClick{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      Class cls = NSClassFromString([NSString stringWithFormat:@"%@%@%@%@", @"W", @"K", @"Content", @"View"]);
                      if (cls) {
                          SEL fixSel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@", @"_non", @"Blocking", @"DoubleTap", @"Recognized:"]);
                          Method method = class_getInstanceMethod(cls, fixSel);
                          
                          NSCAssert(NULL != method,
                                    @"Selector %@ not found in %@ methods of class %@.",
                                    NSStringFromSelector(fixSel),
                                    class_isMetaClass(cls) ? @"class" : @"instance",
                                    cls);
                          
                          IMP newIMP = imp_implementationWithBlock( ^void(id _self, UITapGestureRecognizer *gestureRecognizer) {
                              // do nothing
                          });
                          class_replaceMethod(cls, fixSel, newIMP,  method_getTypeEncoding(method));
                      } else {
                          HPKErrorLog(@"WKWebView (doubleClick) can not find valid class");
                      }
                  });
}


@end
