//
//  ComTextFiled.h
//
//  封装文本的控件
//
//  Created by 周杨 on 15/1/8.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import "UIImage+UICon.h"
#import "UIColor+UICon.h"
#import "NSString+FontAwesome.h"
#import "ComControls.h"

@interface ComTextFiled : UITextField



/**
 *  前置图标Lable
 */
@property (nonatomic,weak) UILabel * pIconLable;

/**
 *  当前的颜色样式
 */
@property (nonatomic)ColorStyle textFiledColorStyle;

/**
 *  改变之前的颜色样式
 */
@property (nonatomic)ColorStyle oldTextFiledColorStyle;


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
-(instancetype) initForColorStyle:(ColorStyle) colorStyle;


/**
 *  设置文本控件颜色样式
 *
 *  @param colorStyle 颜色枚举
 */
-(void) setColorStyle:(ColorStyle) colorStyle;

/**
 *  黑色样式
 */
-(void) blackColorStyle;

/**
 *  灰色样式
 */
-(void) grayColorStyle;

/**
 *  白色样式
 */
-(void) whiteColorStyle;

/**
 *  绿色样式
 */
-(void) greenColorStyle;

/**
 *  透明样式
 */
-(void) clearColorStyle;

/**
 *  设置TextFieldIcon图标
 *
 *  @param faicon
 *  @param size
 */
-(void) setIconLable:(FAIcon)faicon size:(int) size;

/**
 *  设置清空按钮颜色
 *
 *  @param hex 颜色字符
 */
-(void) setClearIconColor:(UIColor *) color;

/**
 *  邮箱验证 MODIFIED BY HELENSONG
 *
 *  @param email
 *
 *  @return
 */
-(BOOL)isValidateEmail;

/**
 *  手机号码验证 MODIFIED BY HELENSONG
 *
 *  @param mobile
 *
 *  @return
 */
-(BOOL) isValidateMobile;
@end
