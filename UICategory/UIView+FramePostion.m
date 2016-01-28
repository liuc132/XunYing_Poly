//
//  UIView+FramePostion.m
//  CommonLibrary
//
//  Created by 周杨 on 15/3/12.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "UIView+FramePostion.h"
#include "XunYingPre.h"

@implementation UIView (FramePostion)

/**
 *  设置视图控件的垂直偏移
 *
 *  @param prevUI 相对于上一控件
 *  @param x      X轴偏移量
 *  @param y      Y轴偏移量
 */
-(void) setVerticalPostion:(UIView *) prevUI forX:(double) x andY:(double) y{
    if (prevUI) {
        
        self.frame = CGRectMake(prevUI.frame.origin.x+x, prevUI.frame.origin.y+prevUI.frame.size.height+y, self.frame.size.width, self.frame.size.height);
    }
}

/**
 *  设置视图控件的水平偏移
 *
 *  @param prevUI 相对于上一控件
 *  @param x      X轴偏移量
 *  @param y      Y轴偏移量
 */
-(void) setHorizontalPostion:(UIView *) prevUI forX:(double) x andY:(double) y{
    if (prevUI) {
        
        self.frame = CGRectMake(prevUI.frame.origin.x+prevUI.frame.size.width +x, prevUI.frame.origin.y+y, self.frame.size.width, self.frame.size.height);
    }
}

/**
 *  设置视图控件居中
 */
-(void) setMediation{
    
    CGRect  toFrame = self.frame;
    
    toFrame.origin = CGPointMake((ScreenWidth -self.frame.size.width)/2, toFrame.origin.y);
    
    self.frame =toFrame;
//    self.frame = CGRectMake(, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
}

/**
 *  设置布局方式
 *
 *  @param floatPostion 布局方式【居左、居右】
 *  @param x            偏移值
 */
-(void) setFloatPostion:(FloatPostion) floatPostion andX:(double) x{
    CGRect  toFrame = self.frame;
    
    switch (floatPostion) {
        case LeftFloat:
            toFrame.origin = CGPointMake(x, toFrame.origin.y);
            break;
        case RightFloat:
            toFrame.origin = CGPointMake(ScreenWidth -self.frame.size.width-x, toFrame.origin.y);
            break;
        case TopFloat:
            toFrame.origin = CGPointMake(toFrame.origin.x, x);
            break;
        case BottomFloat:
            toFrame.origin = CGPointMake(toFrame.origin.x, ScreenHeight-toFrame.size.height-x);
            break;
        default:
            
            break;
    }
    
    self.frame = toFrame;
}

/**
 *  设置布局方式
 *
 *  @param floatPostion 布局方式【居左、居右、居上、居下】
 *  @param view         UIView
 *  @param x            偏移值
 */
-(void) setFloatPostion:(FloatPostion) floatPostion forView:(UIView *) view andX:(double) x{

    CGRect  toFrame =self.frame;
    
    switch (floatPostion) {
        case LeftFloat:
            toFrame.origin = CGPointMake(x, toFrame.origin.y);
            break;
        case RightFloat:
            toFrame.origin = CGPointMake(view.frame.size.width -self.frame.size.width-x, toFrame.origin.y);
            break;
        case TopFloat:
            toFrame.origin = CGPointMake(toFrame.origin.x, x);
            break;
        case BottomFloat:
            toFrame.origin = CGPointMake(toFrame.origin.x, view.frame.size.height-toFrame.size.height-x);
            break;
        default:
            
            break;
    }
    
    self.frame = toFrame;
}


@end
