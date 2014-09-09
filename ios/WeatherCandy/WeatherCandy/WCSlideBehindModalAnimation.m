//
//  WCSlideBehindModalAnimation.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/3/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCSlideBehindModalAnimation.h"

@implementation WCSlideBehindModalAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting) {
        
        [transitionContext.containerView addSubview:toViewController.view];
        
        CGRect startFrame = fromViewController.view.frame;
        startFrame.origin.y += startFrame.size.height;
        toViewController.view.frame = startFrame;
        
        CGRect endFrame = startFrame;
        endFrame.origin.y = 0;
        
        // Animate
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0
             usingSpringWithDamping:0.8f initialSpringVelocity:0.5f
                            options:0 animations:^{
                                toViewController.view.frame = endFrame;
                            } completion:^(BOOL finished) {
                                [transitionContext completeTransition:finished];
                                [[UIApplication sharedApplication].keyWindow addSubview:toViewController.view];
                            }];
    }
    else {
        
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        CGRect endFrame = fromViewController.view.frame;
        endFrame.origin.y += endFrame.size.height;
        
        // Animate
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0
             usingSpringWithDamping:0.5f initialSpringVelocity:0.5f
                            options:0 animations:^{
                                fromViewController.view.frame = endFrame;
                            } completion:^(BOOL finished) {
                                [transitionContext completeTransition:YES];
                            }];
    }
}

@end
