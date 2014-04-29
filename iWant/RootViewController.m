//
//  RootViewController.m
//  iWant
//
//  Created by Aaron Pang on 4/25/14.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "QuestionView.h"
#import "QuestionButton.h"

@interface RootViewController ()
@end

@implementation RootViewController {
    UIView *_rootView;
    UIImageView *_backgroundImageView;
    UIView *_loadingView;
    QuestionView *_questionView;
}

- (id)init
{
    self = [super init];
    if (self) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _rootView = [[UIView alloc] initWithFrame:appDelegate.window.bounds];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:_rootView.bounds];
        _backgroundImageView.image = [UIImage imageNamed:@"bg_day.jpg"];
        _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        [_rootView addSubview:_backgroundImageView];
        self.view = _rootView;

        _questionView = [[QuestionView alloc] initWithFrame:_rootView.bounds];
        [self.view addSubview:_questionView];
        
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
