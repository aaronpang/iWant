//
//  Constants.h
//  iWant
//
//  Created by Aaron Pang on 2014-04-27.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString * const IWFontName;
extern NSString * const IWItalicFontName;

extern const NSInteger IWFontSize;
extern const NSInteger IWGoButtonSize;
extern const NSInteger IWCancelButtonSize;
extern const NSInteger IWResultButtonSize;
extern const CGFloat IWTimeoutTime;

extern NSString * const IWStopQuestionErrorDomain;

typedef enum {
    kStopQuestionLoadingLocationErrorCode,
    kStopQuestionNoResultsErrorCode,
    kStopQuestionConnectionErrorCode,
    kStopQuestionTimeout
}IWStopQuestionErrorCode;

@end
