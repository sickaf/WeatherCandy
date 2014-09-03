//
//  WCSlideDownModalAnimation.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/2/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCSlideDownModalAnimation.h"

@implementation WCSlideDownModalAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (self.presenting) {
        
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        // Set our ending frame. We'll modify this later if we have to
        CGRect endFrame = fromViewController.view.frame;
        endFrame.origin.y -= endFrame.size.height;
        
        // Animate
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0
             usingSpringWithDamping:0.8f initialSpringVelocity:0.3f
                            options:0 animations:^{
                                fromViewController.view.frame = endFrame;
                            } completion:^(BOOL finished) {
                                [transitionContext completeTransition:YES];
                            }];
    }
    else {
        CGRect starting = fromViewController.view.frame;
        starting.origin.y -= toViewController.view.frame.size.height;
        toViewController.view.frame = starting;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        // Set our ending frame. We'll modify this later if we have to
        CGRect endFrame = fromViewController.view.frame;
        
        // Animate
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0
             usingSpringWithDamping:0.8f initialSpringVelocity:0.3f
                            options:0 animations:^{
                                toViewController.view.frame = endFrame;
                            } completion:^(BOOL finished) {
                                [transitionContext completeTransition:YES];
                            }];
    }
}

@end
