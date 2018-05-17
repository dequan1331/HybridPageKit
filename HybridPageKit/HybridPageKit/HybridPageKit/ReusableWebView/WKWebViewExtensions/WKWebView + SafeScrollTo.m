//
//  WKWebView + SafeScrollTo.m
//  WKWebViewExtension
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "WKWebView + SafeScrollTo.h"

typedef BOOL (^RunloopUtilsConditionBlock)(void);
typedef void (^RunloopUtilsSuccessBlock)(NSInteger loopTimes);
typedef void (^RunloopUtilsFailBlock)(NSInteger loopTimes);

@interface RunloopUtils : NSObject

@property(nonatomic, assign, readwrite) CFRunLoopObserverRef observer;
@property(nonatomic, assign, readwrite) CFRunLoopRef runLoop;

@property(nonatomic, copy, readwrite) RunloopUtilsConditionBlock conditionBlock;
@property(nonatomic, copy, readwrite) RunloopUtilsSuccessBlock successBlock;
@property(nonatomic, copy, readwrite) RunloopUtilsFailBlock failBlock;

@property(nonatomic, weak, readwrite) id holder;
@property(nonatomic, assign, readwrite) NSInteger maxLoopTimes;
@property(nonatomic, assign, readwrite) NSInteger currentLoopNum;

+ (instancetype)sharedInstance;

- (void)startRunloopCheckWithHolder:(id)holder
                       MaxLoopTimes:(NSInteger)maxLoopTimes
                          condition:(RunloopUtilsConditionBlock)conditionBlock
                       successBlock:(RunloopUtilsSuccessBlock)successBlock
                          failBlock:(RunloopUtilsFailBlock)failedBlock;

- (void)stopRunloopCheckWithHolder:(id)holder;

@end

@implementation RunloopUtils

+ (instancetype)sharedInstance{
    static RunloopUtils *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RunloopUtils alloc]init];
    });
    return sharedInstance;
}

- (void)dealloc {
    if (CFRunLoopContainsObserver(CFRunLoopGetMain(), _observer, kCFRunLoopDefaultMode)) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopDefaultMode);
    }
    if (CFRunLoopObserverIsValid(_observer)) {
        CFRunLoopObserverInvalidate(_observer);
    }
    if (_observer != NULL) {
        CFRelease(_observer);
        _observer = NULL;
    }
    if (_runLoop != NULL) {
        CFRelease(_runLoop);
        _runLoop = NULL;
    }
    _conditionBlock = nil;
    _successBlock = nil;
    _failBlock = nil;
    _holder = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _runLoop = (CFRunLoopRef)CFRetain(CFRunLoopGetMain());
        
        __weak typeof(self) wself = self;
        _observer = CFRunLoopObserverCreateWithHandler(NULL,kCFRunLoopAllActivities,YES,0,
                                                       ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
                __strong __typeof(wself) strongSelf = wself;
                switch (activity) {
                   case kCFRunLoopBeforeWaiting:
                       if (strongSelf.currentLoopNum > strongSelf.maxLoopTimes) {
                           if (self.failBlock) {
                               self.failBlock(self.currentLoopNum);
                           }
                           [strongSelf _stopRetryFunction];
                       } else {
                           if (strongSelf.conditionBlock()) {
                               if (self.successBlock) {
                                   self.successBlock(self.currentLoopNum);
                               }
                               [strongSelf _stopRetryFunction];
                           } else {
                               strongSelf.currentLoopNum++;
                           }
                       }
                       break;
                   default:
                       break;
               }
           });
    }
    return self;
}

- (void)startRunloopCheckWithHolder:(id)holder
                       MaxLoopTimes:(NSInteger)maxLoopTimes
                          condition:(RunloopUtilsConditionBlock)conditionBlock
                       successBlock:(RunloopUtilsSuccessBlock)successBlock
                          failBlock:(RunloopUtilsFailBlock)failBlock{
    
    if (_observer == NULL || _runLoop == NULL) {
        return;
    }
    
    if (CFRunLoopContainsObserver(_runLoop, _observer, kCFRunLoopDefaultMode)) {
        CFRunLoopRemoveObserver(_runLoop, _observer, kCFRunLoopDefaultMode);
        if (self.failBlock) {
            self.failBlock(self.currentLoopNum);
        }
    }
    
    NSParameterAssert(conditionBlock != NULL);
    NSParameterAssert(successBlock != NULL);
    NSParameterAssert(failBlock != NULL);
    NSParameterAssert(holder != nil);
    
    _maxLoopTimes = maxLoopTimes;
    _conditionBlock = [conditionBlock copy];
    _successBlock = [successBlock copy];
    _failBlock = [failBlock copy];
    _currentLoopNum = 1;
    _holder = holder;
    
    [self _beginRetryFunction];
    
}

- (void)stopRunloopCheckWithHolder:(id)holder{
    if (CFRunLoopContainsObserver(CFRunLoopGetMain(), _observer, kCFRunLoopDefaultMode)) {
        if (holder == _holder) {
            [self _stopRetryFunction];
        } else {
        }
    }
}

#pragma mark - private method

- (void)_beginRetryFunction {
    
    if (CFRunLoopContainsObserver(_runLoop, _observer, kCFRunLoopDefaultMode)) {
        CFRunLoopRemoveObserver(_runLoop, _observer, kCFRunLoopDefaultMode);
    }
    
    CFRunLoopAddObserver(_runLoop, _observer, kCFRunLoopDefaultMode);
}

- (void)_stopRetryFunction {
    
    if (CFRunLoopContainsObserver(CFRunLoopGetMain(), _observer, kCFRunLoopDefaultMode)) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopDefaultMode);
    }
    
    _maxLoopTimes = 0;
    _conditionBlock = nil;
    _successBlock = nil;
    _failBlock = nil;
    _currentLoopNum = 1;
    _holder = nil;
}

@end


@implementation WKWebView (SafeScrollTo)

- (void)scrollToOffset:(CGFloat)offset
           maxRunloops:(NSUInteger)maxRunloops
       completionBlock:(SafeScrollToCompletionBlock)completionBlock{
    
    
    if(offset < 0 || maxRunloops <= 0){
        NSLog(@"WKWebView can not scroll to with invalid paras");
        return;
    }
    
    [[RunloopUtils sharedInstance] stopRunloopCheckWithHolder:self];
    
    __weak typeof(self) wself = self;
    [[RunloopUtils sharedInstance] startRunloopCheckWithHolder:self MaxLoopTimes:maxRunloops condition:^BOOL{
        __strong typeof(wself) strongSelf = wself;
        return strongSelf.scrollView.contentSize.height >= offset;
    } successBlock:^(NSInteger loopTimes) {
        __strong typeof(wself) strongSelf = wself;
        [strongSelf.scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
        if(completionBlock){
            completionBlock(YES,loopTimes);
        }
    } failBlock:^(NSInteger loopTimes) {
        if(completionBlock){
            completionBlock(NO,loopTimes);
        }
    }];
}

@end



