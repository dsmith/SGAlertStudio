//
//  SGTickerView.h
//  SGAlertStudio
//
//  Created by Derek Smith on 7/8/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SGTickerMessage.h"

enum TickerMessagePriority {
 
    kTickerMessagePriority_Normal = 0,
    kTickerMessagePriority_High
    
};

@interface SGTickerView : UIView {

    @private
    NSMutableArray* messages;
    NSMutableArray* viewableMessages;
    
    NSTimer* drawTickerTimer;

    CGGradientRef fadeGradient;
    
    BOOL historyMode;
    
}

+ (SGTickerView*) sharedTicker;
+ (void) addMessage:(SGTickerMessage*)message priority:(enum TickerMessagePriority)priority;

- (void) startTicker;
- (void) stopTicker;
- (void) addMessage:(SGTickerMessage*)message priority:(enum TickerMessagePriority)priority;
@end
