//
//  UIImageView+UICon.m
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/1.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "UIImageView+UICon.h"
#import "UIColor+UICon.h"

@implementation UIImageView (UICon)

/**
 *  设置为圆形样式
 */
-(void) setCircleStyle{
    
    self.layer.masksToBounds=YES;
    [self.layer setCornerRadius:self.frame.size.width/2];
    //self.image=[UIImage circleImage:self.image ];
}

/**
 *  设置boder样式
 */
-(void) setBoderStyle:(NSString *) hexColor{
    
   // self.layer
    self.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.layer.borderWidth =4;
    self.layer.borderColor = [UIColor HexString:hexColor].CGColor;
}


@end
