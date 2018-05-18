//
//  ComponentRendering.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "ComponentRendering.h"
#import "HPKWebViewHandler.h"

@interface ComponentRendering ()
@property(nonatomic,copy,readwrite)NSString *componentIndex;
@property(nonatomic,strong,readwrite)GRMustacheTemplate *template;
@end

@implementation ComponentRendering

- (void)setComponentIndex:(NSString *)index{
    _componentIndex = index;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag
                           context:(GRMustacheContext *)context
                          HTMLSafe:(BOOL *)HTMLSafe
                             error:(NSError **)error{

   HPKModel *HPKObj = [context valueForMustacheKey:_componentIndex];
    
    if (!HPKObj) {
        return @"";
    }
    
    if (!_template) {
        _template = [GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"\
                                                            <div class='%@' style='width:{{width}}px;height:{{height}}px' data-index='{{componentIndex}}'>\
                                                            </div>",HPKWebViewHandlerComponentClass] error:nil];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 16;
    CGFloat height = ceilf([HPKObj getComponentFrame].size.height/[HPKObj getComponentFrame].size.width * width);

    return [_template renderObject:@{@"componentIndex":[HPKObj getUniqueId],@"width":@(width),@"height":@(height)} error:nil] ;
}
@end
