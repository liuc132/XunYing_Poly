//
//  CircleBtn.m
//  CommonLibrary
//
//  Created by 周杨 on 15/2/1.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "CircleBtn.h"
#import "NSString+FontAwesome.h"
#import "UIColor+UICon.h"
#import "UIImage+UICon.h"

@implementation CircleBtn{
}



/**
 *  构造图标按钮
 *
 *  @param icon      图标
 *  @param colorStr  颜色
 *  @param lColorStr 点击变化的颜色
 *  @param action    事件
 */
-(void) buildIcon:(FAIcon )icon titTxt:(NSString *) tit forColor:(NSString *) colorStr andLColor:(NSString *) lColorStr action:(ActionBlock)action{
    
    ComButton * iconLib=[[ComButton alloc] init];
    
    iconLib.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
    iconLib.titleLabel.font =  [UIFont fontWithName:@"FontAwesome" size:24];
    iconLib.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    iconLib.tintColor = [UIColor whiteColor];
    iconLib.titleLabel.textAlignment=NSTextAlignmentCenter;
    iconLib.contentEdgeInsets = UIEdgeInsetsMake(0,0, 0, 0);
    [iconLib.layer setCornerRadius:self.frame.size.width/2]; //设置矩圆角半径
    //        iconLib.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    
    UILabel * titLib = [[UILabel alloc] init];
    titLib.frame = CGRectMake(0, self.frame.size.width, self.frame.size.width, 20);
    titLib.text = tit;
    titLib.textAlignment =NSTextAlignmentCenter;
    titLib.textColor = [UIColor whiteColor];
    titLib.font =  [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];
    
    self.iconLb = iconLib;
    self.titTxt = titLib;
    
    
    
    
    
    [self.iconLb setTitle:[NSString stringFromAwesomeIcon:icon] forState:UIControlStateNormal];
    [self.iconLb.layer setBackgroundColor:[UIColor HexString:colorStr].CGColor];
    
    
    [self.iconLb setAdjustsImageWhenDisabled:YES];
    [self.iconLb changeColor:colorStr andColorLight:lColorStr];
    
    
    [self.iconLb action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.iconLb];
    [self addSubview:self.titTxt];
    
}

@end
