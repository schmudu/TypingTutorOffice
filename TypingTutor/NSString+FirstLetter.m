//
//  NSString+FirstLetter.m
//  TypingTutor
//
//  Created by PATRICK LEE on 7/15/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSString+FirstLetter.h"

@implementation NSString (FirstLetter)

- (NSString *)bnr_firstLetter{
    if ([self length] < 2){
        return self;
    }
    NSRange r;
    r.location = 0;
    r.length = 1;
    return [self substringWithRange:r];
}

@end
