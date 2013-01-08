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

#define kHapPixelFormatTypeRGB_DXT1 'DXt1'
#define kHapPixelFormatTypeRGBA_DXT1 'DXT1'
#define kHapPixelFormatTypeRGBA_DXT5 'DXT5'
#define kHapPixelFormatTypeYCoCg_DXT5 'DYt5'

BOOL HapSMovieHasHapTrack(QTMovie *movie);
CFDictionaryRef HapSCreateCVPixelBufferOptionsDictionary();

#endif
