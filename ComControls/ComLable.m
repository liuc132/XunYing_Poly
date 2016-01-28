//
//  ComLable.m
//  Common
//
//  Created by 周杨 on 15/1/11.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "ComLable.h"
#import "UIColor+UICon.h"
#import "NSString+FontAwesome.h"

@implementation ComLable

/**
 *  设置FAIcon图标
 *
 *  @param faicon
 *  @param size
 */
-(void) setIconLable:(FAIcon)faicon size:(int) size{
    self.font = [UIFont fontWithName:@"FontAwesome" size:size];
    self.textColor =[UIColor whiteColor];
    self.text=[NSString stringFromAwesomeIcon:faicon];
}



/**
 *  设置为 黑色样式
 */
-(void) blackColorStyle{
    //self.tintColor
//    self.backgroundColor = [UIColor HexString:@"#292d39"];
    self.layer.backgroundColor = [UIColor HexString:@"#292d39"].CGColor;
    self.layer.borderColor = [UIColor HexString:@"#667086"].CGColor;
    self.textColor =[UIColor HexString:@"#667086"];
}

/**
 *  设置为 灰色样式
 */
-(void) grayColorStyle{
    //self.backgroundColor = [UIColor HexString:@"#393f4f"];
    self.layer.borderColor = [UIColor HexString:@"#8e95a5"].CGColor;
    self.layer.backgroundColor = [UIColor HexString:@"#393f4f"].CGColor;
    self.textColor =[UIColor HexString:@"#8e95a5"];
}

/**
 *  设置为 白色样式
 */
-(void) whiteColorStyle{
    //self.backgroundColor = [UIColor HexString:@"#ffffff"];
    self.layer.borderColor = [UIColor HexString:@"#ffffff"].CGColor;
    self.layer.backgroundColor = [UIColor HexString:@"#676c79"].CGColor;
    self.textColor =[UIColor HexString:@"ffffff"];
}


/**
 *  设置 圆角边框
 */
-(void) borderRadiusStyle{
    self.textAlignment = NSTextAlignmentCenter;
    
    [self.layer setCornerRadius:6.0]; //设置矩圆角半径
    [self.layer setBorderWidth:3];   //边框宽度
}

/**
 *  设置 圆形边框
 */
-(void) borderCircleStyle{
    self.textAlignment = NSTextAlignmentCenter;
    
    [self.layer setCornerRadius:self.bounds.size.width/2]; //设置矩圆角半径
    [self.layer setBorderWidth:3];
}

/**
 *  设置 无边框
 */
-(void) borderNoneStyle{
    [self.layer setBorderWidth:0];
}

/**
 *  点击事件
 *
 *  @param actionBlock 事件闭包
 */
-(void) onClick:(ActionBlock)action{
    
    self.actionBlock = action;
    
    UITapGestureRecognizer *gensture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidFun)];
    self.userInteractionEnabled=YES;
    gensture.delegate = self;
    [self addGestureRecognizer:gensture];
}

- (void)hidFun{
    self.actionBlock();
    
    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:0.4f];
    //动画的内容
    self.transform = CGAffineTransformScale(self.transform , 1.1, 1.1);
    //动画结束
    [UIView commitAnimations];
    
    self.transform = CGAffineTransformIdentity;
    
}
@end
