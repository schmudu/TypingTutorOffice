//
//  TutorController.h
//  TypingTutor
//
//  Created by PATRICK LEE on 7/15/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BigLetterView;
@interface TutorController : NSObject{
    // Outlets
    IBOutlet BigLetterView *inLetterView;
    IBOutlet BigLetterView *outLetterView;
    IBOutlet NSWindow *speedSheet;
    
    // Data
    NSArray *letters;
    int lastIndex;
    
    // Time
    NSTimeInterval startTime;
    NSTimeInterval elapsedTime;
    NSTimeInterval timeLimit;
    NSTimer *timer;
}

- (IBAction)stopGo:(id)sender;
- (IBAction)showSpeedSheet:(id)sender;
- (IBAction)endSpeedSheet:(id)sender;

- (void)updateElapsedTime;
- (void)resetElapsedTime;
- (void)showAnotherLetter;

@end
