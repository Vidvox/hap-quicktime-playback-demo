//
//  HapSupport.h
//  QTMultiGPUTextureIssue
//
//  Created by Tom Butterworth on 15/05/2012.
//  Copyright (c) 2012 Tom Butterworth. All rights reserved.
//

#ifndef QTMultiGPUTextureIssue_HapSupport_h
#define QTMultiGPUTextureIssue_HapSupport_h

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

#if __LP64__

#error Hap QuickTime support requires 32-bit QuickTime APIs but this target is 64-bit

#else

/**
 The four-character-codes used to describe the pixel-formats of DXT frames emitted by the Hap QuickTime codec.
 */
#define kHapPixelFormatTypeRGB_DXT1 'DXt1'
#define kHapPixelFormatTypeRGBA_DXT5 'DXT5'
#define kHapPixelFormatTypeYCoCg_DXT5 'DYt5'

/**
 Returns YES if any track of movie is a Hap track and the codec is installed to handle it, otherwise NO.
 */
BOOL HapQTMovieHasHapTrackPlayable(QTMovie *movie);

/**
 Returns a dictionary suitable to pass with the kQTVisualContextPixelBufferAttributesKey in an options dictionary when
 creating a CVPixelBufferContext.
 */
CFDictionaryRef HapQTCreateCVPixelBufferOptionsDictionary();

#endif

#endif
