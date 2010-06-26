//
//  SGTickerMessage.m
//  SGAlertStudio
//
//  Created by Derek Smith on 7/8/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGTickerMessage.h"


@implementation SGTickerMessage

@synthesize reuse, startCoord, endCoord;

- (id) initWithString:(NSString*)str
{
    if(self = [super initWithString:str]) {
        startCoord = 0.0;
        endCoord = 0.0;
        reuse = NO;
    }
    
    return self;
}

- (void) reset
{
    startCoord = 0.0;
    CGSize size = [self getSizeOfString];
    endCoord = -size.width;
}

- (void) advanceTickMessage:(NSInteger)count
{
    startCoord += count;
    endCoord += count;
}

@end
