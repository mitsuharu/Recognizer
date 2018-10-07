//
//  UIImage+OpenCV.m
//  SampleFaceEditor
//
//  Created by Mitsuharu Emoto on 2015/07/09.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/highgui.hpp>

#import "UIImage+OpenCV.h"




@interface UIImage (OpenCV_private)


-(NSString*)haarcascade:(OCVDetectedObject)detectedObject;
-(float)minScale:(OCVDetectedObject)detectedObject;
-(float)maxScale:(OCVDetectedObject)detectedObject;


+(UIImage *)imageFromCVMat:(cv::Mat)cvMat;
-(cv::Mat)cvMat;


@end

@implementation UIImage (OpenCV_private)

//-(IplImage *)iplImage
//{
//    CGImageRef imageRef = self.CGImage;
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    IplImage *iplimage = cvCreateImage(cvSize(self.size.width, self.size.height), IPL_DEPTH_8U, 4);
//    
//    // IplImageからCGBitmapContextを作成
//    CGContextRef contextRef = CGBitmapContextCreate(
//                                                    iplimage->imageData,
//                                                    iplimage->width,
//                                                    iplimage->height,
//                                                    iplimage->depth,
//                                                    iplimage->widthStep,
//                                                    colorSpace,
//                                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
//    
//    // CGBitmapContextに描画
//    CGContextDrawImage(contextRef, CGRectMake(0, 0, self.size.width, self.size.height), imageRef);
//    
//    CGContextRelease(contextRef);
//    CGColorSpaceRelease(colorSpace);
//    
//    // 出力するIplImageを作成
//    // OpenCVではデフォルトの色配列がBGRになっているので合わせます
//    IplImage *outputImage = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
//    cvCvtColor(iplimage, outputImage, CV_RGBA2BGR);
//    
//    // 解放を忘れない
//    cvReleaseImage(&iplimage);
//    
//    return outputImage;
//}
//
//+ (UIImage *)imageFromIplImage:(IplImage *)inputImage
//{
//    CGColorSpaceRef colorSpace;
//    if (inputImage->nChannels == 1) {
//        colorSpace = CGColorSpaceCreateDeviceGray();
//    }
//    else {
//        colorSpace = CGColorSpaceCreateDeviceRGB();
//        
//        // 先ほどの逆ですが、OpenCVの色配列はBGRになっているのでRGBに変換
//        cvCvtColor(inputImage, inputImage, CV_BGR2RGB);
//    }
//    
//    // IplImageからNSDataを作成
//    NSData *data = [NSData dataWithBytes:inputImage->imageData length:inputImage->imageSize];
//    
//    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
//    
//    // CGImageを作成
//    CGImageRef imageRef = CGImageCreate(inputImage->width,
//                                        inputImage->height,
//                                        inputImage->depth,
//                                        inputImage->depth * inputImage->nChannels,
//                                        inputImage->widthStep,
//                                        colorSpace,
//                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,
//                                        provider,
//                                        NULL,
//                                        false,
//                                        kCGRenderingIntentDefault
//                                        );
//    
//    // UIImageをimageRefから作成
//    UIImage *outputImage = [UIImage imageWithCGImage:imageRef];
//    
//    // しつこいようですが解放を忘れない
//    CGImageRelease(imageRef);
//    CGDataProviderRelease(provider);
//    CGColorSpaceRelease(colorSpace);
//    
//    return outputImage;
//}

-(cv::Mat)cvMat
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    cvMat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast
                                                    | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
//    CGColorSpaceRelease(colorSpace); // retainしてないので不要
    
    return cvMat;
}

+(UIImage *)imageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data
                                  length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // CFDataRefをリリースするとクラッシュする
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

-(NSString*)haarcascade:(OCVDetectedObject)detectedObject
{
    NSString *str = @"haarcascade_frontalface_default";
    if (detectedObject == OCVDetectedObjectEye) {
        str = @"haarcascade_eye";
    }else if (detectedObject == OCVDetectedObjectNose){
        str = @"haarcascade_mcs_nose";
    }else if (detectedObject == OCVDetectedObjectMouth){
        str = @"haarcascade_mcs_mouth";
    }
    return str;
}

-(float)minScale:(OCVDetectedObject)detectedObject
{
    float scale = 0.2;
    if (detectedObject == OCVDetectedObjectEye) {
        scale = 0.3;
    }else if (detectedObject == OCVDetectedObjectNose){
        scale = 0.3;
    }else if (detectedObject == OCVDetectedObjectMouth){
        scale = 0.2; //0.3;
    }
    return scale;
}

-(float)maxScale:(OCVDetectedObject)detectedObject
{
    float scale = 0.8;
    if (detectedObject == OCVDetectedObjectEye) {
        scale = 0.8;// 0.6;
    }else if (detectedObject == OCVDetectedObjectNose){
        scale = 0.6;
    }else if (detectedObject == OCVDetectedObjectMouth){
        scale = 0.8;
    }
    return scale;
}


@end


@implementation UIImage (OpenCV)

-(UIImage*)maskImage:(CGRect)rect
{
    UIImage *mask = nil;
    
    UIGraphicsBeginImageContextWithOptions(self.size, false, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGRect rect0 = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, rect0);
    
    // 縦長に補正
    float xscale = 0.9;
    float yscale = 1.2;
    CGRect rect1 = CGRectMake(rect.origin.x - (rect.size.width)*(xscale-1.0)/2.0,
                              rect.origin.y - (rect.size.height)*(yscale-1.0)/2.0,
                              rect.size.width*xscale,
                              rect.size.height*yscale);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextFillRect(context, rect);
    
    CGContextFillEllipseInRect(context, rect1);
    
    mask = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return mask;
}


-(UIImage*)smoothedImage
{
    cv::Mat cvImage = [self cvMat];
    cv::Mat smoothCvImage;
    cv::medianBlur(cvImage, smoothCvImage, 7);
    
    UIImage *image = [UIImage imageFromCVMat:smoothCvImage];
    cvImage.release();
    smoothCvImage.release();
    
    return image;
}


-(UIImage*)maskSkinImageAroundEye:(CGRect)eyeRect1 eye2:(CGRect)eyeRect2
{
    cv::Mat cvImage = [self cvMat];
    
    cv::Mat hsvImage;
    cvtColor(cvImage, hsvImage, CV_BGR2HSV);
    
    cv::Mat d1_img, e1_img;
    cv::dilate(cvImage, d1_img, cv::Mat(), cv::Point(-1,-1), 1);
    cv::erode(d1_img, e1_img, cv::Mat(), cv::Point(-1,-1), 1);
    
    cv::Mat smoothCvImage;
    cv::medianBlur(cvImage, smoothCvImage, 7);	//ノイズがあるので平滑化

    cv::Mat smoothHsvImage;
    cv::cvtColor(smoothCvImage, smoothHsvImage, CV_BGR2HSV);
    
    // 確実に肌色
    int base1_h = 0;
    int base1_s = 0;
    int base1_v = 0;
    int count1 = 0;
    for(int y = (int)(eyeRect1.origin.y+eyeRect1.size.height-2); y < (int)(eyeRect1.origin.y+eyeRect1.size.height); y++){
        for(int x = (int)(eyeRect1.origin.x); x < (int)(eyeRect1.origin.x+eyeRect1.size.width); x++){
            int a = (int)(smoothHsvImage.step*y+(x*3));
            base1_h += smoothHsvImage.data[a];
            base1_s += smoothHsvImage.data[a+1];
            base1_v += smoothHsvImage.data[a+2];
            count1 += 1;
        }
    }
    if (count1!=0) {
        base1_h /= count1;
        base1_s /= count1;
        base1_v /= count1;        
    }
    
    int base2_h = 0;
    int base2_s = 0;
    int base2_v = 0;
    int count2 = 0;
    for(int y = (int)(eyeRect2.origin.y+eyeRect2.size.height-2); y < (int)(eyeRect2.origin.y+eyeRect2.size.height); y++){
        for(int x = (int)(eyeRect2.origin.x); x < (int)(eyeRect2.origin.x+eyeRect2.size.width); x++){
            int a = (int)(smoothHsvImage.step*y+(x*3));
            base2_h += smoothHsvImage.data[a];
            base2_s += smoothHsvImage.data[a+1];
            base2_v += smoothHsvImage.data[a+2];
            count2 += 1;
        }
    }
    if (count2!=0){
        base2_h /= count2;
        base2_s /= count2;
        base2_v /= count2;
    }
    
    for(int y = 0; y < self.size.height; y++){
        for(int x = 0; x < self.size.width; x++){
            int a = (int)(smoothHsvImage.step*y+(x*3));
            int h = 0;
            int s = 0;
            int v = 0;
            float scale = 0.0;
            int threshold = 50;
            if ((eyeRect1.origin.y + eyeRect1.size.height*scale <= y
                && y < eyeRect1.origin.y + eyeRect1.size.height
                && eyeRect1.origin.x <= x
                && x < eyeRect1.origin.x + eyeRect1.size.width)) {
                
                int def_h = pow((smoothHsvImage.data[a] - base1_h ), 2);
                int def_s = pow((smoothHsvImage.data[a+1] - base1_s ), 2);
                int def_v = pow((smoothHsvImage.data[a+2] - base1_v ), 2);
                int def = sqrt((def_h + def_s + def_v)/3.0);
                
                if (def < threshold) {
                    h = 0;
                    s = 0;
                    v = 255;
                }
            }else if (eyeRect2.origin.y + eyeRect2.size.height*scale <= y
                      && y < eyeRect2.origin.y + eyeRect2.size.height
                      && eyeRect2.origin.x <= x
                      && x < eyeRect2.origin.x + eyeRect2.size.width) {
                
                int def_h = pow((smoothHsvImage.data[a] - base2_h ), 2);
                int def_s = pow((smoothHsvImage.data[a+1] - base2_s ), 2);
                int def_v = pow((smoothHsvImage.data[a+2] - base2_v ), 2);
                int def = sqrt((def_h + def_s + def_v)/3.0);
                
                if (def < threshold) {
                    h = 0;
                    s = 0;
                    v = 255;
                }
            }
            
            hsvImage.data[a] = h;
            hsvImage.data[a+1] = s;
            hsvImage.data[a+2] = v;
        }
    }
    
    // HSVからBGRに変換
    cv::Mat cvImage5;
    cv::cvtColor(hsvImage, cvImage5, CV_HSV2BGR);
    
    UIImage *result = [UIImage imageFromCVMat:cvImage5];
    
    cvImage.release();
    hsvImage.release();
    d1_img.release();
    e1_img.release();
    smoothCvImage.release();;
    smoothHsvImage.release();
    cvImage5.release();
    
    return result;
}



- (void)skinHsv:(CGRect)faceRect h:(int*)h s:(int*)s v:(int*)v
{
    cv::Mat cvImage = [self cvMat];
    
    cv::Mat hsvImage;
    cvtColor(cvImage, hsvImage, CV_BGR2HSV);
    
    cv::Mat smoothCvImage;
    cv::medianBlur(cvImage, smoothCvImage, 7);	//ノイズがあるので平滑化
    
    cv::Mat smoothHsvImage;
    cv::cvtColor(smoothCvImage, smoothHsvImage, CV_BGR2HSV);
    
    // 確実に肌色
    CGPoint center = CGPointMake(faceRect.origin.x + faceRect.size.width/2,
                                 faceRect.origin.y + faceRect.size.height/2);
    int face_h = 0;
    int face_s = 0;
    int face_v = 0;
    float scale = 0.1;
    int count = 0;
    for(int y = (int)(center.y - (faceRect.size.width*scale)); y < (int)(center.y + (faceRect.size.width*scale)); y++){
        for(int x = (int)(center.x - (faceRect.size.height*scale)); x < (int)(center.x + (faceRect.size.height*scale)); x++){
            int a = (int)(smoothHsvImage.step*y+(x*3));
            face_h += smoothHsvImage.data[a];
            face_s += smoothHsvImage.data[a+1];
            face_v += smoothHsvImage.data[a+2];
            count += 1;
        }
    }
    if (count != 0) {
        *h = face_h / count;
        *s = face_s / count;
        *v = face_v / count;
    }
    
    cvImage.release();
    hsvImage.release();
    smoothCvImage.release();
    smoothHsvImage.release();
}

/**
 顔認識後に肌色検出を行う
 */
-(UIImage*)maskSkinImage:(CGRect)faceRect
{
    cv::Mat cvImage = [self cvMat];
    
    cv::Mat hsvImage;
    cvtColor(cvImage, hsvImage, CV_BGR2HSV);
    
    cv::Mat smoothCvImage;
    cv::medianBlur(cvImage, smoothCvImage, 7);	//ノイズがあるので平滑化
    
    cv::Mat smoothHsvImage;
    cv::cvtColor(smoothCvImage, smoothHsvImage, CV_BGR2HSV);
    
    // 確実に肌色
    CGPoint center = CGPointMake(faceRect.origin.x + faceRect.size.width/2,
                                 faceRect.origin.y + faceRect.size.height/2);
    int face_h = 0;
    int face_s = 0;
    int face_v = 0;
    float scale = 0.1;
    int count = 0;
    for(int y = (int)(center.y - (faceRect.size.width*scale)); y < (int)(center.y + (faceRect.size.width*scale)); y++){
        for(int x = (int)(center.x - (faceRect.size.height*scale)); x < (int)(center.x + (faceRect.size.height*scale)); x++){
            int a = (int)(smoothHsvImage.step*y+(x*3));
            face_h += smoothHsvImage.data[a];
            face_s += smoothHsvImage.data[a+1];
            face_v += smoothHsvImage.data[a+2];
            count += 1;
        }
    }
    if (count != 0) {
        face_h /= count;
        face_s /= count;
        face_v /= count;
    }


    for(int y = 0; y < self.size.height; y++){
        for(int x = 0; x < self.size.width; x++){
            int a = (int)(smoothHsvImage.step*y+(x*3));
            int h = 0;
            int s = 0;
            int v = 0;
            
            if (faceRect.origin.y <= y
                && y < faceRect.origin.y + faceRect.size.height
                && faceRect.origin.x <= x
                && x < faceRect.origin.x + faceRect.size.width) {
                
                int def_h = pow((smoothHsvImage.data[a] - face_h ), 2);
                int def_s = pow((smoothHsvImage.data[a+1] - face_s ), 2);
                int def_v = pow((smoothHsvImage.data[a+2] - face_v ), 2);
                int def = sqrt((def_h + def_s + def_v)/3.0);
                
                int threshold = 30;
                if (def < threshold) {
                    h = 0;
                    s = 0;
                    v = 255;
                }
            }
            
            hsvImage.data[a] = h;
            hsvImage.data[a+1] = s;
            hsvImage.data[a+2] = v;
        }
    }
    
    // HSVからBGRに変換
    cv::Mat cvImage5;
    cv::cvtColor(hsvImage, cvImage5, CV_HSV2BGR);

    UIImage *result = [UIImage imageFromCVMat:cvImage5];
    cvImage.release();
    hsvImage.release();
    smoothCvImage.release();
    smoothHsvImage.release();
    cvImage5.release();
    
    return result;
}

-(UIImage*)croppedImage:(CGRect)rect
{
    CGImageRef cgimage = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:cgimage];
    CGImageRelease(cgimage);
    return image;
}


-(void)detectObjects:(OCVDetectedObject)detectedObject
          completion:(OCVDetectedObjectCompletion)completion
{
//    NSLog(@"%s", __FUNCTION__);
    NSTimeInterval interval = CFAbsoluteTimeGetCurrent();
    
    UIImage *image = [self copy];
    
    // 分類器のカスケードを読み込む
    NSString *haarcascade = @"lbpcascade_animeface"; // [self haarcascade:detectedObject];
    NSString *path = [[NSBundle mainBundle] pathForResource:haarcascade ofType:@"xml"];
    std::string cascadeName = (char *)[path UTF8String];
    
    cv::CascadeClassifier cascade;
    if(!cascade.load(cascadeName)) {
        NSLog(@"%s, it cannot loat haarcascede file %@", __FUNCTION__, path);
        return;
    }
 
    
    cv::Mat matImage = [image cvMat];
    cv::Mat grayMat;
    cv::cvtColor(matImage, grayMat, CV_BGR2GRAY);
    
    // 顔検出
    float minScale = [self minScale:detectedObject];
    float maxScale = [self maxScale:detectedObject];
    int baseLength = MIN(image.size.width, image.size.height);
    int minLength = (int)(baseLength*minScale);
    int maxLength = (int)(baseLength*maxScale);
    
    std::vector<cv::Rect> faces;
    cascade.detectMultiScale(grayMat,
                             faces,
                             1.1, 2,
                             CV_HAAR_SCALE_IMAGE,
                             cv::Size(minLength, minLength),
                             cv::Size(maxLength, maxLength));
    matImage.release();
    grayMat.release();
    image = nil;
    
    @autoreleasepool {
        NSMutableArray *rectangles = nil;
        if (faces.size() > 0) {
            rectangles = [[NSMutableArray alloc] initWithCapacity:1];
        }
        
        std::vector<cv::Rect>::const_iterator r = faces.begin();
        for(; r != faces.end(); ++r) {
            CGRect rect = CGRectMake((CGFloat)(r->x),
                                     (CGFloat)(r->y),
                                     (CGFloat)(r->width),
                                     (CGFloat)(r->height));
            NSValue *v = [NSValue valueWithCGRect:rect];
            [rectangles addObject:v];
        }
        
        if (completion) {
            NSError *error = nil;
            completion([rectangles copy], error);
        }
        
        if (rectangles) {
            [rectangles removeAllObjects];
            rectangles = nil;
        }
        
//        interval = CFAbsoluteTimeGetCurrent() - interval;
//        NSLog(@"%s, %f", __FUNCTION__, interval);
    }
}

-(void)detectFaces:(OCVDetectedObjectCompletion)completion
{
    [self detectObjects:OCVDetectedObjectFace
             completion:completion];
}

-(UIImage*)drawRectangle:(NSArray*)rects
{
    cv::Mat matImage = [self cvMat];
    
    for (NSValue *value in rects) {
        CGRect rect = [value CGRectValue];
        
        int width = 4;
        
        cv::rectangle(matImage,
                      cv::Point(rect.origin.x, rect.origin.y),
                      cv::Point(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height),
                      cv::Scalar(80,80,255),
                      width,
                      4);
    }
    

    UIImage *result = [UIImage imageFromCVMat:matImage];
    matImage.release();
    
    return result;
}

-(UIImage*)drawCircle:(NSArray*)rects
{
    cv::Mat matImage = [self cvMat];

    for (NSValue *value in rects) {
        CGRect rect = [value CGRectValue];

        cv::Point center;
        int radius;
        center.x = cv::saturate_cast<int>((rect.origin.x + rect.size.width*0.5));
        center.y = cv::saturate_cast<int>((rect.origin.y + rect.size.height*0.5));
        radius = cv::saturate_cast<int>((rect.size.width + rect.size.height)/4.0);
        cv::circle(matImage, center, radius, cv::Scalar(80,80,255), 3, 8, 0 );

    }
    
    UIImage *result = [UIImage imageFromCVMat:matImage];
    matImage.release();
    
    return result;
}


-(UIImage*)gray
{
    cv::Mat srcMat = [self cvMat];
    cv::Mat grayMat;
    cv::cvtColor(srcMat, grayMat, CV_BGR2GRAY);
    
    
    UIImage *result = [UIImage imageFromCVMat:grayMat];
    srcMat.release();
    grayMat.release();
    
    return result;
}


@end
