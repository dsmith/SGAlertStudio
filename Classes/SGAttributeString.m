//
//  SGAttributeString.m
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
