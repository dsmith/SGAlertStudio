//
//  SGGrowlView.m
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

#import "SGGrowlView.h"

#import "SGNotificationConstants.h"

@interface SGGrowlView (Private)
- (void) initializeSubViews;
@end

@implementation SGGrowlView

@synthesize delegate;
@dynamic message;

- (id) initWithTag:(NSInteger)tag
{
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, 302.0, 0.0)]) {
        self.backgroundColor = [UIColor clearColor];
        delegate = nil;
        [self initializeSubViews];
        self.tag = tag;
    }
    
    return self;
}

- (void) initializeSubViews
{
    backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    backgroundView.image = [[UIImage imageNamed:kGrowlView_NotificationImage] stretchableImageWithLeftCapWidth:15.0 topCapHeight:15.0];
    [self addSubview:backgroundView];
    
    messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    messageLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textAlignment = UITextAlignmentCenter;
    messageLabel.numberOfLines = 3;
    messageLabel.font = [UIFont fontWithName:kGrowlView_MessageFont size:14.0];
    messageLabel.textColor = [UIColor whiteColor];
    [self addSubview:messageLabel];
    
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 26.0, 30.0)];
    [closeButton setBackgroundImage:[UIImage imageNamed:kGrowlView_CloseImage] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIButton methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) closeView:(id)button
{
    if(delegate)
        [delegate viewDidClose:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) setLeftCorner:(CGPoint)point
{
    self.frame = CGRectMake(point.x, point.y, self.bounds.size.width, self.bounds.size.height);
    [self setNeedsLayout];
}

- (NSString*) message
{
    return messageLabel.text;
}

- (void) setMessage:(NSString*)mess
{
    messageLabel.text = mess;
 
    NSString* text = messageLabel.text;
    if(!text)
        text = @"M";
    
    CGSize characterSize = [text sizeWithFont:messageLabel.font];
    CGSize textSize = [text sizeWithFont:messageLabel.font
					   constrainedToSize:CGSizeMake(self.bounds.size.width - 64.0, characterSize.height * 3.0)
						   lineBreakMode:UILineBreakModeWordWrap];
    
    if(textSize.height < 20.0)
        textSize.height = 42.0;
    else 
        textSize.height = textSize.height + 16.0;

        
    self.bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, textSize.height + 12.0);
    
    messageLabel.frame = CGRectMake(40.0, 6.0, self.bounds.size.width - (64.0), self.bounds.size.height - 12.0);
    
}

- (void) clear
{
    messageLabel.text = nil;
    self.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) layoutSubviews
{
    backgroundView.frame = self.bounds;
    
    closeButton.frame = CGRectMake(8.0,
                                   (self.frame.size.height - closeButton.frame.size.height) / 2.0,
                                   closeButton.frame.size.width,
                                   closeButton.frame.size.height);
    
}

- (void) dealloc
{
    [closeButton release];
    [messageLabel release];
    [backgroundView release];
    
    [super dealloc];
}


@end
