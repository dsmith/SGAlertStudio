//
//  SGGrowlView.m
//  SGAlertStudio
//
//  Created by Derek Smith on 7/6/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
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
