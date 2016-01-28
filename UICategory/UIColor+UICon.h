//
//  UIColor+UICon.h
//  Common
//
//  Created by 周杨 on 14/12/22.
//  Copyright (c) 2014年 zhouy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UICon)
/**
 *  通过16进制转换为UIColor对象
 *
 *  @param str 16进制图像字串
 *
 *  @return UIColor实例
 */
+(UIColor *) HexString:(NSString *) str;

/**
 *  通过16进制转换为UIColor对象  并设置透明度
 *
 *  @param str   16进制图像字串
 *  @param alpha 透明度
 *
 *  @return UIColor实例
 */
+(UIColor *) HexString:(NSString *) str andAlpha:(float) alpha;
@end
