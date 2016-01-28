//
//  ComRadioButton.m
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/19.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "ComRadioButton.h"
#import "UIFactory.h"

@interface ComRadioButton ()

@end

@implementation ComRadioButton

#pragma mark - Helpers
- (void)initilizeRadio {
    
    [self changeSelected:self.isSelected];
}

/**
 *  改变选中状态样式
 *
 *  @param selectedVal <#selectedVal description#>
 */
-(void) changeSelected:(BOOL) selectedVal{
    if (selectedVal) {
        [self setIconLable:FAIconOkSign size:20];
        self.textColor = self.fontColor;
        [self.layer setBorderColor:self.fontColor.CGColor];
    }
    else{
        [self.layer setCornerRadius:self.bounds.size.width/2]; //设置矩圆角半径
        [self.layer setMasksToBounds:true];
        self.backgroundColor =[UIColor whiteColor];
//        self.layer.backgroundColor = [UIColor HexString:@"999999"].CGColor;
        [self.layer setBorderWidth:1];
        self.text=@"";
        [self.layer setBorderColor:[UIColor HexString:@"C9CACA"].CGColor];
        
    }
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self initilizeRadio];
}

/**
 *  设置FAIcon图标
 *
 *  @param faicon
 *  @param size
 */
-(void) setIconLable:(FAIcon)faicon size:(int) size{
    self.font = [UIFont fontWithName:@"FontAwesome" size:size];
    self.text=[NSString stringFromAwesomeIcon:faicon];
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
    
    if (self.isSelected) {
        self.isSelected = false;
    }
    else{
        self.isSelected = true;
    }
    
    [self changeSelected:self.isSelected];
    
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

/*
- (ComLable *)drawIconWithSelection:(BOOL)selected {
    
    ComLable * lib = [[ComLable alloc] init];
    lib.frame = CGRectMake(0, 0, 18, 18);
    if (selected) {
        [lib setIconLable:FAIconOkSign size:18];
    }
    else{
        lib.frame = CGRectMake(0, 0, 18, 18);
        [lib.layer setCornerRadius:lib.bounds.size.width/2]; //设置矩圆角半径
        [lib.layer setMasksToBounds:true];
        [lib.layer setBorderWidth:2];
        [lib.layer setBorderColor:self.circleColor.CGColor];
        
        lib.backgroundColor = [UIColor whiteColor];
    }
    lib.textColor =self.circleColor;
    return lib;
}
*/
