//
//  HPKModelProtocol.h
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HPKComponentContext.h"

#define HPKProtocolImp(INDEX,FRAME,VIEWCLS,CTLCLS,CONTEXT,ENABLEPULL)   \
-(NSString *)getUniqueId{return INDEX;}\
-(CGRect)getComponentFrame{return FRAME;}\
-(void)setComponentFrame:(CGRect)frame{FRAME = frame;}\
-(Class)getComponentViewClass{return [VIEWCLS class];}\
-(Class)getComponentControllerClass{return [CTLCLS class];}\
-(__kindof HPKComponentContext *)getCustomContext{return CONTEXT;}\
-(void)setComponentOriginY:(CGFloat)originY{FRAME = CGRectMake(FRAME.origin.x, originY, FRAME.size.width, FRAME.size.height);}\
-(void)setComponentOriginX:(CGFloat)originX{FRAME = CGRectMake(originX, FRAME.origin.y, FRAME.size.width, FRAME.size.height);}\
-(void)setComponentWidth:(CGFloat)width{FRAME = CGRectMake(FRAME.origin.x, FRAME.origin.y, width, FRAME.size.height);}\
-(void)setComponentHeight:(CGFloat)height{FRAME = CGRectMake(FRAME.origin.x, FRAME.origin.y, FRAME.size.width, height);}\
-(BOOL)enablePullToLoad{return ENABLEPULL;}

@protocol HPKModelProtocol
@required
-(NSString *)getUniqueId;
-(void)setComponentFrame:(CGRect)frame;
-(CGRect)getComponentFrame;
-(Class)getComponentViewClass;
-(BOOL)enablePullToLoad;
@optional
-(Class)getComponentControllerClass;
-(__kindof HPKComponentContext *)getCustomContext;
-(void)setComponentOriginX:(CGFloat)originX;
-(void)setComponentOriginY:(CGFloat)originY;
-(void)setComponentWidth:(CGFloat)width;
-(void)setComponentHeight:(CGFloat)height;
@end
