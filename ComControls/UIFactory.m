//
//  UIFactory.m
//  UI控件创建工厂   封装通用包的控件及样式
//
//  Created by 周杨 on 15/1/5.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "UIFactory.h"

#import "UIColor+UICon.h"

@implementation UIFactory

/**
 *  根据标题，创建封装按钮
 *
 *  @param title 标题名称
 *
 *  @return 封装按钮实例
 */
+(ComButton *) CreateUIButton:(NSString *) title{
    ComButton * btn=[[ComButton alloc ] init];
    
    [btn blueColorStyle];
    
    [btn setAdjustsImageWhenDisabled:YES];
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return btn;
}

/**
 *  根据标题，创建页面底部的封装按钮
 *
 *  @param title title 标题名称
 *
 *  @return 封装按钮实例
 */
+(ComButton *) CreateBottomUIButton:(NSString *) title{
    ComButton * btn=[ComButton buttonWithType:UIButtonTypeCustom ];
    
    
    [btn.layer setMasksToBounds:true];
    [btn.layer setCornerRadius:0]; //设置矩圆角半径
    [btn.layer setBorderWidth:0];   //边框宽度
    [btn.layer setBackgroundColor:[UIColor HexString:color].CGColor];
    
    
    UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 1)];
    UIView * separator2 = [[UIView alloc] initWithFrame:CGRectMake(0, 1, [[UIScreen mainScreen] bounds].size.width, 1)];
    separator.backgroundColor = [UIColor HexString:@"#f3f3f3"];
    separator2.backgroundColor = [UIColor HexString:@"#d8d8d8"];
    
    [btn addSubview:separator];
    [btn addSubview:separator2];
    
    btn.layer.shadowOffset=CGSizeZero;
    btn.titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:14.0];
    
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return btn;
}

@end
