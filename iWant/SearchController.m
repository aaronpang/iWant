//
//  SearchController.m
//  iWant
//
//  Created by Aaron Pang on 2014-04-30.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "SearchController.h"
#import "Constants.h"
#import "TFHpple.h"

#import <CoreLocation/CoreLocation.h>
#import <OAuthConsumer/OAuthConsumer.h>
#import <MapKit/MapKit.h>

@interface SearchController () <NSURLConnectionDelegate, CLLocationManagerDelegate>
@end

@implementation SearchController {
    NSMutableData *_responseData;
    CLLocationManager *_locationManager;
    CLLocation *_location;
    NSOperationQueue *_opQueue;
    NSMutableSet *_validRestaurants;
    NSURLConnection *_businessSearchConnection;
    NSString *_searchTerm;
}

- (id) init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)beginSearchWithTerm:(NSString *)searchTerm {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    _searchTerm = [searchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _searchTerm = [_searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSError *errorObject = [NSError errorWithDomain:IWStopQuestionErrorDomain code:kStopQuestionTimeout userInfo:nil];
    [self performSelector:@selector(delegateStopSearchWithError:) withObject:errorObject afterDelay:IWTimeoutTime];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _location = [locations lastObject];
    [manager stopUpdatingLocation];
    [self startYelpSearch];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.delegate stopAskQuestionWithError:[NSError errorWithDomain:IWStopQuestionErrorDomain code:kStopQuestionConnectionErrorCode userInfo:@{@"error":error}]];
}

- (void)startYelpSearch {
    if (!_searchTerm) {
        _searchTerm = @"restaurants";
    }
//    _location = [[CLLocation alloc] initWithLatitude:43.657323 longitude:-79.3891645];
    NSString *searchString = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&ll=%f,%f", _searchTerm, _location.coordinate.latitude, _location.coordinate.longitude];
    NSURL *URL = [NSURL URLWithString:searchString];
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"H8LnKk0YMILop-RkAJ_-0w" secret:@"6X2fZQam2_aggcubI-1wqxU0KZA"] ;
    OAToken *token = [[OAToken alloc] initWithKey:@"e0yVVCx127VGomwRgzz7JEHAgs9ZxeWF" secret:@"SmBdXQKBs52csF9XzcICkBRMcwc"];
    
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *realm = nil;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];
    
    _responseData = [[NSMutableData alloc] init];
    _businessSearchConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.delegate stopAskQuestionWithError:[NSError errorWithDomain:IWStopQuestionErrorDomain code:kStopQuestionConnectionErrorCode userInfo:@{@"error":error}]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection != _businessSearchConnection) {
        NSLog(@"WHAT THE FUCK");
    }
    _businessSearchConnection = nil;
    _validRestaurants = [NSMutableSet set];
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingAllowFragments error:nil];
    // Determine which result to choose
    NSArray *businessArray = responseDictionary[@"businesses"];
    if (![businessArray count]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self.delegate stopAskQuestionWithError:[NSError errorWithDomain:IWStopQuestionErrorDomain code:kStopQuestionNoResultsErrorCode userInfo:nil]];
        return;
    }
    _opQueue = [[NSOperationQueue alloc]init];
    [_opQueue setMaxConcurrentOperationCount:15];
    for (NSDictionary *business in businessArray) {
        [_opQueue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(determineValidResult:) object:business]];
    }
    [_opQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (_opQueue == object && [keyPath isEqualToString:@"operations"]) {
        if (_opQueue.operationCount == 0) {
            if (![_validRestaurants count]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                    [self.delegate stopAskQuestionWithError:[NSError errorWithDomain:IWStopQuestionErrorDomain code:kStopQuestionNoResultsErrorCode userInfo:nil]];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self determineBestResult:[_validRestaurants copy]];
                });
            }

        }
    }
}

- (void)determineBestResult:(NSSet *)businesses {
    NSMutableDictionary *businessRanks = [NSMutableDictionary dictionary];
    // Apply a rating to each business based on the algorithm
    for (NSDictionary *business in businesses) {
        CLLocationCoordinate2D businessLocation = CLLocationCoordinate2DMake([business[@"location"][@"latitude"] doubleValue], [business[@"location"][@"longitude"] doubleValue]);
        CLLocationCoordinate2D userLocation = _location.coordinate;
        CLLocationDistance distanceInMeters = MKMetersBetweenMapPoints(MKMapPointForCoordinate(userLocation), MKMapPointForCoordinate(businessLocation));
        CGFloat distanceInMiles = distanceInMeters / 1609.344;
        CGFloat distanceRating = (1 / (distanceInMiles * 4 + 1)) * 0.74;
        
        CGFloat hoursUntilClose = [business[@"hoursUntilClose"] floatValue];
        CGFloat openRating = (1 - 1 / ((hoursUntilClose - 0.5) / 0.5 * 4 + 1)) * 0.05;
        
        CGFloat priceRatio = [business[@"price"] length] / 4.0f;
        CGFloat priceRating = ((0.5 - priceRatio) / 0.5) * 0.01;
        
        CGFloat rating = [business[@"rating"] floatValue];
        CGFloat ratingRating = 1 - (1/(((rating - 3.5) / 1.5) * 4 + 1)) * 0.15;
        
        CGFloat luckRating = arc4random() % 100 / 100.0f * 0.05;
        
        CGFloat totalRating = distanceRating + priceRating + ratingRating + luckRating + openRating;
        businessRanks [business] = @(totalRating);
    }
    
    // Find the highest rated business
    NSDictionary *highestRatedBusiness = nil;
    for (NSDictionary *business in businessRanks) {
        if ([businessRanks[business] floatValue] > [businessRanks[highestRatedBusiness] floatValue] ) {
            highestRatedBusiness = business;
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.delegate stopAskQuestionWithResult:highestRatedBusiness];

}

- (void)delegateStopSearchWithError:(id)object {
    [self.delegate stopAskQuestionWithError:(NSError *)object];
}

- (void)cancelSearch {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_locationManager stopUpdatingLocation];
    [_businessSearchConnection cancel];
    [_opQueue cancelAllOperations];
    [_validRestaurants removeAllObjects];
    
    @try {
        [_opQueue removeObserver:self forKeyPath:@"operations"];
    }@catch(id exception) {
    }
    
    _businessSearchConnection = nil;
    _opQueue = nil;
    _locationManager = nil;
    _validRestaurants = nil;
}

- (void)determineValidResult:(id)arg {
    if (!_opQueue) {
        return;
    }
    NSDictionary *business = (NSDictionary *)arg;
    NSString *businessSiteString = business[@"url"];
    NSURL *businessSiteURL = [NSURL URLWithString:businessSiteString];
    TFHpple *parser = [TFHpple hppleWithHTMLData:[NSData dataWithContentsOfURL:businessSiteURL]];
    
    NSString *priceQueryString = @"//div[@class='price-category']/span[@class='bullet-after']/span[@class='business-attribute price-range']";
    NSArray *priceNode = [parser searchWithXPathQuery:priceQueryString];
    
    NSString *price;
    for (TFHppleElement *element in priceNode) {
        price = [element firstChild].content;
    }
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    NSString *timeQueryString = @"//table[@class='table table-simple hours-table']/tbody";
    NSArray *timeNode = [parser searchWithXPathQuery:timeQueryString];
    // Assume the place is closed between 9 PM and 9 AM
    CGFloat hoursUntilClose = [currentComponents hour] > 21 || [currentComponents hour] < 9 ? 0 : 0.5;
    if ([timeNode count]) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
        NSInteger weekday = [comps weekday] - 2;
        weekday = weekday < 0 ? 6 : weekday;
        
        TFHppleElement *dayElement = timeNode[0];
        NSArray *tableBody = dayElement.children;
        TFHppleElement *tableElement = tableBody [weekday * 2 + 1];
        NSArray *tableCell = tableElement.children;
        TFHppleElement *openElement = tableCell[3];
        NSArray *openArray = openElement.children;
        // If the array has only one element in it, it means it's closed
        if ([openArray count] == 1) {
            NSString *openString = ((TFHppleElement *)openArray[0]).content;
            openString = [openString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![openString isEqualToString:@"Closed"]) {
                hoursUntilClose = 24;
            }
        } else if ([openArray count] >= 1 ) {
            
            TFHppleElement *openingElement = [openArray[1] firstChild];
            NSString *openingTime = openingElement.content;
            CGFloat openingTimeInHours = [self timeInHoursFromString:openingTime];

            TFHppleElement *closingElement = [openArray[3] firstChild];
            NSString *closingTime = closingElement.content;
            CGFloat closingTimeInHours = [self timeInHoursFromString:closingTime];
            
            CGFloat currentTimeInHours = [currentComponents hour] + [currentComponents minute] / 60.f;
            
            // Zero the opening time and make all the time relative to it
            CGFloat openingTimeDifference = 24 - openingTimeInHours;
            
            CGFloat newOpenTimeInHours = fmod(openingTimeInHours + openingTimeDifference, 24);
            CGFloat newClosingTimeInHours = fmod(closingTimeInHours + openingTimeDifference, 24);
            CGFloat newCurrentTimeInHours = fmod(currentTimeInHours + openingTimeDifference, 24);
            
            if (newCurrentTimeInHours >= newOpenTimeInHours && newCurrentTimeInHours <= newClosingTimeInHours) {
                hoursUntilClose = newClosingTimeInHours - newCurrentTimeInHours;
            }

        }
    }

    CGFloat rating = [business[@"rating"] floatValue];
    
    // Determine if it is a valid result or not
    if (![price isEqual:@"$"] && ![price isEqual:@"$$"]) {
        return;
    }
    if (rating < 3.5) {
        return;
    }
    if (hoursUntilClose < 0.5) {
        return;
    }
    

    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:[NSString stringWithFormat:@"%@, %@, %@", business[@"location"][@"address"], business[@"location"][@"city"], business[@"location"][@"country_code"]] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (![placemarks count] || error) {
            return;
        }
        CLPlacemark *placemark = placemarks[0];
        
        NSMutableDictionary *newBusiness = [[NSMutableDictionary alloc] initWithDictionary:business];
        NSMutableDictionary *locationDictionary = [[NSMutableDictionary alloc] initWithDictionary:newBusiness[@"location"]];
        locationDictionary[@"latitude"] = @(placemark.location.coordinate.latitude);
        locationDictionary[@"longitude"] = @(placemark.location.coordinate.longitude);
        newBusiness[@"location"] = locationDictionary;
        newBusiness[@"price"] = price;
        newBusiness[@"hoursUntilClose"] = @(hoursUntilClose);
        if (!_opQueue) {
            return;
        }
        [_validRestaurants addObject:[newBusiness copy]];
    }];
}

- (CGFloat)timeInHoursFromString:(NSString *)timeString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"hh:mm aaa"];
    NSDate *date = [dateFormatter dateFromString:timeString];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    CGFloat timeInHours = hour + minute / 60.f;
    return timeInHours;
}

- (CLLocationCoordinate2D)getCurrentCoordinate {
    return _location.coordinate;
}

@end
