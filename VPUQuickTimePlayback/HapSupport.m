//
//  HapSupport.m
//  QTMultiGPUTextureIssue
//
//  Created by Tom Butterworth on 15/05/2012.
//  Copyright (c) 2012 Tom Butterworth. All rights reserved.
//

#include "HapSupport.h"
#import <QuickTime/QuickTime.h>

#pragma GCC push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
BOOL HapSMovieHasHapTrack(QTMovie *movie)
{
    BOOL hasHap = NO;
    for (QTTrack *track in [movie tracksOfMediaType:QTMediaTypeVideo])
    {
        Media media = [[track media] quickTimeMedia];
        
        ImageDescriptionHandle imageDescription = (ImageDescriptionHandle)NewHandle(0); // GetMediaSampleDescription will resize it
        GetMediaSampleDescription(media, 1, (SampleDescriptionHandle)imageDescription);
        if ((*imageDescription)->cType == 'VPUV')
        {
            hasHap = YES;
        }
        DisposeHandle((Handle)imageDescription);
    }
    return hasHap;
}
#pragma GCC pop

CFDictionaryRef HapSCreateCVPixelBufferOptionsDictionary()
{
    // the pixel formats we want. These are registered by the Hap codec.
    SInt32 rgb_dxt1 = kHapPixelFormatTypeRGB_DXT1;
    SInt32 rgba_dxt1 = kHapPixelFormatTypeRGBA_DXT1;
    SInt32 rgba_dxt5 = kHapPixelFormatTypeRGBA_DXT5;
    SInt32 ycocg_dxt5 = kHapPixelFormatTypeYCoCg_DXT5;
    
    const void *formatNumbers[4] = {
        CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &rgb_dxt1),
        CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &rgba_dxt1),
        CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &rgba_dxt5),
        CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &ycocg_dxt5)
    };
    
    CFArrayRef formats = CFArrayCreate(kCFAllocatorDefault, formatNumbers, 4, &kCFTypeArrayCallBacks);
    
    CFRelease(formatNumbers[0]);
    CFRelease(formatNumbers[1]);
    CFRelease(formatNumbers[2]);
    CFRelease(formatNumbers[3]);
    
    const void *keys[2] = { kCVPixelBufferPixelFormatTypeKey, kCVPixelBufferOpenGLCompatibilityKey };
    const void *values[2] = { formats, kCFBooleanTrue };
    
    CFDictionaryRef dictionary = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFRelease(formats);
    
    return dictionary;
}