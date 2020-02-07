//
//  CoverViewerView.h
//  CoverViewer
//
//  Created by Gen2 on 2018/11/29.
//  Copyright © 2018年 Gen2. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CoverViewer;

@protocol CoverViewerDelegate <NSObject>

- (NSInteger)coverViewerCount:(CoverViewer *)coverViewer;
- (UIImageView *)coverViewer:(CoverViewer*)coverViewer coverAtIndex:(NSInteger)index;
-(void)passCurrentScrollIndex:(NSInteger)currentIndex;
@end

@interface CoverViewer : UIView

@property (nonatomic, weak) id <CoverViewerDelegate> delegate;

@property (nonatomic, assign) CGFloat leftLimit;
@property (nonatomic, assign) CGFloat rightLimit;

@property (nonatomic, assign) CGFloat contentOffset;

- (void)reloadDatas;
- (UIImageView *)dequeueItemView;

- (void)setContentOffset:(CGFloat)contentOffset animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
