
#import <Cocoa/Cocoa.h>




typedef enum	{
	VVSizingModeFit = 0,
	VVSizingModeFill = 1,
	VVSizingModeStretch = 2,
	VVSizingModeCopy = 3
} VVSizingMode;




@interface VVSizingTool : NSObject {

}

+ (NSAffineTransform *) transformThatFitsRect:(NSRect)a inRect:(NSRect)b sizingMode:(VVSizingMode)m;
+ (NSAffineTransform *) inverseTransformThatFitsRect:(NSRect)a inRect:(NSRect)b sizingMode:(VVSizingMode)m;
+ (NSRect) rectThatFitsRect:(NSRect)a inRect:(NSRect)b sizingMode:(VVSizingMode)m;

@end
