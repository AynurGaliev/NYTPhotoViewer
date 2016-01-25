//
//  NYTPhotoTransitionAnimator.m
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/17/15.
//
//

#import "NYTPhotoTransitionAnimator.h"

static const CGFloat NYTPhotoTransitionAnimatorDurationWithZooming = 0.5;
static const CGFloat NYTPhotoTransitionAnimatorDurationWithoutZooming = 0.3;
static const CGFloat NYTPhotoTransitionAnimatorBackgroundFadeDurationRatio = 4.0 / 9.0;
static const CGFloat NYTPhotoTransitionAnimatorEndingViewFadeInDurationRatio = 0.1;
static const CGFloat NYTPhotoTransitionAnimatorStartingViewFadeOutDurationRatio = 0.05;
static const CGFloat NYTPhotoTransitionAnimatorSpringDamping = 0.9;

@interface NYTPhotoTransitionAnimator ()

@property (nonatomic, readonly) BOOL shouldPerformZoomingAnimation;

@end

@implementation NYTPhotoTransitionAnimator

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _animationDurationWithZooming = NYTPhotoTransitionAnimatorDurationWithZooming;
        _animationDurationWithoutZooming = NYTPhotoTransitionAnimatorDurationWithoutZooming;
        _animationDurationFadeRatio = NYTPhotoTransitionAnimatorBackgroundFadeDurationRatio;
        _animationDurationEndingViewFadeInRatio = NYTPhotoTransitionAnimatorEndingViewFadeInDurationRatio;
        _animationDurationStartingViewFadeOutRatio = NYTPhotoTransitionAnimatorStartingViewFadeOutDurationRatio;
        _zoomingAnimationSpringDamping = NYTPhotoTransitionAnimatorSpringDamping;
    }
    
    return self;
}

#pragma mark - NYTPhotoTransitionAnimator

- (void)setupTransitionContainerHierarchyWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];

    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toView.frame = [transitionContext finalFrameForViewController:toViewController];
    
    if (![toView isDescendantOfView:transitionContext.containerView]) {
        [transitionContext.containerView addSubview:toView];
    }
    
    if (self.isDismissing) {
        [transitionContext.containerView bringSubviewToFront:fromView];
    }
}

- (void)setAnimationDurationFadeRatio:(CGFloat)animationDurationFadeRatio {
    _animationDurationFadeRatio = MIN(animationDurationFadeRatio, 1.0);
}

- (void)setAnimationDurationEndingViewFadeInRatio:(CGFloat)animationDurationEndingViewFadeInRatio {
    _animationDurationEndingViewFadeInRatio = MIN(animationDurationEndingViewFadeInRatio, 1.0);
}

- (void)setAnimationDurationStartingViewFadeOutRatio:(CGFloat)animationDurationStartingViewFadeOutRatio {
    _animationDurationStartingViewFadeOutRatio = MIN(animationDurationStartingViewFadeOutRatio, 1.0);
}

#pragma mark - Fading

- (void)performFadeAnimationWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    UIView *viewToFade = toView;
    CGFloat beginningAlpha = 0.0;
    CGFloat endingAlpha = 1.0;
    
    if (self.isDismissing) {
        viewToFade = fromView;
        beginningAlpha = 1.0;
        endingAlpha = 0.0;
    }
    
    viewToFade.alpha = beginningAlpha;
    
    [UIView animateWithDuration:[self fadeDurationForTransitionContext:transitionContext] animations:^{
        viewToFade.alpha = endingAlpha;
    } completion:^(BOOL finished) {
        if (!self.shouldPerformZoomingAnimation) {
            [self completeTransitionWithTransitionContext:transitionContext];
        }
    }];
}

- (CGFloat)fadeDurationForTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.shouldPerformZoomingAnimation) {
        return [self transitionDuration:transitionContext] * self.animationDurationFadeRatio;
    }
    
    return [self transitionDuration:transitionContext];
}

#pragma mark - Zooming

- (void)performZoomingAnimationWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = transitionContext.containerView;
    
    // Create a brand new view with the same contents for the purposes of animating this new view and leaving the old one alone.
    UIView *startingViewForAnimation = self.startingViewForAnimation;
    if (!startingViewForAnimation) {
        startingViewForAnimation = [[self class] newAnimationViewFromView:self.startingView];
    }
    
    UIView *endingViewForAnimation = self.endingViewForAnimation;
    if (!endingViewForAnimation) {
        endingViewForAnimation = [[self class] newAnimationViewFromView:self.endingView];
    }
    
    CGPoint translatedStartingViewCenter = [[self class] centerPointForView:self.startingView
                                                  translatedToContainerView:containerView];
    
    CGRect finalFrame = CGRectMake(0, 0, endingViewForAnimation.frame.size.width, endingViewForAnimation.frame.size.height);
    startingViewForAnimation.center = translatedStartingViewCenter;
    endingViewForAnimation.transform = CGAffineTransformIdentity;
    endingViewForAnimation.frame = startingViewForAnimation.frame;
    if (!self.isDismissing) {
        endingViewForAnimation.alpha = 0.0;
        startingViewForAnimation.alpha = 0.0;
        self.endingView.alpha = 1.0;
        self.startingView.alpha = 1.0;
    } else {
        endingViewForAnimation.alpha = 1.0;
        startingViewForAnimation.alpha = 1.0;
        self.endingView.alpha = 0.0;
        self.startingView.alpha = 0.0;
    }
    
    if(!self.isDismissing) {
        [transitionContext.containerView addSubview:startingViewForAnimation];
    }
    [transitionContext.containerView addSubview:endingViewForAnimation];
    
    __weak NYTPhotoTransitionAnimator* wself = self;

    CGPoint translatedEndingViewFinalCenter = [[self class] centerPointForView:self.endingView
                                                     translatedToContainerView:containerView];
    
    finalFrame.origin = CGPointMake(translatedEndingViewFinalCenter.x - finalFrame.size.width/2,
                                    translatedEndingViewFinalCenter.y - finalFrame.size.height/2);
    [UIView animateWithDuration: 0.4
                          delay: 0
         usingSpringWithDamping: 0.85
          initialSpringVelocity: 1.5
                        options: UIViewAnimationOptionCurveEaseIn animations:^{
                            
                                    if (wself) {
                                        if (!wself.isDismissing) {
                                            startingViewForAnimation.alpha = 1.0;
                                            endingViewForAnimation.alpha = 1.0;
                                            self.endingView.alpha = 0.0;
                                            self.startingView.alpha = 0.0;
                                        } else {
                                            startingViewForAnimation.alpha = 0.0;
                                            endingViewForAnimation.alpha = 0.0;
                                            self.endingView.alpha = 1.0;
                                            self.startingView.alpha = 1.0;
                                        }
                                        endingViewForAnimation.frame = finalFrame;
                                        startingViewForAnimation.frame = finalFrame;
                                    }
                            
                                } completion:^(BOOL finished) {
                                    if (wself) {
                                        [startingViewForAnimation removeFromSuperview];
                                        [endingViewForAnimation removeFromSuperview];
                                        wself.endingView.alpha = 1.0;
                                        wself.startingView.alpha = 1.0;
                                        [wself completeTransitionWithTransitionContext:transitionContext];
                                    }
                                }];
}

#pragma mark - Convenience

- (BOOL)shouldPerformZoomingAnimation {
    return self.startingView && self.endingView;
}

- (void)completeTransitionWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (transitionContext.isInteractive) {
        if (transitionContext.transitionWasCancelled) {
            [transitionContext cancelInteractiveTransition];
            [[UIApplication sharedApplication] setStatusBarHidden:true];
        }
        else {
            [transitionContext finishInteractiveTransition];
        }
    }
    
    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
}

+ (CGPoint)centerPointForView:(UIView *)view translatedToContainerView:(UIView *)containerView {
    CGPoint centerPoint = view.center;
    
    // Special case for zoomed scroll views.
    if ([view.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view.superview;
        
        if (scrollView.zoomScale != 1.0) {
            centerPoint.x += (CGRectGetWidth(scrollView.bounds) - scrollView.contentSize.width) / 2.0 + scrollView.contentOffset.x;
            centerPoint.y += (CGRectGetHeight(scrollView.bounds) - scrollView.contentSize.height) / 2.0 + scrollView.contentOffset.y;
        }
    }
    
    return [view.superview convertPoint:centerPoint toView:containerView];
}

+ (UIView *)newAnimationViewFromView:(UIView *)view {
    if (!view) {
        return nil;
    }
    
    UIView *animationView;
    
    if (view.layer.contents) {
        animationView = [[UIView alloc] initWithFrame:view.frame];
        animationView.layer.contents = view.layer.contents;
        animationView.layer.bounds = view.layer.bounds;
        animationView.layer.cornerRadius = view.layer.cornerRadius;
        animationView.layer.masksToBounds = view.layer.masksToBounds;
        animationView.contentMode = view.contentMode;
        animationView.transform = view.transform;
    }
    else {
        animationView = [view snapshotViewAfterScreenUpdates:YES];
    }
    
    return animationView;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    [self setupTransitionContainerHierarchyWithTransitionContext:transitionContext];
    
    [self performFadeAnimationWithTransitionContext:transitionContext];
    
    if (self.shouldPerformZoomingAnimation) {
        [self performZoomingAnimationWithTransitionContext:transitionContext];
    }
}

- (void)animationEnded:(BOOL) transitionCompleted {
    if (self.completionBlock) {
        self.completionBlock(transitionCompleted);
    }
}

@end
