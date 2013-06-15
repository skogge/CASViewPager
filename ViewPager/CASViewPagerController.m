//
//  CASViewPagerController.h
//  ViewPager
//
//  Created by Christian Skogsberg on 14/06/13.
//  Copyright (c) 2013 Christian Skogsberg. All rights reserved.
//

#import "CASViewPagerController.h"

#define kAnimationDuration 0.3f
#define kTagOffset 1000
#define kTabBarHeight 44.0f
#define kIndicatorHeight 8.0f
#define kTabBarTopHeight 2.0f
#define kDividerMargin 18.0f
#define kTabButtonMaxWidth 124.0f
#define kTabIndicatorColor @"#99cc00"

@implementation CASViewPagerController
{
	UIScrollView *_tabButtonsContainerView;
	UIScrollView *_contentContainerView;
    UIView *_indicatorView;
    UIView *_tabBarTopView;
    BOOL _lockPageChange;
}

#pragma mark -
#pragma mark Lifecycle
- (void)viewDidLoad
{
	[super viewDidLoad];
    self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CGRect rect = CGRectMake(0, (self.view.bounds.size.height)-kTabBarHeight, self.view.bounds.size.width, kTabBarHeight);
	_tabButtonsContainerView = [[UIScrollView alloc] initWithFrame:rect];
	_tabButtonsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    _tabButtonsContainerView.bounces = YES;
    UIImage *image = [[UIImage imageNamed:@"tab_unselected"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    [_tabButtonsContainerView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    _tabButtonsContainerView.showsHorizontalScrollIndicator = NO;
    _tabButtonsContainerView.multipleTouchEnabled = NO;
    _tabButtonsContainerView.exclusiveTouch = YES;
	_tabButtonsContainerView.scrollsToTop = NO;
    
    CGRect containerRect = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.frame.size.width, self.view.frame.size.height - kTabBarHeight);
	_contentContainerView = [[UIScrollView alloc] initWithFrame:containerRect];
	_contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    _contentContainerView.autoresizesSubviews = YES;
    _contentContainerView.backgroundColor = [UIColor clearColor];
    _contentContainerView.canCancelContentTouches = NO;
    _contentContainerView.showsHorizontalScrollIndicator = NO;
    _contentContainerView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _contentContainerView.clipsToBounds = YES;
    _contentContainerView.scrollEnabled = YES;
    _contentContainerView.pagingEnabled = YES;
    _contentContainerView.delegate = self;
    
    
	[self.view addSubview:_contentContainerView];
    [self.view addSubview:_tabButtonsContainerView];
	[self reloadTabButtons];
    [self reloadPages];
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self layoutTabButtons];
    [self setSelectedButton:_selectedIndex];
    [_tabButtonsContainerView bringSubviewToFront:_indicatorView];
    [_tabButtonsContainerView bringSubviewToFront:_tabBarTopView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Only rotate if all child view controllers agree on the new orientation.
	for (UIViewController *viewController in self.viewControllers)
	{
		if (![viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation])
			return NO;
	}
	return YES;
}

#pragma mark -
#pragma mark ViewControllers
- (void)setViewControllers:(NSArray *)newViewControllers
{
	NSAssert([newViewControllers count] >= 2, @"This controller requires at least two view controllers");
    
	// Remove the old child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[viewController willMoveToParentViewController:nil];
		[viewController removeFromParentViewController];
	}
    
	_viewControllers = [newViewControllers copy];
    
	// Add the new child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[self addChildViewController:viewController];
		[viewController didMoveToParentViewController:self];
	}
    
    
	if ([self isViewLoaded])
    {
		[self reloadTabButtons];
        [self reloadPages];
    }
}

- (void)selectTabButton:(UIButton *)button
{
    float scrollToPosition = button.center.x - self.view.center.x;
    
    if(scrollToPosition < 0)
    {
        scrollToPosition = 0;
    } else if(scrollToPosition > _tabButtonsContainerView.contentSize.width - self.view.frame.size.width) {
        scrollToPosition = _tabButtonsContainerView.contentSize.width - self.view.frame.size.width;
    }
    
    
    CGRect frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width, kIndicatorHeight);
    //Scroll button to center of screen if possible.
    _indicatorView.frame = frame;
    _tabButtonsContainerView.contentOffset = CGPointMake(scrollToPosition, 0);
}

- (void)addTabButtonsAndIndicator
{
	NSUInteger index = 0;
	for (UIViewController *viewController in self.viewControllers)
	{
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.tag = kTagOffset + index;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:10];
		[button addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button setTitle:viewController.title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[self imageFromColor:[self colorFromHexString:kTabIndicatorColor alpha:0.5f]] forState:UIControlStateHighlighted];
        [_tabButtonsContainerView addSubview:button];
        
        
        if(index < self.viewControllers.count - 1)
        {
            CGRect dividerRect = CGRectMake(0, 0, 1.0f, kTabBarHeight - kDividerMargin);
            UIView *divider = [[UIView alloc] initWithFrame:dividerRect];
            divider.center = CGPointMake(divider.center.x, button.center.y);
            divider.backgroundColor = [UIColor lightGrayColor];
            divider.alpha = 0.25f;
            [_tabButtonsContainerView addSubview:divider];
        }
        
		++index;
	}
    
    UIImage* indicatorImage = [self imageFromColor:[self colorFromHexString:kTabIndicatorColor alpha:1.0f]];
    UIImage* tabBarTopImage =  [[UIImage imageNamed:@"tab_top_bar"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    _tabBarTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _tabBarTopView.backgroundColor = [UIColor colorWithPatternImage:tabBarTopImage];
    _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _indicatorView.backgroundColor = [UIColor colorWithPatternImage:indicatorImage];
    [_tabButtonsContainerView addSubview:_indicatorView];
    [_tabButtonsContainerView addSubview:_tabBarTopView];
}

- (void)removeTabButtonsAndIndicator
{
	NSArray *views = [_tabButtonsContainerView subviews];
	for (UIView *view in views)
    {
		[view removeFromSuperview];
    }
}

- (void)reloadTabButtons
{
	[self removeTabButtonsAndIndicator];
	[self addTabButtonsAndIndicator];
}

- (void)layoutTabButtons
{
    NSArray *subViews = [_tabButtonsContainerView subviews];
    
	NSUInteger count = [self.viewControllers count];
    
    float buttonWidth = floorf(self.view.bounds.size.width / count) < kTabButtonMaxWidth ? kTabButtonMaxWidth : floorf(self.view.bounds.size.width / count);
	CGRect buttonRect = CGRectMake(0.0f, 0.0f, buttonWidth, kTabBarHeight);
    CGRect dividerRect = CGRectMake(0.0f, kDividerMargin / 2.0f, 1.0f, kTabBarHeight - kDividerMargin);
    CGFloat xPosition = 0.0f;
    for (UIView *subView in subViews)
	{
        if([subView isKindOfClass:[UIButton class]])
        {
            subView.frame = buttonRect;
            buttonRect.origin.x += buttonRect.size.width;
            xPosition += buttonWidth;
        }
        else if([subView isKindOfClass:[UIView class]])
        {
            dividerRect.origin.x = xPosition;
            subView.frame = dividerRect;
        }
	}
    _tabButtonsContainerView.contentSize = CGSizeMake(floorf(buttonWidth*count), kTabBarHeight);
    _tabBarTopView.frame = CGRectMake(0.0f, 0.0f, floorf(buttonWidth*count), kTabBarTopHeight);
}

- (void) reloadPages
{
    for (UIView *view in _contentContainerView.subviews)
    {
        [view removeFromSuperview];
    }
    CGFloat contentWidth = 0.0f;
    
    NSUInteger count = self.childViewControllers.count;
	for (NSUInteger i = 0; i < count; i++)
    {
        UIView *view = [[self.childViewControllers objectAtIndex:i] view];
        CGRect rect = view.frame;
        
        rect.origin.x = contentWidth;
        rect.origin.y = 0;
        rect.size.height = rect.size.height-kTabBarHeight;
        view.frame = rect;
        
        [_contentContainerView addSubview:view];
        
        contentWidth += _contentContainerView.frame.size.width;
    }
    
    _contentContainerView.contentSize = CGSizeMake(contentWidth, _contentContainerView.bounds.size.height - kTabBarHeight);
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex
{
    [self setSelectedIndex:newSelectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated
{
    if(_selectedIndex != newSelectedIndex)
    {
        CGRect frame = _contentContainerView.frame;
        frame.origin.x = frame.size.width * newSelectedIndex;
        frame.origin.y = 0;
        
        if (frame.origin.x < _contentContainerView.contentSize.width)
        {
            [_contentContainerView scrollRectToVisible:frame animated:animated];
            _lockPageChange = YES;
        }
    }
}

- (void) setSelectedButton:(NSUInteger)newSelectedIndex {
    
    UIButton *toButton = (UIButton *)[_tabButtonsContainerView viewWithTag:kTagOffset + newSelectedIndex];
    [self selectTabButton:toButton];
}

- (void) tabButtonPressed:(UIButton *)sender
{
	[self setSelectedIndex:sender.tag - kTagOffset animated:YES];
}

- (void) positionTabScrollView
{
    UIButton *toButton = (UIButton *)[_tabButtonsContainerView viewWithTag:kTagOffset + _selectedIndex];
    
    float scrollToPosition = toButton.center.x - self.view.center.x;
    
    if(scrollToPosition < 0)
    {
        scrollToPosition = 0;
    } else if(scrollToPosition > _tabButtonsContainerView.contentSize.width - self.view.frame.size.width)
    {
        scrollToPosition = _tabButtonsContainerView.contentSize.width - self.view.frame.size.width;
    }
    
    //Scroll button to center of screen if possible.
    [UIView animateWithDuration:kAnimationDuration animations:^{
        _tabButtonsContainerView.contentOffset = CGPointMake(scrollToPosition, 0);
    }];
    
    _lockPageChange = NO;
}

- (void)positionTabIndicator:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    uint page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _selectedIndex = page;
    UIButton *toButton = (UIButton *)[_tabButtonsContainerView viewWithTag:kTagOffset + _selectedIndex];
    
    float scale = scrollView.contentSize.width / _tabButtonsContainerView.contentSize.width;
    
    _indicatorView.frame = CGRectMake(scrollView.contentOffset.x / scale, 0, toButton.frame.size.width + 1, kIndicatorHeight);
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self positionTabIndicator:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    [self positionTabScrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self positionTabScrollView];
}


#pragma mark - 
#pragma mark Color utils
- (UIColor *)colorFromHexString:(NSString *)hexString alpha:(CGFloat) alpha {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

- (UIImage *)imageFromColor:(UIColor*)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

