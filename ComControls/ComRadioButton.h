//
//  ComRadioButton.h
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/19.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

@interface ComRadioButton : UILabel<UIGestureRecognizerDelegate>

/**
 * 定义闭包
 */
typedef void (^ActionBlock)(void);
@property (nonatomic, copy) ActionBlock actionBlock;

/**
 *  是否选择
 */
@property (nonatomic) BOOL isSelected;

/**
 *  颜色
 */
@property (nonatomic) UIColor * fontColor;

/**
 *  设置FAIcon图标
 *
 *  @param faicon
 *  @param size
 */
-(void) setIconLable:(FAIcon)faicon size:(int) size;

/**
 *  改变选中状态样式
 *
 *  @param selectedVal <#selectedVal description#>
 */
-(void) changeSelected:(BOOL) selectedVal;

/**
 *  点击事件
 *
 *  @param actionBlock 事件闭包
 */
-(void) onClick:(ActionBlock)actionBlock;

@end
