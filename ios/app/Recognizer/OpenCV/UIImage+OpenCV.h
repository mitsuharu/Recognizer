//
//  UIImage+OpenCV.h
//  SampleFaceEditor
//
//  Created by Mitsuharu Emoto on 2015/07/09.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^OCVDetectedObjectCompletion)(NSArray<NSValue *> *rectangles,
                                            NSError *error);

typedef NS_ENUM(NSInteger, OCVDetectedObject) {
    OCVDetectedObjectFace,
    OCVDetectedObjectEye,
    OCVDetectedObjectNose,
    OCVDetectedObjectMouth,
};





@interface UIImage (OpenCV)

-(UIImage*)maskSkinImage:(CGRect)faceRect;
- (void)skinHsv:(CGRect)faceRect h:(int*)h s:(int*)s v:(int*)v;

-(UIImage*)maskSkinImageAroundEye:(CGRect)eye1Rect eye2:(CGRect)eye2Rect;


-(UIImage*)maskImage:(CGRect)rect;
-(UIImage*)croppedImage:(CGRect)rect;

-(UIImage*)gray;
-(UIImage*)smoothedImage;

-(UIImage*)drawRectangle:(NSArray*)rects;
-(UIImage*)drawCircle:(NSArray*)rects;

-(void)detectFaces:(OCVDetectedObjectCompletion)completion;

-(void)detectObjects:(OCVDetectedObject)detectedObject
          completion:(OCVDetectedObjectCompletion)completion;

@end
