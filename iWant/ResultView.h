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

- (void)setBusinesses:(id)result;
- (void)setViewInformation;
- (void)resetMapPosition;
- (void)clearLeftOverBusinesses;


@end

@protocol ResultViewDelegate

-(void)closeResultView;

@end
