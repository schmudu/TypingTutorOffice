//
//  BigLetterView.h
//  TypingTutor
//
//  Created by PATRICK LEE on 7/14/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSString+FirstLetter.h"

@interface BigLetterView : NSView{
    NSColor *bgColor;
    NSString *string;
    NSMutableDictionary *attributes;
    BOOL italic;
    BOOL bold;
    IBOutlet NSButton *boldButton;
    IBOutlet NSButton *italicButton;
    NSEvent *mouseDownEvent;
    BOOL highlighted;
}

- (void)prepareAttributes;
- (IBAction)savePDF:(id)sender;
- (IBAction)toggleBold:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

@property (strong) NSColor *bgColor;
@property (copy) NSString *string;

@end
