//
//  QuestionButton.m
//  iWant
//
//  Created by Aaron Pang on 2014-04-28.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "QuestionButton.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@implementation QuestionButton

- (id)init
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = IWGoButtonSize / 2.0f;
        self.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowRadius = 10.f;
        self.backgroundColor = [UIColor whiteColor];
        
        [self setTitle:@"GO" forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont fontWithName:IWItalicFontName size:25]];
        
        [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = [UIColor redColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}


@end
