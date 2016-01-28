//
//  ComButton.h
//
//  封装按钮的控件
//  基于FontAwesome字体文件
//
//  Created by 周杨 on 15/1/5.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+UICon.h"
#import "UIColor+UICon.h"
#import "NSString+FontAwesome.h"


@interface ComButton : UIButton

/**
 *  图标Lable
 */
@property (nonatomic,weak) UILabel * iconLable;

/**
 * 颜色的样式
 */
typedef enum
{
    blueColor,    //默认
    pinkColor,
    greenColor,
    grayColor,
    orangeColor
} ComButtonColorStyle ;
//typedef enum ColorStyle ColorStyle;


/**
 * 定义闭包
 */
typedef void (^ActionBlock)(void);
@property (nonatomic, copy) ActionBlock actionBlock;

/**
 *  重写加载方法
 *
 *  @return 对象实例
 */
-(instancetype) init;

/**
 *  根据颜色样式加载按钮
 *
 *  @param colorStyle 颜色的样式
 *
 *  @return 对象实例
 */
-(instancetype) initForColorStyle:(ComButtonColorStyle) colorStyle;


/**
 *  设置按钮样式
 *
 *  @param colorStyle 颜色枚举
 */
-(void) setColorStyle:(ComButtonColorStyle) colorStyle;

/**
 *  蓝色按钮样式
 */
-(void) blueColorStyle;

/**
 *  粉色按钮样式
 */
-(void) pinkColorStyle;

/**
 *  绿色按钮样式
 */
-(void) greenColorStyle;

/**
 *  灰色按钮样式
 */
-(void) grayColorStyle;

/**
 *  橙色按钮样式
 */
-(void) orangeColorStyle;

/**
 *  设置ButtonIcon图标
 *
 *  @param faicon
 *  @param size
 */
-(void) setIconLable:(FAIcon)faicon size:(int) size;

/**
 *  通过闭包的方式触发按钮事件
 *
 *  @param action        函数闭包
 *  @param controlEvents 事件类型
 */
-(void)action:(ActionBlock)action forControlEvents:(UIControlEvents)controlEvents;

/**
 *  根据颜色构造样式
 *
 *  @param color      默认颜色
 *  @param lightColor 高亮颜色
 */
-(void) colorStyleFor:(NSString *) color andColorLight:(NSString *) lightColor;


/**
 *  设置按钮的颜色状态
 *
 *  @param color      默认颜色
 *  @param lightColor 高亮颜色
 */
-(void) changeColor:(NSString *) color andColorLight:(NSString *) lightColor;
@end
