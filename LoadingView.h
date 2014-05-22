//
//  LoadingView.h
//  iWant
//
//  Created by Aaron Pang on 2014-04-30.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property (nonatomic, weak) id delegate;

- (void)stopAnimatingSpinner;
- (void)startAnimatingSpinner;

@end

@protocol LoadingViewDelegate

- (void)stopAskQuestion;

@end
