//
//  ComButton.m
//  Common
//
//  Created by 周杨 on 15/1/5.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "ComButton.h"

@implementation ComButton


/**
 *  重写加载方法
 *
 *  @return 对象实例
 */
-(instancetype) init{
    self = [super init];

    if (self) {
        
        //默认样式
        [self blueColorStyle];
    }
    
    return self;
}

/**
 *  根据颜色样式加载按钮
 *
 *  @param colorStyle 颜色的样式
 *
 *  @return 对象实例
 */
-(instancetype) initForColorStyle:(ComButtonColorStyle) colorStyle{
    
    self = [super init];
    
    if (self) {
        
        //默认样式
        [self setColorStyle:colorStyle];
    }
    
    return self;
}

/**
 *  设置按钮样式
 *
 *  @param colorStyle 颜色枚举
 */
-(void) setColorStyle:(ComButtonColorStyle) colorStyle{
    switch (colorStyle) {
        case blueColor:
            [self blueColorStyle];
            break;
        case pinkColor:
            [self pinkColorStyle];
            break;
        case grayColor:
            [self grayColorStyle];
            break;
        case greenColor:
            [self greenColorStyle];
            break;
        case orangeColor:
            [self orangeColorStyle];
            
            break;
    }

}

/**
 *  橙色按钮样式
 */
-(void) orangeColorStyle{
    
    NSString * colorStr =  @"#ffa959";              //定义普通颜色常量
    NSString * colorLightStr =  @"#ffb570";         //定义高亮颜色常量
    
    [self colorStyleFor:colorStr andColorLight:colorLightStr];
    
}

/**
 *  蓝色按钮样式
 */
-(void) blueColorStyle{
    /**
     *  蓝色的颜色样式
     */
    NSString * colorStr =  @"#4eb7cd";              //定义普通颜色常量
    NSString * colorLightStr =  @"#57d1eb";         //定义高亮颜色常量
     
    [self colorStyleFor:colorStr andColorLight:colorLightStr];
}

/**
 *  粉色按钮样式
 */
-(void) pinkColorStyle{
    
    /**
     *  粉色的颜色样式
     */
    NSString * colorStr =  @"#ff6b6b";              //定义普通颜色常量
    NSString * colorLightStr =  @"#ff8686";         //定义高亮颜色常量
    
    
    [self colorStyleFor:colorStr andColorLight:colorLightStr];
}

/**
 *  绿色按钮样式
 */
-(void) greenColorStyle{
    /**
     *  绿色的颜色样式
     */
    NSString * colorStr =  @"#55c45f";              //定义普通颜色常量
    NSString * colorLightStr =  @"#68d472";         //定义高亮颜色常量
    
    
    [self colorStyleFor:colorStr andColorLight:colorLightStr];
}

/**
 *  灰色按钮样式
 */
-(void) grayColorStyle{
    /**
     *  灰色的颜色样式
     */
    NSString * colorStr =  @"#393f4f";              //定义普通颜色常量
    NSString * colorLightStr =  @"#5a6378";         //定义高亮颜色常量
    
    
    [self colorStyleFor:colorStr andColorLight:colorLightStr];
}


/**
 *  （私有）根据颜色构造样式
 *
 *  @param color      默认颜色
 *  @param lightColor 高亮颜色
 */
-(void) colorStyleFor:(NSString *) color andColorLight:(NSString *) lightColor{
    [self.layer setMasksToBounds:true];
    [self.layer setCornerRadius:4.0]; //设置矩圆角半径
    [self.layer setBorderWidth:0];   //边框宽度
    
    if (self.iconLable!=nil) {
        self.contentEdgeInsets = UIEdgeInsetsMake(0,23, 0, 0);
    }
    
    //imageView.frame.origin.x+52
    //self.titleLabel.frame.origin.x+20;
    
    self.layer.shadowOffset=CGSizeZero;
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    
    [self setAdjustsImageWhenDisabled:YES];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self changeColor:color andColorLight:lightColor];
}

/**
 *  设置按钮的颜色状态
 *
 *  @param color      默认颜色
 *  @param lightColor 高亮颜色
 */
-(void) changeColor:(NSString *) color andColorLight:(NSString *) lightColor{
    
    [self setBackgroundImage:[UIImage createImageWithColor:[UIColor HexString:color]] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage createImageWithColor:[UIColor HexString:lightColor]] forState:UIControlStateHighlighted];
}

/**
 *  设置ButtonIcon图
 *
 *  @param faicon
 *  @param size
 */
-(void) setIconLable:(FAIcon)faicon size:(int) size{
    UILabel * iconLb=[[UILabel alloc] init];
    iconLb.font = [UIFont fontWithName:@"FontAwesome" size:18];
    iconLb.textColor =[UIColor whiteColor];
    iconLb.text=@"";
    //        iconLb.frame = CGRectMake(-20, 0, 18, 18);
    
    self.iconLable =iconLb;
    
    [self.viewForBaselineLayout addSubview:self.iconLable];
    
    self.iconLable.font = [UIFont fontWithName:@"FontAwesome" size:size];
    self.iconLable.text=[NSString stringFromAwesomeIcon:faicon];
    self.iconLable.frame = CGRectMake(-(size+5), 0, size+2, size+2);
    
}


/**
 *  通过闭包的方式触发按钮事件
 *
 *  @param action        函数闭包
 *  @param controlEvents 事件类型
 */
-(void)action:(ActionBlock)action forControlEvents:(UIControlEvents)controlEvents{
    self.actionBlock = action;
    
    [self addTarget:self action:@selector(hidFun) forControlEvents:controlEvents];
}

/**
 *  （私有） 处理按钮事件闭包调用
 */
-(void)hidFun{
    
    self.actionBlock();
}

@end
