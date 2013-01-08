//
//  QTMultiGPUTextureIssueAppDelegate.h
//  QTMultiGPUTextureIssue
//
//  Created by bagheera on 3/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <libkern/OSAtomic.h>
#import <OpenGL/CGLMacro.h>
#import <QTKit/QTKit.h>
#import <QuickTime/QuickTime.h>
#import "GLView.h"
#import "HapPixelBufferTexture.h"

@interface HapQuickTimePlaybackAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSUInteger              inputSelection;
    
    OSSpinLock				contextLock;
    NSOpenGLContext			*sharedContext;
    
    QTMovie					*movie;
    QTVisualContextRef		vc;
    
    IBOutlet GLView			*qtGLView;
    
    HapPixelBufferTexture      *pbTexture;
}

- (void) timerCallback:(NSTimer *)t;
- (void)openMovie:(NSURL *)url;
@property (assign) IBOutlet NSWindow *window;
@property (assign) NSInteger inputSelectionIndex;
@end
