//
//  IWButton.m
//  iWant
//
//  Created by Aaron Pang on 2014-05-26.
//  Copyright (c) 2014 Aaron Pang. All rights reserved.
//

#import "IWButton.h"

@implementation IWButton

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) setHighlighted:(BOOL)highlighted {    
    if (highlighted) {
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = [UIColor redColor];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}


@end
