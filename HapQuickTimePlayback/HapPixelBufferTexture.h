//
//  HapPixelBufferTexture.h
//
//  Created by Tom Butterworth on 16/05/2012.
//  Copyright (c) 2012 Tom Butterworth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <OpenGL/OpenGL.h>

/**
 A class to maintain a DXT-compressed texture for upload of DXT frames from CoreVideo pixel-buffers.
 
 To handle Scaled YCoCg DXT5 (Hap Q), requires an accompanying shader in two resource files:
    ScaledCoCgYToRGBA.vert
    ScaledCoCgYToRGBA.frag
 */
@interface HapPixelBufferTexture : NSObject
{
@private
    CGLContextObj   cgl_ctx;
    GLuint          texture;
    CVPixelBufferRef buffer;
    GLuint    backingHeight;
    GLuint     backingWidth;
    GLuint            width;
    GLuint           height;
    BOOL              valid;
    GLenum   internalFormat;
    GLhandleARB      shader;
}
/**
 Returns a HapPixelBufferTexture to draw in the provided CGL context.
 */
- (id)initWithContext:(CGLContextObj)context;

/**
 The pixel-buffer to draw. It must have a pixel-format type (as returned
 by CVPixelBufferGetPixelFormatType()) of one of the DXT formats in HapSupport.h.
 */
@property (readwrite) CVPixelBufferRef buffer;

/**
 The name of the GL_TEXTURE_2D texture.
 */
@property (readonly) GLuint textureName;

/**
 The width of the texture in texels. This may be greater than the image width.
 */
@property (readonly) GLuint textureWidth;

/**
 The height of the texture in texels. This may be greater than the image height.
 */
@property (readonly) GLuint textureHeight;

/**
 The width of the image in texels. The image may not fill the entire texture.
 */
@property (readonly) GLuint width;

/**
 The height of the image in texels. The image may not fill the entire texture.
 */
@property (readonly) GLuint height;

/**
 YCoCg DXT requires a shader to convert color values when it is drawn.
 If the attached pixel-buffer contains YCoCg pixels, the value of this property will be non-NULL
 and should be bound to the context prior to drawing the texture.
 */
@property (readonly) GLhandleARB shaderProgramObject;

// @property (readonly) GLenum textureTarget; // is always GL_TEXTURE_2D

// @property (readonly) BOOL textureIsFlipped; // is always YES

@end
