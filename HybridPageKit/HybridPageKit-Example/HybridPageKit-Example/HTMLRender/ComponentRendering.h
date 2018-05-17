//
//  ComponentRendering.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "GRMustache.h"

@interface ComponentRendering : NSObject<GRMustacheRendering>
- (void)setComponentIndex:(NSString *)index;
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag
                           context:(GRMustacheContext *)context
                          HTMLSafe:(BOOL *)HTMLSafe
                             error:(NSError **)error;
@end
