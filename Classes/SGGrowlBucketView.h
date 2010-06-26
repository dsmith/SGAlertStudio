//
//  SGGrowlBucketView.h
//  SGAlertStudio
//
//  Created by Derek Smith on 7/6/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGGrowlView.h"


@interface SGGrowlBucketView : UIView <SGGrowlViewDelegate> {

    @private
    NSMutableArray* messages;
    NSMutableArray* buckets;
    
    BOOL isAnimating;
    
    NSTimer* bucketUpdateTimer;

    SGGrowlView* poppedBucketView;
    
    NSTimeInterval timeInterval;
}

+ (void) showNotifications;
+ (void) addNotification:(NSString*)message;

- (void) addMessage:(NSString*)message;

- (void) makeBucketViewAppear;
- (void) makeBucketViewDisappear;

@end
