/*
 HapQuickTimePlaybackAppDelegate.m
 Hap QuickTime Playback
 
 Copyright (c) 2012-2013, Tom Butterworth and Vidvox LLC. All rights reserved.
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Hap nor the name of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "HapQuickTimePlaybackAppDelegate.h"
#import "HapSupport.h"

/*
 Whenever a frame is ready this gets called by the QTVisualContext, usually on a background thread
 */
static void VisualContextFrameCallback(QTVisualContextRef visualContext, const CVTimeStamp *timeStamp, void *refCon)
{
    OSErr err = noErr;
    CVImageBufferRef image;
    err = QTVisualContextCopyImageForTime(visualContext, nil, nil, &image);
    
    if (err == noErr && image)
    {
        [(HapQuickTimePlaybackAppDelegate *)refCon displayFrame:image];
        CVBufferRelease(image);
    }
    else if (err != noErr)
    {
        NSLog(@"err %hd at QTVisualContextCopyImageForTime(), %s", err, __func__);
    }
    
    QTVisualContextTask(visualContext);
}

@implementation HapQuickTimePlaybackAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.inputSelectionIndex = 0;
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
    
    switch (index)
    {
        case 0:
            title = @"SampleQT";
            break;
        case 1:
            title = @"SampleHap";
            break;
        case 2:
            title = @"SampleHapAlpha";
            break;
        case 3:
            title = @"SampleHapQ";
            break;
        default:
            title = nil;
            break;
    }
    
    if (title)
    {
        // Load our movie
        
        NSURL *url = [[NSBundle mainBundle] URLForResource:title withExtension:@"mov"];
        [self openMovie:url];
    }
}

- (void)openMovie:(NSURL *)url
{
    // Stop and release our previous movie
    
    if (movie)
    {
        [movie stop];
        SetMovieVisualContext([movie quickTimeMovie], NULL);
        [movie release];
        movie = nil;
    }
    
    // For simplicity we rebuild the visual context every time - you could re-use it if the new movie
    // will use exactly the same kind of context as the previous one.
    
    QTVisualContextRelease(visualContext);
    visualContext = NULL;
    
    // Set up the new movie and visual context
    
    movie = [[QTMovie alloc] initWithURL:url error:nil];
    [movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieLoopsAttribute];
    
    // It's important not to play the movie until it has been attached to a context, otherwise it will start decompression with a non-optimal pixel format
    
    OSStatus err = noErr;
    
    // Check if the movie has a Hap video track
    if (HapQTMovieHasHapTrackPlayable(movie))
    {        
        CFDictionaryRef pixelBufferOptions = HapQTCreateCVPixelBufferOptionsDictionary();
        
        // QT Visual Context attributes
        NSDictionary *visualContextOptions = [NSDictionary dictionaryWithObject:(NSDictionary *)pixelBufferOptions
                                                                         forKey:(NSString *)kQTVisualContextPixelBufferAttributesKey];
        
        CFRelease(pixelBufferOptions);
        
        err = QTPixelBufferContextCreate(kCFAllocatorDefault, (CFDictionaryRef)visualContextOptions, &visualContext);
    }
    else
    {
        err = QTOpenGLTextureContextCreate(kCFAllocatorDefault, [[glView openGLContext] CGLContextObj], [[glView pixelFormat] CGLPixelFormatObj], nil, &visualContext);
    }
    if (err != noErr)
    {
        NSLog(@"err %ld, couldnt create visual context at %s", err, __func__);
    }
    else
    {
        // Set the new-frame callback. You could use another mechanism, such as a CVDisplayLink, instead
        
        QTVisualContextSetImageAvailableCallback(visualContext, VisualContextFrameCallback, self);
        
        // Set the movie's visual context
        
        err = SetMovieVisualContext([movie quickTimeMovie],visualContext);
        if (err != noErr)
        {
            NSLog(@"err %ld SetMovieVisualContext %s", err, __func__);
        }
        else
        {
            // The movie was attached to the context, we can start it now
            
            [movie play];
        }
    }
}

- (void)displayFrame:(CVImageBufferRef)frame
{
    // Check what type of frame (pixel-buffer or texture) this is
    
    CFTypeID imageType = CFGetTypeID(frame);
    
    if (imageType == CVOpenGLTextureGetTypeID())
    {
        // If we were previously playing Hap frames, we can dispose of the DXT texture now
        
        if (hapTexture)
        {
            [hapTexture release];
            hapTexture = nil;
        }
        
        CGSize imageSize = CVImageBufferGetEncodedSize(frame);
        
        [glView drawTexture:CVOpenGLTextureGetName(frame) sized:NSSizeFromCGSize(imageSize) flipped:CVOpenGLTextureIsFlipped(frame)];
    }
    else if (imageType == CVPixelBufferGetTypeID())
    {
        // We re-use a texture for uploading the DXT pixel-buffer, create it if it doesn't already exist
        
        if (hapTexture == nil)
        {
            hapTexture = [[HapPixelBufferTexture alloc] initWithContext:[[glView openGLContext] CGLContextObj]];
        }
        
        // Update the texture
        
        hapTexture.buffer = frame;
        
        NSSize imageSize = NSMakeSize(hapTexture.width, hapTexture.height);
        NSSize textureSize = NSMakeSize(hapTexture.textureWidth, hapTexture.textureHeight);
        
        [glView drawTexture:hapTexture.textureName target:GL_TEXTURE_2D imageSize:imageSize textureSize:textureSize flipped:YES usingShader:hapTexture.shaderProgramObject];
    }
}

@end
