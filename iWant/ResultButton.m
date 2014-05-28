//
//  ResultButton.m
//  iWant
//
//  Created by Aaron Pang on 2014-05-27.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "ResultButton.h"
#import "Constants.h"

@implementation ResultButton {
    UIColor *_backgroundColor;
    UIColor *_fontColor;
}

- (id)initWithBackgroundColor:(UIColor *)backgroundColor fontColor:(UIColor *)fontColor title:(NSString *)title {
    self = [super init];
    if (self) {
        _fontColor = fontColor;
        _backgroundColor = backgroundColor;
        self.layer.cornerRadius = IWResultButtonSize / 2.0f;
        self.layer.shadowColor = _backgroundColor.CGColor;
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowRadius = 10.f;
        self.backgroundColor = _backgroundColor;
        
        [self setTitle:title forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont fontWithName:IWItalicFontName size:25]];
        
        [self setTitleColor:_fontColor forState:UIControlStateNormal];
        [self setTitleColor:_backgroundColor forState:UIControlStateHighlighted];
        
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = _fontColor;
    } else {
        self.backgroundColor = _backgroundColor;
    }
}


@end
