//
//  ResultView.m
//  iWant
//
//  Created by Aaron Pang on 2014-05-21.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "ResultView.h"
#import "Constants.h"
#import "IWButton.h"
#import "ResultButton.h"

#import <MapKit/MapKit.h>


const NSInteger metersPerMile = 1609.344;

@implementation ResultView {
    UILabel *_titleLabel;
    MKMapView *_mapView;
    UILabel *_ratingLabel;
    UILabel *_priceLabel;
    IWButton *_viewOnYelpButton;
    UIButton *_yesButton;
    UIButton *_noButton;
    
    NSDictionary *_business;
    NSString *_urlString;
}


- (id)initWithFrame:(CGRect)frame
{
    //★½
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:IWFontName size:35];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_titleLabel];
        
        _mapView = [[MKMapView alloc] init];
        _mapView.mapType = MKMapTypeStandard;
        _mapView.translatesAutoresizingMaskIntoConstraints = NO;
        _mapView.userInteractionEnabled = NO;
        _mapView.zoomEnabled = NO;
        _mapView.scrollEnabled = NO;
        _mapView.rotateEnabled = NO;
        _mapView.pitchEnabled = NO;
        [self addSubview:_mapView];
        
        _viewOnYelpButton = [IWButton buttonWithType:UIButtonTypeRoundedRect];
        _viewOnYelpButton.translatesAutoresizingMaskIntoConstraints = NO;
        _viewOnYelpButton.titleLabel.font = [UIFont fontWithName:IWFontName size:20];
        [_viewOnYelpButton setTitle:@"View On Yelp" forState:UIControlStateNormal];
        [_viewOnYelpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _viewOnYelpButton.layer.cornerRadius = 10.0f;
        _viewOnYelpButton.layer.borderWidth = 1.0f;
        _viewOnYelpButton.layer.borderColor = _viewOnYelpButton.titleLabel.textColor.CGColor;
        [_viewOnYelpButton addTarget:self action:@selector(yelpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_viewOnYelpButton];
        
        _ratingLabel = [[UILabel alloc] init];
        _ratingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _ratingLabel.font = [UIFont fontWithName:IWFontName size:25];
        _ratingLabel.backgroundColor = [UIColor clearColor];
        _ratingLabel.textColor = [UIColor whiteColor];
        _ratingLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_ratingLabel];
        
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _priceLabel.font = [UIFont fontWithName:IWFontName size:25];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = [UIColor whiteColor];
        _priceLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_priceLabel];

        _yesButton = [[ResultButton alloc] initWithBackgroundColor:[UIColor colorWithRed:0 green:0xcc/255.f blue:0 alpha:1] fontColor:[UIColor whiteColor] title:@"YES"];
        [_yesButton addTarget:self action:@selector(yesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _yesButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_yesButton];
        
        _noButton = [[ResultButton alloc] initWithBackgroundColor:[UIColor redColor] fontColor:[UIColor whiteColor] title:@"NO"];
        [_noButton addTarget:self action:@selector(noButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _noButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_noButton];
        
        // Add the constraints
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_titleLabel, _mapView, _viewOnYelpButton, _ratingLabel, _priceLabel, _yesButton, _noButton);

        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_titleLabel(>=0)]-5-[_ratingLabel(>=0)]-5-[_mapView(==180)]-10-[_viewOnYelpButton(==50)]" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_titleLabel(>=0)]-5-[_priceLabel(>=0)]" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_titleLabel(>=0)]-10-|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_mapView(>=0)]-10-|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_viewOnYelpButton(>=0)]-10-|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_ratingLabel(>=0)]-[_priceLabel(>=0)]-10-|" options:0 metrics:nil views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_noButton(==buttonWidth)]-(>=0)-[_yesButton(==buttonWidth)]-40-|" options:0 metrics:@{@"buttonWidth":@(IWResultButtonSize)} views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_yesButton(==buttonHeight)]-30-|" options:0 metrics:@{@"buttonHeight":@(IWResultButtonSize)} views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_noButton(==buttonHeight)]-30-|" options:0 metrics:@{@"buttonHeight":@(IWResultButtonSize)} views:viewsDictionary]];
    
    }
    return self;
}

- (void)setViewInformation:(id)business {
    _business = business;
    _titleLabel.text = _business[@"name"];
    
    // Clear anything shown on the map before
    MKCoordinateRegion region = MKCoordinateRegionMake(_mapView.centerCoordinate, MKCoordinateSpanMake(180, 360));
    [_mapView setRegion:region animated:NO];
    [_mapView removeAnnotations:_mapView.annotations];
    
    // Display the location on the map
    CGFloat latitude = [_business[@"location"][@"latitude"] floatValue];
    CGFloat longitude = [_business[@"location"][@"longitude"] floatValue];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = latitude;
    zoomLocation.longitude= longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.7 * metersPerMile, 0.7 * metersPerMile);
    [_mapView setRegion:viewRegion animated:YES];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:zoomLocation];
    [annotation setTitle:_business[@"name"]];
    [_mapView addAnnotation:annotation];
    
    // Show the number of stars and price
    _priceLabel.text = _business[@"price"];
    NSMutableString *starString = [NSMutableString string];
    for (int i=0; i < [_business[@"rating"]integerValue]; i++) {
        [starString appendString:@"★"];
    }
    if (fmod([_business[@"rating"] doubleValue], 1) == 0.5) {
        [starString appendString:@"½"];
    }
    _ratingLabel.text = starString;
    
    // Set the link to the yelp page
    if ([self isYelpInstalled]) {
        // Call into the Yelp app
        _urlString = [NSString stringWithFormat:@"yelp5.3:///biz/%@",_business[@"id"]];
    } else {
        // Use the Yelp touch site
        _urlString = [NSString stringWithFormat:@"http://yelp.com/biz/%@",_business[@"id"]];
    }
    
}

- (BOOL)isYelpInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"yelp5.3:"]];
}

- (void)yesButtonPressed:(id)sender {
    // Open up the Map

    CGFloat currentLat = [_business[@"currentLocation"][@"latitude"] floatValue];
    CGFloat currentLong = [_business[@"currentLocation"][@"longitude"] floatValue];
    CGFloat toLat = [_business[@"location"][@"latitude"] floatValue];
    CGFloat toLong = [_business[@"location"][@"longitude"] floatValue];
    
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:currentLat longitude:currentLong];
    CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:toLat longitude:toLong];
    MKMapItem *from = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:fromLocation.coordinate addressDictionary:nil]];
    MKMapItem *to = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:toLocation.coordinate addressDictionary:nil]];
    to.name = _business[@"name"];
    [MKMapItem openMapsWithItems:@[from, to] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking}];

}

- (void)yelpButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_urlString]];
}

- (void)noButtonPressed:(id)sender {
    [self.delegate closeResultView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
