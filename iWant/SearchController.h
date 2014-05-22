//
//  SearchController.h
//  iWant
//
//  Created by Aaron Pang on 2014-04-30.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchController : NSObject

@property (nonatomic, weak) id delegate;

- (void)beginSearchWithTerm:(NSString *)searchTerm;
- (void)cancelSearch;

- (CLLocationCoordinate2D)getCurrentCoordinate;

@end

@protocol SearchControllerDelegate

- (void)stopAskQuestionWithError:(NSError *)error;
- (void)stopAskQuestionWithResult:(id)result;

@end
