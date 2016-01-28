//
//  CircleBtn.h
//  CommonLibrary
//
//  圆形图标按钮仿百度按钮
//
//  Created by 周杨 on 15/2/1.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComLable.h"
#import "ComButton.h"
#import "NSString+FontAwesome.h"

@interface CircleBtn : UIButton


/**
 *  显示字段值
 */
@property (nonatomic,weak) UILabel * titTxt;

/**
 *  显示字段值
 */
@property (nonatomic,weak) ComButton * iconLb;

/**
 *  根据属性创建实例
 *
 *  @param icon      <#icon description#>
 *  @param tit       <#tit description#>
 *  @param colorStr  <#colorStr description#>
 *  @param lColorStr <#lColorStr description#>
 *  @param action    <#action description#>
 */
-(void) buildIcon:(FAIcon )icon titTxt:(NSString *) tit forColor:(NSString *) colorStr andLColor:(NSString *) lColorStr action:(ActionBlock)action;
@end
