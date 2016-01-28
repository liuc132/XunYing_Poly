//
//  UIImage+UICon.m
//  Common
//
//  Created by 周杨 on 14/12/22.
//  Copyright (c) 2014年 zhouy. All rights reserved.
//

#import "UIImage+UICon.h"

@implementation UIImage (UICon)

/**
 *  根据文件路径获取UIImage
 *
 *  @param path 文件路径
 *
 *  @return UIImage 实例
 */
+(UIImage *) ForPath:(NSString *) path{
    
    NSString *toParh = [[NSBundle mainBundle] pathForResource:path ofType:nil inDirectory:@""];
    UIImage *img = [[[UIImage alloc] initWithContentsOfFile:toParh] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return img;
}



/**
 *  根据文件路径及设置图片大小 得到UIImage
 *
 *  @param path     文件路径
 *  @param newSieze 尺寸大小
 *
 *  @return UIImage 实例
 */
+(UIImage *) ForPath:(NSString *)path size:(CGSize)newSieze{
    NSString *toParh = [[NSBundle mainBundle] pathForResource:path ofType:nil inDirectory:@""];
    UIImage *img = [[[UIImage alloc] initWithContentsOfFile:toParh] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(newSieze);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, newSieze.width, newSieze.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
    
}




/**
 *  根据文件路径及图片的坐标 得到UIImage
 *  用与整张PNG 获取里面的一块图片
 *
 *  @param path   文件路径
 *  @param x      X坐标
 *  @param y      Y坐标
 *  @param width  宽度
 *  @param height 高度
 *
 *  @return UIImage 实例
 */
+(UIImage *) ForPath:(NSString *)path atX:(float) x andAtY:(float) y andWidth:(float) width andHeight:(float) height{
    
    NSString *toParh = [[NSBundle mainBundle] pathForResource:path ofType:nil inDirectory:@""];
    UIImage *img = [[[UIImage alloc] initWithContentsOfFile:toParh] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    CGRect myImageRect = CGRectMake(x, y, width, height);
    
    CGImageRef imageRef = img.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIGraphicsEndImageContext();
    
    //内存泄漏
    __block UIImage* smallImage =nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImage * tempImg = [UIImage imageWithCGImage:subImageRef];
        
        smallImage=tempImg;
    });
    //
    return smallImage;
}

/**
 *  根据颜色转换为UIImage对象
 *
 *  @param color 颜色
 *
 *  @return UIImage 实例
 */
+ (UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


/**
 *  裁剪为圆形图片
 *
 *  @param image  UIImage实例
 *
 *  @return 裁剪后的图片
 */
+(UIImage*) circleImage:(UIImage*) image  {
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGRect rect = CGRectMake(0, 0, image.size.width , image.size.height);
    
    //图片偏移
    //CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}


static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

/**
 *  裁剪为圆角图片
 *
 *  @param image  需裁剪的uiimage
 *  @param size   最终图片的大小
 *  @param radius 圆角大小
 *
 *  @return 裁剪后的图片
 */
+ (UIImage *)roundedRectImage:(UIImage *)image imgSize:(CGSize) size roundRadius:(CGFloat)radius {
    if (!radius)
        radius = 8;
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
    __block UIImage *retImage;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *img = image;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
        CGRect rect = CGRectMake(0, 0, w, h);
        
        CGContextBeginPath(context);
        addRoundedRectToPath(context, rect, radius, radius);
        CGContextClosePath(context);
        CGContextClip(context);
        CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
        CGImageRef imageMasked = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        dispatch_async(dispatch_get_main_queue(), ^{
            retImage = [UIImage imageWithCGImage:imageMasked];
        });
        
    });
    
    
    return retImage;
}



@end
