//
//  HPKJavascriptUtils.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKJavascriptUtils.h"


@implementation HPKJavascriptUtils
#pragma mark -

+ (NSString *)getWebViewContentHeightWithContainerWidth:(int)width{
    if (width <= 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"document.documentElement.offsetHeight * %d / document.documentElement.clientWidth", width];
}

+ (NSString *)getComponentFrameJsWithDomClass:(NSString *)domClass{
    
    if (!domClass) {
        return nil;
    }
    return [NSString stringWithFormat:@"(function(){var componentFrameDic=[];var list= document.getElementsByClassName('%@');for(var i=0;i<list.length;i++){var dom = list[i];componentFrameDic.push({'index':dom.getAttribute('data-index'),'top':dom.offsetTop,'left':dom.offsetLeft,'width':dom.clientWidth,'height':dom.clientHeight});}return componentFrameDic;}())",domClass];
}


+ (NSString *)setComponentJSWithWithDomClass:(NSString *)domClass
                                       index:(NSString *)index
                               componentSize:(CGSize)componentSize{
    if (!domClass || !index) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"[].forEach.call(document.getElementsByClassName('%@'), function (dom) {if(dom.getAttribute('data-index') == '%@'){dom.style.width='%@px';dom.style.height='%@px';}});", domClass,index,@(componentSize.width),@(componentSize.height)];
}
@end
