//
// --------------------------------------------------------------------------
// MFNotificationLabel.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2021
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "MFNotificationLabel.h"

@implementation MFNotificationLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"INIT LABEL");
//        [self setSelectable: YES]; // Need this to make links work // This doesn't work, need to set this in IB
//        self.delegate = self; // This doesn't work, need to set this in IB
    }
    return self;
}

// Override text selection methods to disallow selection
- (void)setSelectedRanges:(NSArray<NSValue *> *)ranges
                 affinity:(NSSelectionAffinity)affinity
           stillSelecting:(BOOL)stillSelectingFlag {
}
//- (NSArray<NSValue *> *)textView:(NSTextView *)textView willChangeSelectionFromCharacterRanges:(NSArray<NSValue *> *)oldSelectedCharRanges toCharacterRanges:(NSArray<NSValue *> *)newSelectedCharRanges {
//
//    NSValue *nullRangeValue = [NSValue valueWithRange:NSMakeRange(0, 0)];
//    return @[nullRangeValue];
//}

- (void)mouseDragged:(NSEvent *)event {
    
}
//- (void)mouseDown:(NSEvent *)event {
//    NSLog(@"MMMHOUSUH DOWNNNUHH");
//    [super mouseDown:event];
//}
//
//- (void)clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
//    NSLog(@"CLICKED ONUH LINKKKKKUHHHH");
//}

@end
