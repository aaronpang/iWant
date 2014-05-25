//
//  LoadingView.m
//  iWant
//
//  Created by Aaron Pang on 2014-04-30.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "Constants.h"
#import "LoadingView.h"
#import "LoadingCancelButton.h"

#import <QuartzCore/QuartzCore.h>

@implementation LoadingView {
    UIImageView *_spinnerView;
    UILabel *_thinkingLabel;
    LoadingCancelButton *_loadingCancelButton;
    BOOL _animate;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _spinnerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinner.png"]];
        _spinnerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_spinnerView];
        
        _thinkingLabel = [[UILabel alloc] init];
        _thinkingLabel.text = @"thinking...";
        _thinkingLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.6f];
        _thinkingLabel.font = [UIFont fontWithName:IWFontName size:17.f];
        _thinkingLabel.backgroundColor = [UIColor clearColor];
        _thinkingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_thinkingLabel];
        
        _loadingCancelButton = [[LoadingCancelButton alloc] init];
        _loadingCancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_loadingCancelButton addTarget:self action:@selector(loadingCancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_loadingCancelButton];
        
        const NSInteger spinnerSize = 150;
        NSDictionary *views = NSDictionaryOfVariableBindings(_spinnerView, _thinkingLabel, _loadingCancelButton);
        
        // Layout the spinner
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_spinnerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_spinnerView(==spinnerWidth)]" options:0 metrics:@{@"spinnerWidth":@(spinnerSize)} views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-136-[_spinnerView(==spinnerHeight)]" options:0 metrics:@{@"spinnerHeight":@(spinnerSize)} views:views]];

        // Layout the thinking label
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_thinkingLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_thinkingLabel(>=0)]" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[_thinkingLabel(>=0)]" options:0 metrics:nil views:views]];
        
        // Layout the cancel button
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_loadingCancelButton(==buttonHeight)]-60-|" options:0 metrics:@{@"buttonHeight":@(IWCancelButtonSize)} views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_loadingCancelButton attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_loadingCancelButton(==buttonWidth)]" options:0 metrics:@{@"buttonWidth":@(IWCancelButtonSize)} views:views]];
        
    }
    return self;
}

- (void)animateSpinner {
    if (!_animate) return;
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        _spinnerView.transform = CGAffineTransformRotate(_spinnerView.transform, M_PI_2);
    } completion:^(BOOL finished) {
        [self animateSpinner];
    }];
}

- (void)startAnimatingSpinner {
    _animate = YES;
    [self animateSpinner];
}


- (void)stopAnimatingSpinner {
    _animate = NO;
    [_spinnerView.layer removeAllAnimations];
}

- (void)loadingCancelButtonPressed:(id)sender {
    [self.delegate stopAskQuestion];
}

@end
