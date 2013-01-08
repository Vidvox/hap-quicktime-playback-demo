
#import <Cocoa/Cocoa.h>




@interface GLView : NSOpenGLView {
    BOOL                needsReshape;
}
- (void) drawTexture:(GLuint)tx target:(GLenum)tg imageSize:(NSSize)is textureSize:(NSSize)ts flipped:(BOOL)f usingShader:(GLhandleARB)shader;
- (void) drawTexture:(GLuint)t sized:(NSSize)s flipped:(BOOL)f;

@end
