//
//  HPKDealgateDispatcher.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HPKDealgateDispatcher.h"

@interface HPKDealgateDispatcher()

@property(nonatomic,readwrite,weak)NSObject <UIScrollViewDelegate>* internalDelegate;
@property(nonatomic,readwrite,weak)NSObject <UIScrollViewDelegate>* externalDelegate;

@end

@implementation HPKDealgateDispatcher

- (instancetype)initWithInternalDelegate:(__weak NSObject <UIScrollViewDelegate>*)internalDelegate
                        externalDelegate:(__weak NSObject <UIScrollViewDelegate>*)externalDelegate{
    
    self = [super init];
    if (self) {
        _internalDelegate = internalDelegate;
        _externalDelegate = externalDelegate;
    }
    return self;
}

- (void)dealloc{
    _internalDelegate = nil;
    _externalDelegate = nil;
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewDidScroll:scrollView];
    }
    
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewDidZoom:scrollView];
    }
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewDidZoom:scrollView];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewWillBeginDragging:scrollView];
    }
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewWillBeginDragging:scrollView];
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewWillBeginDecelerating:scrollView];
    }
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewDidEndDecelerating:scrollView];
    }
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        return  [_internalDelegate viewForZoomingInScrollView:scrollView];
    }
    
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        return  [_externalDelegate viewForZoomingInScrollView:scrollView];
    }
    
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        return  [_internalDelegate scrollViewShouldScrollToTop:scrollView];
    }
    
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        return  [_externalDelegate scrollViewShouldScrollToTop:scrollView];
    }
    
    return YES;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if (_internalDelegate && [_internalDelegate respondsToSelector:_cmd]) {
        [_internalDelegate scrollViewDidScrollToTop:scrollView];
    }
    if (_externalDelegate && [_externalDelegate respondsToSelector:_cmd]) {
        [_externalDelegate scrollViewDidScrollToTop:scrollView];
    }
}
@end
