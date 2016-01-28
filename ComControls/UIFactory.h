//
//  UIFactory.h
//  Common
//
//  Created by 周杨 on 15/1/5.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ComTextFiled.h"
#import "ComButton.h"
#import "UIImage+UICon.h"
#import "UIColor+UICon.h"
#import "NSString+FontAwesome.h"
#import "UIImage+UICon.h"
#import "ComLable.h"
#import "UIView+FramePostion.h"
#import "UIImageView+UICon.h"
#import "ComRadioButton.h"
#import "ComTextFieldEvent.h"

static NSString *const color = @"#18b4ed";             //定义普通颜色常量
static NSString *const colorLight = @"#27c2fa";        //定义高亮颜色常量

@interface UIFactory : NSObject

/**
 *  根据标题，创建封装按钮控件
 *
 *  @param title 标题名称
 *
 *  @return 封装按钮实例
 */
+(ComButton *) CreateUIButton:(NSString *) title;

/**
 *  根据标题，创建页面底部的封装按钮
 *
 *  @param title title 标题名称
 *
 *  @return 封装按钮实例
 */
+(ComButton *) CreateBottomUIButton:(NSString *) title;


@end
