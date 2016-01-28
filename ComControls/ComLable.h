//
//  ComLable.h
//  Common
//
//  Created by 周杨 on 15/1/11.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSString+FontAwesome.h"

@interface ComLable : UILabel<UIGestureRecognizerDelegate>


/**
 * 定义闭包
 */
typedef void (^ActionBlock)(void);
@property (nonatomic, copy) ActionBlock actionBlock;

/**
 *  设置 圆角边框
 */
-(void) borderRadiusStyle;

/**
 *  设置 圆形边框
 */
-(void) borderCircleStyle;

/**
 *  设置 无边框
 */
-(void) borderNoneStyle;

/**
 *  设置为 黑色样式
 */
-(void) blackColorStyle;

/**
 *  设置为 灰色样式
 */
-(void) grayColorStyle;

/**
 *  设置为 白色样式
 */
-(void) whiteColorStyle;

/**
 *  设置FAIcon图标
 *
 *  @param faicon
 *  @param size
 */
-(void) setIconLable:(FAIcon)faicon size:(int) size;

/**
 *  点击事件
 *
 *  @param actionBlock 事件闭包
 */
-(void) onClick:(ActionBlock)actionBlock;

@end
