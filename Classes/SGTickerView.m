//
//  SGTickerView.m
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

#import "SGTickerView.h"

static SGTickerView* sharedTicker = nil;

#define kMessageSpace_Width         8.0

@interface SGTickerView (Private)

- (void) addNextViewableMessage;
- (void) removeFinishedViewableMessages;
- (void) moveTicker;

- (void) createGradient;

@end


@implementation SGTickerView

- (id) initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {

        messages = [[NSMutableArray alloc] init];
        viewableMessages = [[NSMutableArray alloc] init];
        
        drawTickerTimer = nil;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
     
        historyMode = NO;
//        [self createGradient];
    }
    
    return self;
}

- (void) createGradient
{
    // prepare the gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat colorComponents[2][4] = {
        {0.0f, 0.0f, 0.0f, 0.70f},
        {0.0f, 0.0f, 0.0f, 1.0f}
        };
    
    CGFloat locations[2] = {0.1, 0.6};
    
    CGColorRef rawColors[4];
    rawColors[0] = CGColorCreate(colorSpace, colorComponents[0]);
    rawColors[1] = CGColorCreate(colorSpace, colorComponents[1]);
    
    CFArrayRef colors = CFArrayCreate(NULL, (void*)&rawColors, 2, NULL);
	
    fadeGradient = CGGradientCreateWithColors(colorSpace, colors, locations);
	
    CGColorRelease(rawColors[0]);
    CGColorRelease(rawColors[1]);
    CFRelease(colors);
    CGColorSpaceRelease(colorSpace);
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Static Accessors 
//////////////////////////////////////////////////////////////////////////////////////////////// 

+ (SGTickerView*) sharedTicker
{
    if(!sharedTicker)
        sharedTicker = [[SGTickerView alloc] initWithFrame:CGRectZero];
    
    return sharedTicker;
}

+ (void) setSharedTicker:(SGTickerView*)ticker
{
    if(sharedTicker)
        [sharedTicker release];
    
    sharedTicker = [ticker retain];
}

+ (void) addMessage:(SGTickerMessage*)message priority:(enum TickerMessagePriority)priority
{
    if(!sharedTicker)
        sharedTicker = [SGTickerView sharedTicker];
    
    [sharedTicker addMessage:message priority:priority];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTimer methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) startTicker
{
    if(!drawTickerTimer && [messages count]) {
        
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        
        
        drawTickerTimer  = [[NSTimer scheduledTimerWithTimeInterval:2.0/60.0
                                                   target:self
                                                 selector:@selector(moveTicker)
                                                 userInfo:nil
                                                  repeats:YES] retain];
        
        [runLoop addTimer:drawTickerTimer forMode:@"UITrackingRunLoopMode"];
        
        if(![viewableMessages count])
            [self addNextViewableMessage];

    }
}

- (void) stopTicker
{
    if(drawTickerTimer) {   
        
        [drawTickerTimer invalidate];
        [drawTickerTimer release];
        drawTickerTimer = nil;
            
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Message handlers 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) addMessage:(SGTickerMessage*)message priority:(enum TickerMessagePriority)priority
{
    if(priority == kTickerMessagePriority_High)
        [messages insertObject:message atIndex:0];
    else
        [messages addObject:message];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    historyMode = YES;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent*)event
{
    
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    historyMode = NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Drawing methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) moveTicker
{
    if(!historyMode) {
        // If we have pending messages, we need to make sure that the ticker is 
        // fully loaded
        if([messages count]) {
            if(![viewableMessages count])
                [self addNextViewableMessage];
            else {
                SGTickerMessage* lastMessage = [viewableMessages objectAtIndex:[viewableMessages count] - 1];
            
                if(lastMessage.endCoord > kMessageSpace_Width) 
                    [self addNextViewableMessage];
            }
        }
    
        for(SGTickerMessage* message in viewableMessages)
            [message advanceTickMessage:1.0];
        
        [self removeFinishedViewableMessages];
  
        [self setNeedsDisplay];
    }
}

- (void) removeFinishedViewableMessages
{
    CGSize messageSize;
    if([viewableMessages count]) {
        SGTickerMessage* message = [viewableMessages objectAtIndex:0];
     
        messageSize = [message getSizeOfString];
        if(message.endCoord && message.startCoord > 320.0 + messageSize.width) {
            if(message.reuse)
                [messages addObject:message];
            
            [viewableMessages removeObjectAtIndex:0];
        }
    }
}
    
- (void) addNextViewableMessage
{
    if([messages count]) {
        SGTickerMessage* nextMessage = [messages objectAtIndex:0];
        [nextMessage reset];
        
        [viewableMessages addObject:nextMessage];
        [messages removeObjectAtIndex:0];
    }
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSInteger messageAmount = [viewableMessages count];
    SGTickerMessage* message;
    
    CGContextSaveGState(context);
    
    CGFloat xCoord;
    CGSize messageSize;
    CGRect drawingRect;
    CGFloat messageWidth;
    for(int i = 0; i < messageAmount; i++) {
        
        message = [viewableMessages objectAtIndex:i];
        xCoord = rect.size.width - message.startCoord;
        messageSize = [message getSizeOfString];
        
        drawingRect = CGRectMake(xCoord,
                                 (rect.size.height - messageSize.height) / 2.0,
                                 messageWidth,
                                 messageSize.height);
        
        [message drawStringInRect:drawingRect context:context];
        
    }

    CGContextRestoreGState(context);
    
//    CGContextDrawLinearGradient(context, fadeGradient, CGPointMake(13.0, 0.0), CGPointMake(0.0, 0.0), kCGGradientDrawsAfterEndLocation); 
//    CGContextDrawLinearGradient(context, fadeGradient, CGPointMake(rect.size.width - 13.0, 0.0), CGPointMake(rect.size.width, 0.0), kCGGradientDrawsAfterEndLocation); 

}


- (void) dealloc 
{
    [messages release];
    
    if(drawTickerTimer)
        [drawTickerTimer release];
    
    [super dealloc];
}


@end
