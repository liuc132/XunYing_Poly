//
//  ComImageView.h
//  Common
//
//  Created by 周杨 on 15/1/9.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+UICon.h"
#import "ComControls.h"
#import "NSString+FontAwesome.h"

@interface ComImageView : UIImageView<UIGestureRecognizerDelegate>


/**
 * 定义闭包
 */
typedef void (^ActionBlock)(void);
@property (nonatomic, copy) ActionBlock actionBlock;

/**
 *  设置 圆角边框
 */
-(void) imageViewBorderRadiusStyle;

/**
 *  设置 圆形边框
 */
-(void) imageViewBorderCircleStyle;

/**
 *  设置 无边框
 */
-(void) imageViewBorderNoneStyle;

/**
 *  设置为 黑色样式
 */
-(void) blackImageViewColorStyle;

/**
 *  设置为 灰色样式
 */
-(void) grayImageViewColorStyle;

/**
 *  设置为 白色样式
 */
-(void) whiteImageViewColorStyle;

/**
 *  设置  图形圆角幅度
 *
 *  @param val 幅度值
 */
-(void) setBorderRadius:(double) val;

/**
 *  异步加载网络路径图片
 *
 *  @param url   URL地址
 *  @param frame 大小
 *
 *  @return ImageView实例
 */
-(instancetype) initForNSUrl:(NSString *)url andFrame:(CGRect)frame;

/**
 *  设置为圆形样式
 */
-(void) setCircleStyle;

/**
 *  设置boder样式
 */
-(void) setBoderStyle:(NSString *) hexColor;

/**
 *  点击事件
 *
 *  @param actionBlock 事件闭包
 */
-(void) onClick:(ActionBlock)actionBlock;

@end
