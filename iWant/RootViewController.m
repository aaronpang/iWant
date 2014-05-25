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
#import "LoadingView.h"
#import "QuestionButton.h"
#import "Constants.h"
#import "SearchController.h"
#import "ResultView.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

const CGFloat questionViewZoomAnimateDuration = 0.35f;
const CGFloat questionViewZoomScale = 1.5f;
const CGFloat backgroundScaleFactor = 3.5;
const CGFloat sunriseHour = 6.5;
const CGFloat sunsetHour = 20;

@interface RootViewController () <QuestionViewDelegate, LoadingViewDelegate, SearchControllerDelegate>
@end

@implementation RootViewController {
    UIView *_rootView;
    UIImageView *_backgroundImageView;
    LoadingView *_loadingView;
    QuestionView *_questionView;
    ResultView *_resultView;
    SearchController *_searchController;
    
    BOOL _dogeMode;
    NSTimer *_dogeDisplayTimer;
}

- (id)init
{
    self = [super init];
    if (self) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _rootView = [[UIView alloc] initWithFrame:appDelegate.window.bounds];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:_rootView.bounds];
        _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        [self determineBackgroundToShow];
        [_rootView addSubview:_backgroundImageView];
        self.view = _rootView;

        _loadingView = [[LoadingView alloc] initWithFrame:_rootView.bounds];
        _loadingView.alpha = 0.0f;
        _loadingView.userInteractionEnabled = NO;
        _loadingView.delegate = self;
        [self.view addSubview:_loadingView];

        _questionView = [[QuestionView alloc] initWithFrame:_rootView.bounds];
        _questionView.delegate = self;
        _questionView.userInteractionEnabled = YES;
        [self.view addSubview:_questionView];
        
        _searchController = [[SearchController alloc] init];
        _searchController.delegate = self;
        
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)determineBackgroundToShow {
    
    if (_dogeMode) {
        _backgroundImageView.image = [UIImage imageNamed:@"bg_doge.png"];
        return;
    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    NSInteger currentHour = [components hour];
    
    // Display a different background depending on the time of day
    if (currentHour > sunriseHour && currentHour < sunsetHour) {
        _backgroundImageView.image = [UIImage imageNamed:@"bg_day.jpg"];
    } else {
        _backgroundImageView.image = [UIImage imageNamed:@"bg.jpg"];
    }
}

- (void)enterDogeMode {
    _dogeMode = YES;
    [self determineBackgroundToShow];
}

- (void)startDisplayingDogeThings {
    _dogeDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(displayDogeLabel:) userInfo:nil repeats:YES];
}

- (void)stopDisplayingDogeThings {
    [_dogeDisplayTimer invalidate];
    _dogeDisplayTimer = nil;
}

- (void)displayDogeLabel:(id)object {
    __block UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    NSArray *dogePhrases = @[@"Wow.", @"Such Search", @"Very Search", @"Very Wow."];
    NSArray *dogeColours = @[[UIColor redColor], [UIColor blueColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor]];
    
    label.text = dogePhrases[rand() % [dogePhrases count]];
    label.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
    label.textColor = dogeColours[rand() % [dogeColours count]];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    CGFloat randomX = fmodf(rand(), [UIScreen mainScreen].applicationFrame.size.width - label.frame.size.width);
    CGFloat randomY = fmodf(rand(), [UIScreen mainScreen].applicationFrame.size.height - label.frame.size.height);
    label.frame = (CGRect){.size = label.frame.size, .origin={randomX ,randomY}};
    
    [UIView animateWithDuration:2.0f  delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        label.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
        label = nil;
    }];
    [_loadingView addSubview:label];
}

#pragma mark - View Delegates

- (void)askQuestion {
    [self dismissQuestionView];
    [self presentLoadingView];
    if ([[[_questionView searchTerm] lowercaseString] isEqualToString:@"doge"]) {
        [self enterDogeMode];
    }
    if (_dogeMode) {
        [self startDisplayingDogeThings];
    }
    [_searchController beginSearchWithTerm:[_questionView searchTerm]];
}

- (void)stopAskQuestion {
    [self dismissLoadingView];
    [self presentQuestionView];
    if (_dogeMode) {
        [self stopDisplayingDogeThings];
    }
    [_searchController cancelSearch];
    
}

#pragma mark - Search Controller Delegates

- (void)stopAskQuestionWithError:(NSError *)error {
    [self stopAskQuestion];
    NSString *errorTitle;
    NSString *errorMessage;
    if ([error.domain isEqualToString:IWStopQuestionErrorDomain]) {
        if (error.code == kStopQuestionLoadingLocationErrorCode) {
            NSError * loadingError = error.userInfo[@"error"];
            if (loadingError.code == kCLErrorDenied) {
                errorTitle = NSLocalizedString(@"Activate Location", @"Home Screen - Error loading location");
                errorMessage = NSLocalizedString(@"Please activate location services to use iWant", @"Home Screen - Error loading location comment");
            }
        } else if (error.code == kStopQuestionNoResultsErrorCode) {
            errorTitle = NSLocalizedString(@"No Locations", @"Home Screen - Error No Results");
            errorMessage = NSLocalizedString(@"No locations were found. All locations may be closed or nothing fits our desired criteria.", @"Home Screen - Error No Results comment");
        } else if (error.code == kStopQuestionTimeout ) {
            errorTitle = NSLocalizedString(@"Timeout", @"Home Screen - Error Timeout Error");
            errorMessage = NSLocalizedString(@"The request timed out. Please try again.", @"Home Screen - Error Timeout comment");
        } else if (error.code == kStopQuestionConnectionErrorCode) {
            errorTitle = NSLocalizedString(@"Connection Error", @"Home Screen - Error Connection Error");
            errorMessage = NSLocalizedString(@"There was problem with the connection to the network. Please Try Again.", @"Home Screen - Error Connection comment");
        } else {
            errorTitle = NSLocalizedString(@"Network Error", @"Home Screen - Error Network Error");
            errorMessage = NSLocalizedString(@"There was problem with the network. Please Try Again.", @"Home Screen - Error No Network comment");
        }
        UIAlertView *locationFailedAlert = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMessage delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [locationFailedAlert show];
    }
}

- (void)stopAskQuestionWithResult:(id)result {
    [self stopAskQuestion];
    NSDictionary *business = result;
    
    // Open up the Map
    CGFloat businessLatitude = [business[@"location"][@"latitude"] floatValue];
    CGFloat businessLongitude = [business[@"location"][@"longitude"] floatValue];
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:_searchController.getCurrentCoordinate.latitude longitude:_searchController.getCurrentCoordinate.longitude];
    CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:businessLatitude longitude:businessLongitude];
    MKMapItem *from = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:fromLocation.coordinate addressDictionary:nil]];
    MKMapItem *to = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:toLocation.coordinate addressDictionary:nil]];
    to.name = business[@"name"];
    [MKMapItem openMapsWithItems:@[from, to] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking}];
}

- (void)dismissQuestionView {
    _questionView.userInteractionEnabled = NO;
    
    // Animate the question view out
    [UIView animateWithDuration:questionViewZoomAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        _questionView.alpha = 0.0f;
        _questionView.transform = CGAffineTransformMakeScale(questionViewZoomScale, questionViewZoomScale);
    } completion:^(BOOL finished) {
    }];
}

- (void)presentQuestionView {
    [UIView animateWithDuration:questionViewZoomAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        _questionView.alpha = 1.0f;
        _questionView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        _questionView.userInteractionEnabled = YES;
    }];
}

- (void)dismissLoadingView {
    [self stopAnimatingBackground];
    _loadingView.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:questionViewZoomAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        _loadingView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [_loadingView stopAnimatingSpinner];
    }];
}

- (void)presentLoadingView {
    [self startAnimatingBackground];
    [_loadingView startAnimatingSpinner];
    
    [UIView animateWithDuration:questionViewZoomAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        _loadingView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        _loadingView.userInteractionEnabled = YES;
    }];
}

- (void)startAnimatingBackground {
    // Start the zooming background animation
    [UIView animateWithDuration:IWTimeoutTime delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        _backgroundImageView.layer.transform = CATransform3DMakeScale(backgroundScaleFactor, backgroundScaleFactor, 1.0f);
    } completion:^(BOOL finished) {
    }];
}

- (void)stopAnimatingBackground {
    [_backgroundImageView.layer removeAllAnimations];
    CALayer *currentLayer = (CALayer *)_backgroundImageView.layer.presentationLayer;
    _backgroundImageView.layer.transform = currentLayer.transform;
    
    // Stop the animation and return the background image view back to it's original transform
    [UIView animateWithDuration:questionViewZoomAnimateDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        _backgroundImageView.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
    } completion:^(BOOL finished) {
    }];}

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
