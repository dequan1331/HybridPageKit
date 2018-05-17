//
//  WKWebView + DeleteMenuItems.m
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "WKWebView + DeleteMenuItems.h"
#import <objc/runtime.h>

@implementation WKWebView (DeleteMenuItems)
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

                          IMP originalIMP = method_getImplementation(class_getInstanceMethod(cls,fixSel));
                          BOOL (*originalImplementation_)(__unsafe_unretained id, SEL, SEL, id);

                          IMP newIMP = imp_implementationWithBlock( ^ BOOL (__unsafe_unretained id self, SEL action, id sender){
                              if (action == @selector(cut:) || action == @selector(copy:) ||
                                  action == @selector(paste:) || action == @selector(delete:)) {
                                  return ((__typeof(originalImplementation_))originalIMP)(self, fixSel,action, sender);
                              } else {
                                  return NO;
                              }
                          });

                          class_replaceMethod(cls, fixSel, newIMP,  method_getTypeEncoding(method));
                      } else {
                          NSLog(@"WKWebView (DeleteMenuItems) can not find valid class");
                      }
                  });
}
@end
