//
// HPKScrollProcessor.h
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


#import "HPKPageManager.h"
#import "HPKViewProtocol.h"
#import "HPKModelProtocol.h"
#import "HPKControllerProtocol.h"

typedef NSObject<HPKControllerProtocol>* (^HPKScrollProcessorDelegateBlock)(HPKModel *model , BOOL isGetViewEvent);

typedef NS_ENUM (NSInteger, HPKLayoutType) {
    kHPKLayoutTypeAutoCalculateFrame,     //根据ComponentIndex及相应的protocol自动计算
    kHPKLayoutTypeManualCalculateFrame,   //根据ComponentModel中的Frame布局
};
/**
 * 底层页components滚动管理
 */
@interface HPKScrollProcessor : NSObject

#pragma mark -

- (instancetype)initWithScrollView:(__kindof UIScrollView *)scrollView
                        layoutType:(HPKLayoutType)layoutType
               scrollDelegateBlock:(HPKScrollProcessorDelegateBlock)scrollDelegateBlock;

#pragma mark - layout

- (void)relayoutWithComponentFrameChange;
- (void)addComponentModelAndRelayout:(HPKModel *)componentModel;
- (void)removeComponentModelAndRelayout:(HPKModel *)componentModel;
- (void)layoutWithComponentModels:(NSArray <HPKModel *> *)componentModels;

#pragma mark - scroll

- (void)scrollToContentOffset:(CGPoint)toContentOffset animated:(BOOL)animated;
- (void)scrollToComponentView:(HPKView *)componentView atOffset:(CGFloat)offsetY animated:(BOOL)animated;
- (void)scrollToComponentModel:(HPKModel *)componentModel atOffset:(CGFloat)offsetY animated:(BOOL)animated;

#pragma mark - get View or Model

- (NSArray <HPKModel *> *)getAllComponentModels;
- (NSArray <HPKModel *> *)getVisibleComponentModels;
- (NSArray <HPKView *> *)getVisibleComponentViews;

//get model
- (HPKModel *)getComponentModelByComponentView:(HPKView *)componentView;
- (HPKModel *)getComponentModelByIndex:(NSString *)componentIndex;

//get view
- (HPKView *)getComponentViewByComponentModel:(HPKModel *)componentModel;
- (HPKView *)getComponentViewByIndex:(NSString *)componentIndex;

@end
