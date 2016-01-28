//
//  UILabel+UICon.m
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/5.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "UILabel+UICon.h"

@implementation UILabel (UICon)

/**
 *  设置圆形图标样式
 *
 *  @param backColor 背景颜色
 *  @param fontColor 字体颜色
 */
-(void) setCircleIconStyle:(UIColor*) backColor andFontColor:(UIColor*) fontColor{


    self.textAlignment = NSTextAlignmentCenter;
    
//    
//    font1.font = [NSString getFromAwesomeSize:18];
//    font1.text = [NSString stringFromAwesomeIcon:FAIconArrowUp];
    //font1.backgroundColor=[UIColor redColor];
    [self.layer setCornerRadius:self.bounds.size.width/2];
    self.layer.backgroundColor=backColor.CGColor;
    self.textColor = fontColor;
}
@end
