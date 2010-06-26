//
//  SGTickerMessage.h
//  SGAlertStudio
//
//  Created by Derek Smith on 7/8/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGAttributeString.h"

@interface SGTickerMessage : SGAttributeString {

    CGFloat endCoord;
    CGFloat startCoord;
    
    BOOL reuse;
}

@property (assign, readwrite, nonatomic) BOOL reuse;
@property (assign, readwrite, nonatomic) CGFloat endCoord;
@property (assign, readwrite, nonatomic) CGFloat startCoord;

- (id) initWithString:(NSString*)str;
- (void) advanceTickMessage:(NSInteger)tickCount;
- (void) reset;

@end
