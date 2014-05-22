//
//  QuestionView.m
//  iWant
//
//  Created by Aaron Pang on 4/25/14.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "QuestionView.h"
#import "QuestionButton.h"
#import "Constants.h"

@interface QuestionView () <UITextFieldDelegate>
@end

@implementation QuestionView {
    UILabel *_iWantLabel;
    UITextField *_iWantTextField;
    UIView *_underScoreView;
    UILabel *_periodLabel;
    QuestionButton *_goButton;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
         // Create the iWant label at the top
        _iWantLabel = [[UILabel alloc] init];
        _iWantLabel.font = [UIFont fontWithName:IWFontName size:IWFontSize];
        _iWantLabel.textColor = [UIColor whiteColor];
        _iWantLabel.text = @"I want";
        _iWantLabel.textAlignment = NSTextAlignmentCenter;
        _iWantLabel.backgroundColor = [UIColor clearColor];
        [_iWantLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_iWantLabel];
        
        _iWantTextField = [[UITextField alloc] init];
        _iWantTextField.backgroundColor = [UIColor clearColor];
        _iWantTextField.textAlignment = NSTextAlignmentLeft;
        _iWantTextField.font = [UIFont fontWithName:IWFontName size:IWFontSize - 10];
        _iWantTextField.textColor = [UIColor whiteColor];
        _iWantTextField.delegate = self;
        _iWantTextField.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_iWantTextField];
        
        _periodLabel = [[UILabel alloc] init];
        _periodLabel.font = [UIFont fontWithName:IWFontName size:IWFontSize];
        _periodLabel.textColor = [UIColor whiteColor];
        _periodLabel.text = @".";
        _periodLabel.textAlignment = NSTextAlignmentCenter;
        _periodLabel.backgroundColor = [UIColor clearColor];
        _periodLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_periodLabel];
        
        _underScoreView = [[UIView alloc] init];
        _underScoreView.backgroundColor = [UIColor whiteColor];
        _underScoreView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_underScoreView];

        _goButton = [[QuestionButton alloc] init];
        [_goButton addTarget:self action:@selector(goButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _goButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_goButton];
        
        // Add the constraints
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_iWantLabel, _iWantTextField, _underScoreView, _periodLabel,_goButton);

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-70-[_iWantLabel(==150)]" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-70-[_iWantTextField(==176)]" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-70-[_underScoreView(==_iWantTextField)]-0-[_periodLabel(>=0)]" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[_iWantLabel(>=0)]-[_iWantTextField(==60)][_underScoreView(==1)]" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-132-[_periodLabel]" options:0 metrics:nil views:viewsDictionary]];
        
        // Center the button
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_goButton(==buttonWidth)]" options:0 metrics:@{@"buttonWidth":@(IWGoButtonSize)} views:viewsDictionary]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_goButton attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_goButton(==buttonHeight)]-70-|" options:0 metrics:@{@"buttonHeight":@(IWGoButtonSize)} views:viewsDictionary]];

    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_iWantTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)goButtonPressed:(id)sender {
    [self.delegate askQuestion];
}

- (NSString *)searchTerm {
    return _iWantTextField.text;
}



@end
