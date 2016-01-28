//
//  UIView+FramePostion.h
//  CommonLibrary
//
//  Created by 周杨 on 15/3/12.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 布局方式
 */
typedef enum
{
    LeftFloat,    //默认
    RightFloat,
    TopFloat,
    BottomFloat
} FloatPostion;

@interface UIView (FramePostion)


/**
 *  设置视图控件的垂直偏移
 *
 *  @param prevUI 相对于上一控件
 *  @param x      X轴偏移量
 *  @param y      Y轴偏移量
 */
-(void) setVerticalPostion:(UIView *) prevUI forX:(double) x andY:(double) y;


/**
 *  设置视图控件的水平偏移
 *
 *  @param prevUI 相对于上一控件
 *  @param x      X轴偏移量
 *  @param y      Y轴偏移量
 */
-(void) setHorizontalPostion:(UIView *) prevUI forX:(double) x andY:(double) y;

/**
 *  设置视图控件居中
 */
-(void) setMediation;

/**
 *  设置布局方式
 *
 *  @param floatPostion 布局方式【居左、居右、居上、居下】
 *  @param x            偏移值
 */
-(void) setFloatPostion:(FloatPostion) floatPostion andX:(double) x;

/**
 *  设置布局方式
 *
 *  @param floatPostion 布局方式【居左、居右、居上、居下】
 *  @param view         UIView
 *  @param x            偏移值
 */
-(void) setFloatPostion:(FloatPostion) floatPostion forView:(UIView *) view andX:(double) x;

@end
