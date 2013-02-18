//
//  QTMultiGPUTextureIssueAppDelegate.h
//  QTMultiGPUTextureIssue
//
//  Created by bagheera on 3/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "GLView.h"
#import "HapPixelBufferTexture.h"

@interface HapQuickTimePlaybackAppDelegate : NSObject <NSApplicationDelegate> {
    NSUInteger              inputSelection;
    
    QTMovie                 *movie;
    QTVisualContextRef      visualContext;
    
    IBOutlet GLView         *glView;
    
    HapPixelBufferTexture   *hapTexture;
}

- (void)openMovie:(NSURL *)url;
- (void)displayFrame:(CVImageBufferRef)frame;
@property (assign) NSInteger inputSelectionIndex;
@end
