//
//  QTMultiGPUTextureIssueAppDelegate.m
//  QTMultiGPUTextureIssue
//
//  Created by bagheera on 3/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "VPUQuickTimePlaybackAppDelegate.h"
#import "VPUSupport.h"
#import "VVBasicMacros.h"
#import <OpenGL/CGLMacro.h>

@implementation VPUQuickTimePlaybackAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    sharedContext = [[NSOpenGLContext alloc] initWithFormat:[qtGLView pixelFormat] shareContext:[qtGLView openGLContext]];
	
    self.inputSelectionIndex = 0;
    
	[NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
}

- (IBAction)openDocument:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[QTMovie movieFileTypes:0]];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            self.inputSelectionIndex = -1;            
            [self openMovie:[panel URL]];
        }
    }];
}

- (NSInteger)inputSelectionIndex
{
    return inputSelection;
}

- (void)setInputSelectionIndex:(NSInteger)index
{
    inputSelection = index;
    NSString *title;
    switch (index) {
        case 0:
            title = @"SampleQT";
            break;
        case 1:
            title = @"SampleVPU";
            break;
        case 2:
            title = @"SampleVPUAlpha";
            break;
        case 3:
            title = @"SampleVPUYCoCg";
            break;
        default:
            title = nil;
            break;
    }
    if (title)
    {
        NSURL *url = [[NSBundle mainBundle] URLForResource:title withExtension:@"mov"];
        [self openMovie:url];
    }
}

- (void)openMovie:(NSURL *)url
{
    // stop and release our old stuff
    if (movie)
    {
        [movie stop];
        SetMovieVisualContext([movie quickTimeMovie], NULL);
        [movie release];
        movie = nil;
    }
    
    [pbTexture release];
    pbTexture = nil;
    
    QTVisualContextRelease(vc);
    vc = NULL;
    
    // set up the new movie and visual context
    // in a "real" app you would only need to change the context when the need for a pixel-buffer versus texture context changed
    // as this app toggles between the two, we need to change it every time
    
    movie = [[QTMovie alloc] initWithURL:url error:nil];
    [movie setAttribute:NUMBOOL(YES) forKey:QTMovieLoopsAttribute];
    
    // don't play the movie until it has been attached to a context, otherwise it will start decompression with a non-optimal pixel format
    
    OSStatus		err = noErr;
    if (VPUSMovieHasVPUTrack(movie))
    {
        // we re-use a texture for uploading the DXT pixel-buffer
        pbTexture = [[VPUPixelBufferTexture alloc] initWithContext:[sharedContext CGLContextObj]];
        
        CFDictionaryRef pixelBufferOptions = VPUCreateCVPixelBufferOptionsDictionary();
        
        // QT Visual Context attributes
        NSDictionary *visualContextOptions = [NSDictionary dictionaryWithObject:(NSDictionary *)pixelBufferOptions
                                                                         forKey:(NSString *)kQTVisualContextPixelBufferAttributesKey];
        
        CFRelease(pixelBufferOptions);
        
        err = QTPixelBufferContextCreate(kCFAllocatorDefault, (CFDictionaryRef)visualContextOptions, &vc);
    }
    else
    {
        err = QTOpenGLTextureContextCreate(kCFAllocatorDefault,[sharedContext CGLContextObj],[[qtGLView pixelFormat] CGLPixelFormatObj],nil,&vc);
    }
    if (err != noErr)	{
        NSLog(@"\t\terr %ld, couldnt create visual context at %s",err,__func__);
    }
    else	{
        Movie		qtMovie = [movie quickTimeMovie];
        err = SetMovieVisualContext(qtMovie,vc);
        if (err != noErr)	{
            NSLog(@"\t\terr %ld SetMovieVisualContext %s",err,__func__);
        }
        else
        {
            // the movie was attached to the context, we can start it now
            [movie play];
        }
    }
}

- (void) timerCallback:(NSTimer *)t
{
	CVImageBufferRef		vcImage = NULL;
	if (QTVisualContextIsNewImageAvailable(vc,0))	{
		OSErr					err = noErr;
		err = QTVisualContextCopyImageForTime(vc,nil,nil,&vcImage);
		if (err != noErr)	{
			NSLog(@"\t\terr %hd at QTVisualContextCopyImageForTime(), %s",err,__func__);
			vcImage = NULL;
		}
	}
    /*
	else
		NSLog(@"\t\terr: no new frame available for QT!");
     */
	if (vcImage != NULL)	{
        CFTypeID    imageType = CFGetTypeID(vcImage);
        if (imageType == CVOpenGLTextureGetTypeID())
        {
            CGSize		imageSize = CVImageBufferGetEncodedSize(vcImage);
            [qtGLView drawTexture:CVOpenGLTextureGetName(vcImage) sized:CGMAKENSSIZE(imageSize) flipped:CVOpenGLTextureIsFlipped(vcImage)];
        }
        else if (imageType == CVPixelBufferGetTypeID())
        {
            pbTexture.buffer = vcImage;
            NSSize imageSize = NSMakeSize(pbTexture.width, pbTexture.height);
            NSSize textureSize = NSMakeSize(pbTexture.textureWidth, pbTexture.textureHeight);
            [qtGLView drawTexture:pbTexture.textureName target:GL_TEXTURE_2D imageSize:imageSize textureSize:textureSize flipped:YES usingShader:pbTexture.shaderProgramObject];
        }
		CVBufferRelease(vcImage);
	}
	QTVisualContextTask(vc);
}

@synthesize window;


@end
