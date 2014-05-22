//
//  LoadingCancelButton.m
//  iWant
//
//  Created by Aaron Pang on 2014-04-30.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "LoadingCancelButton.h"
#import "Constants.h"

@implementation LoadingCancelButton

- (id)init {
    self = [super init];
    if (self) {
        self.layer.cornerRadius = IWCancelButtonSize / 2.0f;
        self.layer.shadowColor = [UIColor redColor].CGColor;
        self.layer.shadowOpacity = 0.7f;
        self.layer.shadowRadius = 10.0f;
        self.backgroundColor = [UIColor redColor];
        
        [self setTitle:@"STOP" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:IWItalicFontName size:17];
        
    }
    return self;
}


- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        [self setBackgroundColor:[UIColor whiteColor]];
    } else {
        [self setBackgroundColor:[UIColor redColor]];
    }
}

@end
