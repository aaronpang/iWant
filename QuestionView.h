//
//  QuestionView.h
//  iWant
//
//  Created by Aaron Pang on 4/25/14.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionView : UIView

@property (nonatomic, weak)id delegate;

- (NSString *)searchTerm;

@end

@protocol QuestionViewDelegate

- (void)askQuestion;

@end