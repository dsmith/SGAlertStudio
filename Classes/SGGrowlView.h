//
//  SGGrowlView.h
//  SGAlertStudio
//
//  Created by Derek Smith on 7/6/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SGGrowlViewDelegate;

@interface SGGrowlView : UIView {

    NSString* message;
    BOOL isLastNotification;
    
    id<SGGrowlViewDelegate> delegate;
    
    @private
    UIButton* closeButton;
    
    UILabel* messageLabel;
    UIImageView* backgroundView;
}

@property (nonatomic, retain, readwrite) NSString* message;
@property (nonatomic, assign, readwrite) id<SGGrowlViewDelegate> delegate;

- (id) initWithTag:(NSInteger)tag;

- (void) setLeftCorner:(CGPoint)point;

- (void) clear;

@end

@protocol SGGrowlViewDelegate

- (void) viewDidClose:(SGGrowlView*)view;

@end
