//
//  SGAttributeString.m
//  SGAlertStudio
//
//  Created by Derek Smith on 7/8/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGAttributeString.h"

#import "SGNotificationConstants.h"

static NSString* coloredStringId = @"<<<%i>>>";

@implementation SGAttributeString

@synthesize font, textColor;
@dynamic string;

- (id) initWithString:(NSString*)str
{
    if(self = [super init]) {
        string = str;
        textColor = kAttributeStringColor_Default;
        textColors = nil;
        font = [UIFont boldSystemFontOfSize:14.0];
        colorsForWords = nil;
        coloredWords = nil;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (NSString*) string
{
    NSString* newString = string;
    NSString* stringId;
    for(int i = 0; i < [coloredWords count]; i++) {
        
        stringId = [NSString stringWithFormat:coloredStringId, i];
        newString = [newString stringByReplacingOccurrencesOfString:stringId
                                                         withString:[coloredWords objectForKey:stringId]];
    }
    
    return newString;
}

- (void) setString:(NSString*)str
{
    string = str;   
    [coloredWords removeAllObjects];
}

- (void) highlightWord:(NSString*)word withColor:(UIColor*)color
{
    if(string) {
        if(!coloredWords) {
            coloredWords = [[NSMutableDictionary alloc] init];
            colorsForWords = [[NSMutableDictionary alloc] init];
        }
    
        NSInteger coloredWordCount = [coloredWords count];
        
        NSString* stringId = [NSString stringWithFormat:coloredStringId, coloredWordCount];
        
        [coloredWords setValue:word forKey:stringId];
        [colorsForWords setValue:color forKey:stringId];        
        
        string = [[string stringByReplacingOccurrencesOfString:word withString:stringId] retain];
    }
}

- (void) drawStringInRect:(CGRect)rect context:(CGContextRef)context
{
//    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    NSArray* words = [string componentsSeparatedByString:@" "];
        
    NSInteger amountOfWords = [words count];
    
    NSString* word;
    UIColor* wordColor;
    
    CGFloat xcoord = rect.origin.x; 
    CGFloat ycoord = rect.origin.y;
    
    CGSize spaceSize = [@" " sizeWithFont:font];
    CGSize wordSize;
    for(int i = 0; i < amountOfWords; i++) {
        
        word = [words objectAtIndex:i];
        
        wordColor = textColor;
        if([word length] > 6 && [[word substringToIndex:3] isEqualToString:@"<<<"]) {
            
            wordColor = [colorsForWords objectForKey:word];
            word = [coloredWords objectForKey:word];
            
        }
            
        wordSize = [word sizeWithFont:font];
        
        CGContextSetFillColorWithColor(context, [wordColor CGColor]);
        
        [word drawInRect:CGRectMake(xcoord, ycoord, wordSize.width, wordSize.height) 
                withFont:font
           lineBreakMode:UILineBreakModeClip];
        
        xcoord += wordSize.width + spaceSize.width;
        
    }
    
//    CGContextRestoreGState(context);
}

- (CGSize) getSizeOfString
{
    CGSize size;
    if(string) {
        
        size = [string sizeWithFont:font];
        
    } else {
        
        size = CGSizeMake(0.0, 0.0);
        
    }
    
    return size;
}

- (BOOL) canStringFillRect:(CGRect)rect
{
        
    CGSize declaredSize = rect.size;
    CGSize stringSize = [self getSizeOfString];
    
    return declaredSize.height < stringSize.height && declaredSize.width < stringSize.width;;
}

- (void) dealloc
{
    
    [string release];
    [font release];
    [textColor release];
    
    [super dealloc];
}
@end
