//
//  BigLetterView.m
//  TypingTutor
//
//  Created by PATRICK LEE on 7/14/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "BigLetterView.h"

@implementation BigLetterView

#pragma mark Copy and Paste
- (void)writeToPasteboard:(NSPasteboard *)pb{
    // Copy date to the pasteboard
    [pb clearContents];
    [pb writeObjects:[NSArray arrayWithObject:string]];
}

- (BOOL)readFromPasteboard:(NSPasteboard *)pb{
    //NSArray *classes = [NSArray arrayWithObject:[NSString class]];
    NSArray *classes = [NSArray arrayWithObject:[NSString class]];
    NSArray *objects = [pb readObjectsForClasses:classes options:nil];
    
    if ([objects count] > 0){
        // Read the string from the pasteboard
        NSString *value = [objects objectAtIndex:0];
        
        // Our view can handle only one letter
        [self setString:[value bnr_firstLetter]];
        return YES;
        /*
        if ([value length] == 1){
            [self setString:value];
            return YES;
        }*/
    }
    return NO;
}

- (IBAction)cut:(id)sender{
    [self copy:sender];
    [self setString:@""];
}

- (IBAction)copy:(id)sender{
    // Create an NSPasteboardItem and write both the string and PDF data to it:
	NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
	[item setData:[self dataWithPDFInsideRect:[self bounds]] forType:NSPasteboardTypePDF];
	[item setString:string forType:NSPasteboardTypeString];
	
	// Now write the item to the pasteboard:
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb clearContents];
	[pb writeObjects:[NSArray arrayWithObject:item]];
    /*
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [self writeToPasteboard:pb];
     */
}

- (IBAction)paste:(id)sender{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    if(![self readFromPasteboard:pb]){
        NSBeep();
    }
}

#pragma mark Font decoration
- (IBAction)toggleBold:(id)sender{
    [self setNeedsDisplay:YES];
}

- (IBAction)toggleItalic:(id)sender{
    [self setNeedsDisplay:YES];
}

#pragma drawing pdf
- (IBAction)savePDF:(id)sender{
    __block NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
    
    [panel beginSheetModalForWindow:[self window] completionHandler:^ (NSInteger result){
        if (result == NSOKButton){
            NSRect r = [self bounds];
            NSData *data = [self dataWithPDFInsideRect:r];
            NSError *error;
            BOOL successful = [data writeToURL:[panel URL] options:0 error:&error];
            
            if (!successful){
                NSAlert *a = [NSAlert alertWithError:error];
                [a runModal];
            }
        }
        
        panel = nil; //avoid strong ref cycle
    }];
}

#pragma mark Font
- (void)prepareAttributes{
    attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[NSFont userFontOfSize:75] forKey:NSFontAttributeName];
}

- (void)drawStringCenteredIn:(NSRect)r{
    NSSize strSize = [string sizeWithAttributes:attributes];
    NSPoint strOrigin;
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:30];
    NSFontManager *fontManager;
    fontManager = [NSFontManager sharedFontManager];
    //NSFont *helvetica = [fontManager convertWeight:YES ofFont:font];
    
    NSLog(@"drawing letter...");
    
    
    // Create and stroke the shadow
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor redColor]];
    [shadow setShadowBlurRadius:10.0];
    [shadow set];
    
    //check italic
    if([italicButton state] == YES){
        font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSItalicFontMask];
    }
    
    //check bold
    if([boldButton state] == YES){
        font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSBoldFontMask];
    }
        
    [attributes setObject:font forKey:NSFontAttributeName];
    strOrigin.x = r.origin.x + (r.size.width - strSize.width)/2;
    strOrigin.y = r.origin.y + (r.size.width - strSize.width)/2;
    [string drawAtPoint:strOrigin withAttributes:attributes];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"initializing view");
        [self prepareAttributes];
        bgColor = [NSColor yellowColor];
        string = @" ";
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeString]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    [bgColor set];
    [NSBezierPath fillRect:bounds];
    
    // Draw gradient background if highlighed
    if (highlighted){
        NSGradient *gr;
        gr = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:bgColor];
        [gr drawInRect:bounds relativeCenterPosition:NSZeroPoint];
    }
    else{
        [bgColor set];
        [NSBezierPath fillRect:bounds];
    }
    
    [self drawStringCenteredIn:bounds];
    
    // Am I the window's first responder?
    if (([[self window] firstResponder] == self) && ([NSGraphicsContext currentContextDrawingToScreen])){
        /*
        [[NSColor keyboardFocusIndicatorColor] set];
        [NSBezierPath setDefaultLineWidth:4.0];
        [NSBezierPath strokeRect:bounds];
         */
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [NSBezierPath fillRect:bounds];
        [NSGraphicsContext restoreGraphicsState];
    }
}
         
- (BOOL)isOpaque{
    return YES;
}

#pragma mark Responder
- (BOOL)acceptsFirstResponder{
    //NSLog(@"Accepting");
    return YES;
}

- (BOOL)resignFirstResponder{
    //NSLog(@"Resigning");
    //[self setNeedsDisplay:YES];
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    return YES;
}

- (BOOL)becomeFirstResponder{
    //NSLog(@"Becoming");
    [self setNeedsDisplay:YES];
    return YES;
}

#pragma mark Keyboard Events

- (void)keyDown:(NSEvent *)theEvent{
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

- (void)insertText:(id)insertString{
    //Set string to be what the user typed
    [self setString:insertString];
}

- (void)insertTab:(id)sender{
    [[self window] selectKeyViewFollowingView:self];
}

- (void)insertBacktab:(id)sender{
    [[self window] selectKeyViewPrecedingView:self];
}

- (void)deleteWordBackward:(id)sender{
    [self setString:@" "];
}

#pragma mark Accessors

- (void)setBgColor:(NSColor *)color{
    bgColor = color;
    [self setNeedsDisplay:YES];
}

- (NSColor *)bgColor{
    return bgColor;
}

- (void)setString:(NSString *)c{
    string = c;
    [self setNeedsDisplay:YES];
}

- (NSString *)string{
    return string;
}

#pragma mark Drag and Drop
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag{
    return NSDragOperationCopy | NSDragOperationDelete;
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation{
    if (operation == NSDragOperationDelete){
        [self setString:@""];
    }
}

- (void)mouseDown:(NSEvent *)event{
    mouseDownEvent = event;
}

- (void)mouseDragged:(NSEvent *)event{
    NSPoint down = [mouseDownEvent locationInWindow];
    NSPoint drag = [event locationInWindow];
    float distance = hypot(down.x - drag.x, down.y - drag.y);
    if (distance < 3){
        return;
    }
    
    // Is the string of zero length?
    if ([string length] == 0){
        return;
    }
    
    // Get the size of the string
    NSSize s = [string sizeWithAttributes:attributes];
    
    // Create the image that will be dragged
    NSImage *anImage = [[NSImage alloc] initWithSize:s];
    
    // Create a rect in which you will draw the letter in the image
    NSRect imageBounds;
    imageBounds.origin = NSZeroPoint;
    imageBounds.size = s;
    
    //Draw the letter on the image
    [anImage lockFocus];
    [self drawStringCenteredIn:imageBounds];
    [anImage unlockFocus];
    
    //Get the location of the mouseDown event
    NSPoint p = [self convertPoint:down fromView:nil];
    
    // Drag from the center of the image
    p.x = p.x - s.width/2;
    p.y = p.y - s.height/2;
    
    // Get the pasteboard
    NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
    
    // Put the string on the pasteboard
    [self writeToPasteboard:pb];
    
    // Start the drag
    [self dragImage:anImage at:p offset:NSZeroSize event:mouseDownEvent pasteboard:pb source:self slideBack:YES];
}

#pragma mark Dragging Destination
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSLog(@"draggingEntered:");
    if ([sender draggingSource] == self){
        return NSDragOperationNone;
    }
    
    highlighted = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender{
    NSLog(@"draggingExited:");
    highlighted = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard *pb = [sender draggingPasteboard];
    if(![self readFromPasteboard:pb]){
       NSLog(@"Error: Could not read from dragging pasteboard");
       return NO;
    }
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender{
    NSLog(@"concludeDragOperation:");
    highlighted = NO;
    [self setNeedsDisplay:YES];
}
@end

