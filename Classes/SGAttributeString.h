//
//  SGAttributeString.h
//  SGAlertStudio
//
//  Created by Derek Smith on 7/8/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SGAttributeString : NSObject {

    NSString* string;
    UIFont* font;
    
    UIColor* textColor;
    
    @private
    NSMutableArray* textColors;
    
    NSMutableDictionary* colorsForWords;
    NSMutableDictionary* coloredWords;
}

@property (nonatomic, assign, readwrite) NSString* string;
@property (nonatomic, retain, readwrite) UIColor* textColor;
@property (nonatomic, retain, readwrite) UIFont* font;

- (id) initWithString:(NSString*)str;

- (void) highlightWord:(NSString*)word withColor:(UIColor*)color;
- (void) drawStringInRect:(CGRect)rect context:(CGContextRef)context;
- (CGSize) getSizeOfString;

- (BOOL) canStringFillRect:(CGRect)rect;

@end
