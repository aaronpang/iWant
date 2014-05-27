//
//  ResultView.h
//  iWant
//
//  Created by Aaron Pang on 2014-05-21.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultView : UIView

@property (nonatomic, weak) id delegate;

- (void)setViewInformation:(id)business;


@end

@protocol ResultViewDelegate

-(void)closeResultView;

@end
