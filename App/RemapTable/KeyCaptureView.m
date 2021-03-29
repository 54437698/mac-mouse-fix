//
// --------------------------------------------------------------------------
// MFKeystrokeCaptureView.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2021
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "KeyCaptureView.h"
#import "AppDelegate.h"
#import "UIStrings.h"
#import <Carbon/Carbon.h>
#import "SharedMessagePort.h"
#import "NSView+Additions.h"

@interface KeyCaptureView ()

@end

@implementation KeyCaptureView {
    
    BOOL _isCapturing;
    
    CaptureHandler _captureHandler;
    CancelHandler _cancelHandler;
    
    id _localEventMonitor;
    
    NSDictionary *_attributesFromIB;
}

#pragma mark - (Pseudo) Properties

- (void)setCoolString:(NSString *)string {
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:_attributesFromIB];
    
    self.textStorage.attributedString = attributedString;
}

#pragma mark - Setup

- (void)setupWithCaptureHandler:(CaptureHandler)captureHandler
                   cancelHandler:(CancelHandler)cancelHandler {
    
#if DEBUG
    NSLog(@"Setting up keystroke capture view");
#endif
    
    self.delegate = self;
    _captureHandler = captureHandler;
    _cancelHandler = cancelHandler;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppDelegate.mainWindow makeFirstResponder:self];
    });
    // ^ This view is being drawn by the tableView. Using dispatch_async makes it execute after the tableView is done drawing preventing a crash
    
}

#pragma mark - Init and drawing

- (void)awakeFromNib {
    
    if (_attributesFromIB == nil) {
        _attributesFromIB = [self.attributedString attributesAtIndex:0 effectiveRange:nil];
    }
}

- (void)drawEmptyAppearance {
    
    self.coolString = @"Type a Keyboard Shortcut";
    self.textColor = NSColor.placeholderTextColor;
    
    [self selectAll:nil];
}

#pragma mark keyCaptureModeFeedback

+ (void)handleKeyCaptureModeFeedbackWithPayload:(NSDictionary *)payload {
    
    // Find keyCaptureField instance in remapsTable
    
    NSTableView *remapsTable = AppDelegate.instance.remapsTable;
    NSInteger effectColumn = [remapsTable columnWithIdentifier:@"effect"];
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    for (int r = 0; r < remapsTable.numberOfRows; r++) {
        NSView *effectView = [AppDelegate.instance.remapsTable viewAtColumn:effectColumn row:r makeIfNecessary:NO];
        if ([effectView.identifier isEqual:@"keyCaptureCell"]) {
            [indexes addIndex:r];
        }
    }
    assert(indexes.count <= 1);
    if (indexes.count == 0) return;
    
    NSTableCellView *keyCaptureCell = [AppDelegate.instance.remapsTable viewAtColumn:effectColumn row:indexes.firstIndex makeIfNecessary:NO];
    KeyCaptureView *keyCaptureView = (KeyCaptureView *)[keyCaptureCell nestedSubviewsWithIdentifier:@"keyCaptureView"].firstObject;
    
    // Send payload to found instance
    
    [keyCaptureView handleKeyCaptureModeFeedbackWithPayload:payload];
}

- (void)handleKeyCaptureModeFeedbackWithPayload:(NSDictionary *)payload {
    
    _isCapturing = NO; // Helper disabled keyCaptureMode after sending payload
    
    CGKeyCode keyCode = ((NSNumber *)payload[@"keyCode"]).unsignedShortValue;
    CGEventFlags flags = ((NSNumber *)payload[@"flags"]).unsignedLongValue;
    
    [AppDelegate.mainWindow makeFirstResponder:nil]; // Important to call this before capture handler, otherwise `resignFirstResponder:` (our teardown function) isn't called
    _captureHandler(keyCode, flags); // This should undraw the view
}

#pragma mark FirstResponderStatus handlers

- (BOOL)becomeFirstResponder {
    
#if DEBUG
    NSLog(@"BECOME FIRST RESPONDER");
#endif
    
    BOOL superAccepts = [super becomeFirstResponder];
    
    if (superAccepts) {
        
        _isCapturing = YES;
        
        [NSNotificationCenter.defaultCenter addObserverForName:NSWindowDidResignKeyNotification object:AppDelegate.mainWindow queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                    [AppDelegate.mainWindow makeFirstResponder:nil];
        }];
        
        [SharedMessagePort sendMessage:@"enableKeyCaptureMode" withPayload:@"" expectingReply:NO];
        
        [self drawEmptyAppearance];
        
        _localEventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskFlagsChanged | NSEventMaskKeyDown) handler:^NSEvent * _Nullable(NSEvent * _Nonnull event) {
            CGEventRef e = event.CGEvent;
            // User is playing around with modifier keys
            
            if (event.type == NSEventTypeFlagsChanged) {
                CGEventFlags flags = CGEventGetFlags(e);
                
                NSString *modString = [UIStrings getKeyboardModifierString:flags];
                if (modString.length > 0) {
                    self.coolString = modString;
                } else {
                    [self drawEmptyAppearance];
                }
            } else if (event.type == NSEventTypeKeyDown) {
                assert(!self->_isCapturing); // _isCapturing should be set to NO by `handleKeyCaptureModeFeedbackWithPayload:` before this is executed.
            }
            
            return nil;
        }];
    }
    
    return superAccepts;
}
- (BOOL)resignFirstResponder {

#if DEBUG
    NSLog(@"RESIGN FIRST RESPONDER");
#endif
    
    BOOL superResigns = [super resignFirstResponder];

    if (superResigns) {
        
        [SharedMessagePort sendMessage:@"disableKeyCaptureMode" withPayload:nil expectingReply:NO];
        
        [NSEvent removeMonitor:_localEventMonitor];
        _cancelHandler();
    }
    return superResigns;
}

#pragma mark - Disable MouseDown and mouseover cursor

- (void)mouseDown:(NSEvent *)event {
    // Ignore
}
- (void)mouseMoved:(NSEvent *)event {
    [NSCursor.arrowCursor set]; // Prevent text insertion cursor from appearing on mouseover
}
- (void)scrollWheel:(NSEvent *)event {
    [NSCursor.arrowCursor set]; // Prevent text insertion cursor from appearing on scroll
}

@end