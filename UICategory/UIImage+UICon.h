//
//  UIImage+UICon.h
//  Common
//
//  Created by 周杨 on 14/12/22.
//  Copyright (c) 2014年 zhouy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UICon)
/**
 *  根据文件路径获取UIImage
 *
 *  @param path 文件路径
 *
 *  @return UIImage 实例
 */
+(UIImage *) ForPath:(NSString *) path;

/**
 *  根据文件路径及设置图片大小 得到UIImage
 *
 *  @param path     文件路径
 *  @param newSieze 尺寸大小
 *
 *  @return UIImage 实例
 */
+(UIImage *) ForPath:(NSString *)path size:(CGSize)newSieze;

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
+(UIImage *) ForPath:(NSString *)path atX:(float) x andAtY:(float) y andWidth:(float) width andHeight:(float) height;



/**
 *  根据颜色转换为UIImage对象
 *
 *  @param color 颜色
 *
 *  @return UIImage 实例
 */
+ (UIImage *) createImageWithColor: (UIColor *) color;

/**
 *  裁剪为圆形图片
 *
 *  @param image  UIImage实例
 *
 *  @return 裁剪后的图片
 */
+(UIImage*) circleImage:(UIImage*) image;

/**
 *  裁剪为圆角图片
 *
 *  @param image  需裁剪的uiimage
 *  @param size   最终图片的大小
 *  @param radius 圆角大小
 *
 *  @return 裁剪后的图片
 */
+ (UIImage *)roundedRectImage:(UIImage *)image imgSize:(CGSize) size roundRadius:(CGFloat)radius;


@end
