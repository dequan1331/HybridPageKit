//
//  HtmlRenderHandler.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HtmlRenderHandler.h"

@interface HtmlRenderHandler ()<GRMustacheTagDelegate>
@property(nonatomic, strong, readwrite) dispatch_queue_t serialQueue;
@property(nonatomic, strong, readwrite)ComponentRendering *componentRendering;
@end

@implementation HtmlRenderHandler

+ (HtmlRenderHandler *)shareInstance{
    static dispatch_once_t once;
    static HtmlRenderHandler *renderHandler = nil;
    dispatch_once(&once,^{
        renderHandler = [[HtmlRenderHandler alloc] init];
    });
    return renderHandler;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String], DISPATCH_QUEUE_SERIAL);
        _componentRendering = [[ComponentRendering alloc] init];
        
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration defaultConfiguration];
        configuration.contentType = GRMustacheContentTypeText;
        configuration.baseContext = [configuration.baseContext contextWithUnsafeKeyAccess];
    }
    return self;
}

- (void)asyncRenderHTMLString:(NSString *)htmlString
               componentArray:(NSArray<HPKModel *> *)componentArray
                completeBlock:(HPKHtmlRenderCompleteBlock)completeBlock{
    dispatch_async(_serialQueue, ^{

        NSError *error;
        
        NSMutableDictionary * componentDic = @{}.mutableCopy;
        for (HPKModel *component in componentArray) {
            [componentDic setObject:component forKey:[component getUniqueId]];
        }
                
        //render html component
        GRMustacheTemplate *htmlTemplate = [GRMustacheTemplate templateFromString:htmlString error:&error];
        [htmlTemplate extendBaseContextWithTagDelegate:self];
        NSString *finalString = [htmlTemplate renderObject:componentDic error:&error];
        
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(finalString,error);
            });
        }
    });
}

#pragma mark -

- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object{
    
    if (![object respondsToSelector:@selector(getUniqueId)]) {
        return nil;
    }

    [_componentRendering setComponentIndex:[object getUniqueId]];
    return _componentRendering;
}

@end
