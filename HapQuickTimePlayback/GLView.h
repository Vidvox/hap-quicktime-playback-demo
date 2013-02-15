
#import <Cocoa/Cocoa.h>


/*
 A very simple thread-safe OpenGL view
 */

@interface GLView : NSOpenGLView {
    BOOL                needsReshape;
}
- (void) drawTexture:(GLuint)texture target:(GLenum)target imageSize:(NSSize)imageSize textureSize:(NSSize)textureSize flipped:(BOOL)isFlipped usingShader:(GLhandleARB)shader;
- (void) drawTexture:(GLuint)t sized:(NSSize)s flipped:(BOOL)f;

@end
