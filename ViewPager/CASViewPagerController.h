//
//  CASViewPagerController.h
//  ViewPager
//
//  Created by Christian Skogsberg on 14/06/13.
//  Copyright (c) 2013 Christian Skogsberg. All rights reserved.
//


@interface CASViewPagerController : UIViewController <UIScrollViewDelegate> {
}

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated;

@end