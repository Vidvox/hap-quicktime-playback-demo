Hap QuickTime Playback Demo
===========================

A demonstration of GPU-accelerated playback of Hap movies using the QuickTime codec.

Hap is a video codec for fast decompression on modern graphics hardware. For general information about Hap, see [the Hap project](http://github.com/vidvox/hap).

Accelerated Playback
====================

Accelerated playback of Hap involves passing S3TC frames to graphics hardware using OpenGL. The Hap codec will emit S3TC frames when an application indicates it can handle them. This is done using the usual QuickTime playback mechanisms and if you are already using QuickTime the code overhead to support Hap is fairly low.

The [Hap QuickTime codec](https://github.com/vidvox/hap-qt-codec) must be installed.

The steps are

1. Open a movie and examine its video track to confirm it is Hap
2. Create a QTPixelBufferContext for playback using a list of custom pixel-format type constants
3. Play the movie
4. When you receive a frame, perform compressed texture upload using OpenGL
5. If the movie is encoded with Hap Q, use a shader when you draw the texture

This example includes reusable code to aid the process. Steps 1. and 2. utilise

    HapSupport.h
    HapSupport.c

Steps 4. and 5. utilise

    HapPixelBufferTexture.h
    HapPixelBufferTexture.m
    ScaledCoCgYToRGBA.vert
    ScaledCoCgYToRGBA.frag

Further Reading
===============

- [Core Video Programming Guide](https://developer.apple.com/library/mac/#documentation/graphicsimaging/conceptual/CoreVideo/CVProg_Intro/CVProg_Intro.html)
- [GL Texture Compression](http://www.opengl.org/registry/specs/ARB/texture_compression.txt)
- [GL S3 Texture Compression](http://www.opengl.org/registry/specs/EXT/texture_compression_s3tc.txt)

Open-Source
===========

This code is open-source, licensed under a [Free BSD License](http://github.com/vidvox/hap-quicktime-playback-demo/blob/master/LICENSE), meaning you can use it in your commercial or non-commercial applications free of charge.

This project was originally written by [Tom Butterworth](http://kriss.cx/tom) and commissioned by [VIDVOX](http://www.vidvox.net), 2012.
