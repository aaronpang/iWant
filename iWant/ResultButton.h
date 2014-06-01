//
//  ResultButton.h
//  iWant
//
//  Created by Aaron Pang on 2014-05-27.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultButton : UIButton
- (id)initWithBackgroundColor:(UIColor *)backgroundColor fontColor:(UIColor *)fontColor title:(NSString *)title;
- (void)setFontSize:(CGFloat)size;
@end
