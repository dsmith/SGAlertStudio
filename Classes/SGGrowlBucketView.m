//
//  SGGrowlBucketView.m
//  SGAlertStudio
//
//  Copyright (c) 2009-2010, SimpleGeo
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, 
//  this list of conditions and the following disclaimer. Redistributions 
//  in binary form must reproduce the above copyright notice, this list of
//  conditions and the following disclaimer in the documentation and/or 
//  other materials provided with the distribution.
//  
//  Neither the name of the SimpleGeo nor the names of its contributors may
//  be used to endorse or promote products derived from this software 
//  without specific prior written permission.
//   
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  Created by Derek Smith.
//

#import "SGGrowlBucketView.h"

#import "SGGrowlView.h"

#define kBucketPosition_Bottom  0
#define kBucketPosition_Middle  1
#define kBucketPosition_Top     2

#define kAnimation_Duration     0.5

static SGGrowlBucketView* sharedNotificationView = nil;

@interface SGGrowlBucketView (Private)

- (void) createBuckets;
- (void) fillBucketsWithMessages;
- (void) moveBuckets;
- (void) popBucket;
- (void) popBucketAtPosition:(NSInteger)position;

@end


@implementation SGGrowlBucketView

- (id) initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
        
        messages = [[NSMutableArray alloc] init];
        
        timeInterval = 0;
        
        self.backgroundColor = [UIColor clearColor];
        isAnimating = NO;
        [self createBuckets];
    }
    
    return self;
}

- (void) createBuckets
{
    buckets = [[NSMutableArray alloc] initWithCapacity:3];

    SGGrowlView* view;
    for(int i = 0; i < 4; i++) {
        
        view = [[SGGrowlView alloc] initWithTag:i];
        view.delegate = self;
        [buckets addObject:view];
        
        [view clear];
        view.alpha = 0.0;
        
        [self addSubview:view];
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

+ (void) addNotification:(NSString*)message
{
    if(!sharedNotificationView) {
        sharedNotificationView = [[[SGGrowlBucketView alloc] initWithFrame:CGRectZero] retain];
        sharedNotificationView.hidden = YES;
    }

    [sharedNotificationView addMessage:message];
}

+ (void) showNotifications
{
    if(!sharedNotificationView) {
        sharedNotificationView = [[[SGGrowlBucketView alloc] initWithFrame:CGRectZero] retain];
        sharedNotificationView.hidden = YES;
    }
 
    if(sharedNotificationView.hidden)
        [sharedNotificationView performSelectorOnMainThread:@selector(makeBucketViewAppear)
                                                 withObject:nil
                                              waitUntilDone:NO];
}

- (void) addMessage:(NSString*)message
{
    [messages addObject:message];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SGGrowlView delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) viewDidClose:(SGGrowlView*)view
{
    [self popBucketAtPosition:view.tag];    
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView animation methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) makeBucketViewAppear
{
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    [self fillBucketsWithMessages];
    [self moveBuckets];
    
    self.alpha = 0.0;
    self.hidden = NO;
    
    [UIView beginAnimations:@"Show Bucket" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kAnimation_Duration];
    
    self.alpha = 1.0;
    
    [UIView commitAnimations];
    
    
    bucketUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateTimeInterval) 
                                                        userInfo:nil
                                                         repeats:YES] retain];
        
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:bucketUpdateTimer forMode:@"UITrackingRunLoopMode"];
}

- (void) makeBucketViewDisappear
{
    if(bucketUpdateTimer) {
     
        [bucketUpdateTimer invalidate];
        [bucketUpdateTimer release];
        bucketUpdateTimer = nil;
                
    }
    
    [UIView beginAnimations:@"Show Bucket" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didDisappear)];
    [UIView setAnimationDuration:kAnimation_Duration];
    
    self.alpha = 0.0;
    
    [UIView commitAnimations];
}

- (void) didDisappear
{
    isAnimating = NO;
    self.hidden = YES;
    [self removeFromSuperview];    
}

- (void) updateTimeInterval
{
    timeInterval++;
    
    if(timeInterval > 3) {
        
        [self popBucket];
        timeInterval = 0;
        
    }
}

- (void) popBucket
{
    if(![messages count] && ((SGGrowlView*)[buckets objectAtIndex:1]).message == nil) {
    
        poppedBucketView = [[buckets objectAtIndex:kBucketPosition_Bottom] retain];
        poppedBucketView.delegate = nil;

        [buckets removeObjectAtIndex:kBucketPosition_Bottom];
        [buckets addObject:poppedBucketView];
        [messages removeAllObjects];
        
        [self makeBucketViewDisappear];
        
    } else {
    
        [self popBucketAtPosition:kBucketPosition_Bottom];
        
    }
}

- (void) popBucketAtPosition:(NSInteger)position
{
    
    if(!isAnimating) {
        
        poppedBucketView = [[buckets objectAtIndex:position] retain];
        poppedBucketView.delegate = nil;
        [buckets removeObjectAtIndex:position];
        [buckets addObject:poppedBucketView];
        
        isAnimating = YES;
        [UIView beginAnimations:@"Pop Bucket" context:nil];
        [UIView setAnimationDuration:kAnimation_Duration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didPopBucket)];
    
        poppedBucketView.alpha = 0.0;
    
        [self fillBucketsWithMessages];
    
        [UIView commitAnimations];
    }
}

- (void) didPopBucket
{    
        
    [poppedBucketView clear];
    [poppedBucketView release];
    isAnimating = NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Message handling methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) fillBucketsWithMessages
{
    SGGrowlView* view;
    for(int i = 0; i < 3; i++) {

        view = [buckets objectAtIndex:i];
        view.tag = i;
        
        if([messages count] && ![view message]) {
            
            [view setMessage:[messages objectAtIndex:0]];
            [messages removeObjectAtIndex:0];
            view.alpha = 1.0;
            view.delegate = self;
            
        } 
    }
    
    [self moveBuckets];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) moveBuckets
{
    CGPoint leftCornerPoint;
    CGFloat height = 0.0;
    SGGrowlView* view;
    for(int i = 2; i >= 0; i--) {
        
        view = [buckets objectAtIndex:i];
        
        if(view.tag != -1) {
            
            switch(i) {
         
                case kBucketPosition_Top:
                {
                    leftCornerPoint = CGPointMake(0.0, 0.0);
                    height += view.frame.size.height + 8.0;
                }
                    break;
                    
                case kBucketPosition_Bottom:
                {
                    leftCornerPoint = CGPointMake(0.0, height);
                    height += view.frame.size.height;
                }
                    break;
                    
                case kBucketPosition_Middle:
                {
                    leftCornerPoint = CGPointMake(0.0, height);
                    height += view.frame.size.height + 8.0;
                }
                    break;
                
                default:
                {
                    NSLog(@"SGGrowlView can not be drawn at this time.");
                }
            }
         
            [view setLeftCorner:leftCornerPoint]; 
        } 
        
    }
    
    self.frame = CGRectMake(8.0, 480.0 - 52.0 - height, 302.0, height);
}

- (void) dealloc 
{
    [messages release];
    [buckets release];
    
    [super dealloc];
}


@end
