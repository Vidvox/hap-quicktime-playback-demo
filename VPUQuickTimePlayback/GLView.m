
#import "GLView.h"
#import <OpenGL/CGLMacro.h>
#import "VVSizingTool.h"




@implementation GLView

- (void) drawRect:(NSRect)r	{
    [self drawTexture:0 sized:NSMakeSize(0, 0) flipped:NO];
}

- (void) drawTexture:(GLuint)t sized:(NSSize)s flipped:(BOOL)f	{
    [self drawTexture:t target:GL_TEXTURE_RECTANGLE_ARB imageSize:s textureSize:s flipped:f usingShader:NULL];
}

- (void)reshape
{
	needsReshape = YES;
}

- (void) drawTexture:(GLuint)tx target:(GLenum)tg imageSize:(NSSize)is textureSize:(NSSize)ts flipped:(BOOL)f usingShader:(GLhandleARB)shader
{
	//NSLog(@"%s",__func__);
    CGLContextObj		cgl_ctx = [[self openGLContext] CGLContextObj];
    
    NSRect bounds = self.bounds;
    
    if (needsReshape)
    {
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_BLEND);
        glHint(GL_CLIP_VOLUME_CLIPPING_HINT_EXT, GL_FASTEST);
        
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glViewport(0, 0, (GLsizei) bounds.size.width, (GLsizei) bounds.size.height);
        glOrtho(bounds.origin.x, bounds.origin.x+bounds.size.width, bounds.origin.y, bounds.origin.y+bounds.size.height, -1.0, 1.0);
        
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
        
        needsReshape = NO;
    }
    if (!NSEqualSizes(is, bounds.size))
    {
        //	clear the view if the texture won't fill it
        glClearColor(0.0,0.0,0.0,0.0);
        glClear(GL_COLOR_BUFFER_BIT);
    }
    if (tx != 0 && !NSEqualSizes(is, NSZeroSize) && !NSEqualSizes(ts, NSZeroSize))
    {
        glEnable(tg);
        
        NSRect	destRect = [VVSizingTool
                            rectThatFitsRect:NSMakeRect(0,0,is.width,is.height)
                            inRect:bounds
                            sizingMode:VVSizingModeFit];
        
        GLfloat vertices[] = {
            destRect.origin.x,                          destRect.origin.y,
            destRect.origin.x+destRect.size.width,      destRect.origin.y,
            destRect.origin.x + destRect.size.width,    destRect.origin.y + destRect.size.height,
            destRect.origin.x,                          destRect.origin.y + destRect.size.height,
        };
        
        GLfloat			texCoords[] = {
            0.0,        (f ? is.height : 0.0),
            is.width,   (f ? is.height : 0.0),
            is.width,   (f ? 0.0 : is.height),
            0.0,        (f ? 0.0 : is.height)
        };
        
        if (tg == GL_TEXTURE_2D)
        {
            texCoords[1] /= (float)ts.height;
            texCoords[3] /= (float)ts.height;
            texCoords[5] /= (float)ts.height;
            texCoords[7] /= (float)ts.height;
            texCoords[2] /= (float)ts.width;
            texCoords[4] /= (float)ts.width;
        }
        
        glBindTexture(tg,tx);
        
        glVertexPointer(2,GL_FLOAT,0,vertices);
        glTexCoordPointer(2,GL_FLOAT,0,texCoords);
        
        if (shader != NULL)
        {
            glUseProgramObjectARB(shader);
        }
        glDrawArrays(GL_QUADS,0,4);
        
        if (shader != NULL)
        {
            glUseProgramObjectARB(NULL);
        }
        glBindTexture(tg,0);
        
        glDisable(tg);
    }
    //	flush!
    glFlush();
}

@end
