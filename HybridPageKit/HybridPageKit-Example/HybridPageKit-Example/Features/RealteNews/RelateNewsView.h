//
//  RelateNewsView.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#define kRelateNewsViewCellHeight 60.f
#import "RelateNewsModel.h"

@interface RelateNewsView : UIView
-(void)layoutWithData:(RelateNewsModel *)relateNewsModel;
@end
