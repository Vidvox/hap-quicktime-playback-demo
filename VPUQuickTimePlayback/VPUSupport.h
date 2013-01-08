//
//  VPUSupport.h
//  QTMultiGPUTextureIssue
//
//  Created by Tom Butterworth on 15/05/2012.
//  Copyright (c) 2012 Tom Butterworth. All rights reserved.
//

#ifndef QTMultiGPUTextureIssue_VPUSupport_h
#define QTMultiGPUTextureIssue_VPUSupport_h

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

#define kVPUSPixelFormatTypeRGB_DXT1 'DXt1'
#define kVPUSPixelFormatTypeRGBA_DXT1 'DXT1'
#define kVPUSPixelFormatTypeRGBA_DXT5 'DXT5'
#define kVPUSPixelFormatTypeYCoCg_DXT5 'DYt5'

BOOL VPUSMovieHasVPUTrack(QTMovie *movie);
CFDictionaryRef VPUCreateCVPixelBufferOptionsDictionary();

#endif
