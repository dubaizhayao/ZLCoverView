//
//  CoverViewerView.m
//  CoverViewer
//
//  Created by Gen2 on 2018/11/29.
//  Copyright © 2018年 Gen2. All rights reserved.
//

#import "CoverViewer.h"
#import "GTween.h"

typedef struct CVRange {
    NSInteger location;
    NSInteger length;
} CVRange;

CVRange CVRangeRange(NSInteger loc, NSInteger len) {
    CVRange r;
    r.location = loc;
    r.length = len;
    return r;
}
@interface CoverViewer ()<UIGestureRecognizerDelegate>
@end

@implementation CoverViewer {
    NSMutableArray  *_displayViews,
                    *_cacheViews;
    CVRange _displayRange;
    NSInteger _totalItems;
    
    CGPoint _oldTrans;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentOffset = 0;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onPan:)];
        [self addGestureRecognizer:pan];
        pan.delegate = self;
        _leftLimit = 3;
        _rightLimit = 3;
        
        [self performSelector:@selector(reloadDatas)
                   withObject:self
                   afterDelay:0];
        
        _cacheViews = [NSMutableArray array];
        _displayViews = [NSMutableArray array];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)reloadDatas {
    for (UIView *view in _displayViews) {
        [view removeFromSuperview];
        [_cacheViews addObject:view];
    }
    [_displayViews removeAllObjects];
    _displayRange = CVRangeRange(0, 0);
    _totalItems = [self.delegate coverViewerCount:self];
    [self updateScrolling];
}

//判断如果是当前view在响应滑动，那么上下方向的滑动被忽略掉，只响应左右方向
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isKindOfClass:[self class]]) {
        
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        
        if (fabs(translation.x)<fabs(translation.y)) {
            //上下方向的滑动
            return NO;
        }
    }
    return YES;
}

//判断，如果是上下方向的滑动，则允许联动，如果是左右方向的滑动，则只允许当前view响应。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
    
    BOOL shouldSimultaneous = NO;
    
    if (fabs(translation.x)<fabs(translation.y)) {
        //上下方向的滑动
        shouldSimultaneous = YES;
    }
    return shouldSimultaneous;
}

- (CGFloat)percentForItemIndex:(NSInteger)index {
    CGFloat off = (index - _contentOffset);
    if (off < 0) {
        return off / _leftLimit;
    }else {
        return off / _rightLimit;
    }
}

- (void)onPan:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            _oldTrans = [pan translationInView:self];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint trans = [pan translationInView:self];
            CGFloat off = ((trans.x - _oldTrans.x) / self.bounds.size.width);
            _oldTrans = trans;
            // TODO 修改这个数值
#define DELTA 2
            off *= DELTA;
            if (_contentOffset < 0 || _contentOffset > _totalItems) {
                off /= 2;
            }
            self.contentOffset -= off;
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self dragEnd:[pan velocityInView:self]];
        }
            
        default:
            break;
    }
}

- (void)updateScrolling {
    NSInteger high = MIN((NSInteger)ceil(_contentOffset + _rightLimit), _totalItems - 1),  low = MAX((NSInteger)floor(_contentOffset - _leftLimit), 0);
    CVRange range = CVRangeRange(low, high - low + 1);
    
    if (range.location != _displayRange.location || range.length != _displayRange.length) {
        NSMutableArray *temp = [NSMutableArray array];
        for (NSInteger i = 0; i < _displayRange.length; ++i) {
            NSInteger index = _displayRange.location + i;
            if (index < range.location || index > (NSInteger)(range.location + range.length) - 1) {
                [temp addObject:[_displayViews objectAtIndex:i]];
            }
        }
        for (UIView *view in temp) {
            [view removeFromSuperview];
            [_cacheViews addObject:view];
            [_displayViews removeObject:view];
        }
        [temp removeAllObjects];
        
        for (NSInteger i = 0; i < range.length; ++i) {
            NSInteger index = range.location + i;
            if (index < _displayRange.location) {
                UIImageView *view = [self.delegate coverViewer:self coverAtIndex:index];
                [self addSubview:view];
                [_displayViews insertObject:view atIndex:0];
            }else if (index > (NSInteger)(_displayRange.location + _displayRange.length) - 1) {
                UIImageView *view = [self.delegate coverViewer:self coverAtIndex:index];
                [self addSubview:view];
                [_displayViews addObject:view];
            }
        }
        _displayRange = range;
    }
    
    for (NSInteger i = 0; i < _displayRange.length; ++i) {
        NSInteger index = _displayRange.location + i;
        [self processView:[_displayViews objectAtIndex:i] atIndex:index];
    }
}

#define RIGHT_SCALE 0.1f

CGFloat makeCurve(CGFloat percent, CGFloat rl) {
    CGFloat p = MAX(MIN(percent, RIGHT_SCALE), 0) / RIGHT_SCALE;
    return RIGHT_SCALE / 4 * p + percent;
}

// TODO 随意取的值 之后完善可以做出更科学的数值
- (void)processView:(UIView *)view atIndex:(NSInteger)index {
    CGFloat percent = [self percentForItemIndex:index];
    if (percent < 0) {
        CGFloat scale = 1 + (0.2 * percent);
        CGAffineTransform trans = CGAffineTransformMakeScale(scale, scale);
        view.transform = CGAffineTransformTranslate(trans, 40 * percent, 0);
        view.alpha = 1 + percent;
    }else {
        CGFloat scale = 1 - 1 * MAX(MIN(percent, RIGHT_SCALE), 0);
        CGAffineTransform trans = CGAffineTransformMakeScale(scale, scale);
        
        view.transform = CGAffineTransformTranslate(trans, (self.bounds.size.width) * makeCurve(percent, _rightLimit), 0);
        view.alpha = 1;
    }
    [view removeFromSuperview];
    [self addSubview:view];
}

- (UIImageView *)dequeueItemView {
    if (_cacheViews.count) {
        id item = _cacheViews.lastObject;
        [_cacheViews removeLastObject];
        return item;
    }
    return nil;
}

- (void)setContentOffset:(CGFloat)contentOffset {
    if (_contentOffset != contentOffset) {
        _contentOffset = contentOffset;
        [self updateScrolling];
    }
}

- (void)dragEnd:(CGPoint)speed {
    CGFloat off = _contentOffset;
    if (speed.x > 100) {
        off = floor(off);
    }else if (speed.x < -100) {
        off = ceil(off);
    }
    NSInteger index = (NSInteger)MAX(0, MIN(_totalItems - 1, round(off)));
    [self setContentOffset:index animated:YES];
    
    [self.delegate passCurrentScrollIndex:index];
}

- (void)setContentOffset:(CGFloat)contentOffset animated:(BOOL)animated {
    if (animated) {
        CGFloat target = MAX(0, MIN(_totalItems - 1, round(contentOffset)));
        [self stopAllTweens];
        GTween *tween = [GTween tween:self duration:0.3 ease:GEaseCubicOut.class];
        [tween addProperty:[GTweenFloatProperty property:@"contentOffset" from:_contentOffset to:target]];
        [tween start];
    }else {
        self.contentOffset = contentOffset;
    }
}

@end
