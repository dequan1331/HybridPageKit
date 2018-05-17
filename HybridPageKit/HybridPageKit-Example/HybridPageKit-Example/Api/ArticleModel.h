//
//  ArticleModel.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

@interface ArticleModel : NSObject

@property(nonatomic,copy,readonly)NSString *articleIdStr;

//template
@property(nonatomic,copy,readonly)NSString *contentTemplateString;

//component
@property(nonatomic,strong,readonly)NSArray<HPKModel *> *webViewComponents;
@property(nonatomic,strong,readonly)NSArray<HPKModel *> *extensionComponents;

- (instancetype)initWithDic:(NSDictionary *)dic;
@end
