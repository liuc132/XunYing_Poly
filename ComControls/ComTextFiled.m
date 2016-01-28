//
//  ComTextFiled.m
//  Common
//
//  Created by 周杨 on 15/1/8.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "ComTextFiled.h"
#import "UIFactory.h"

@implementation ComTextFiled
{
float prewMoveY; //编辑的时候移动的高度
}

/**
 *  重写加载方法
 *
 *  @return 对象实例
 */
-(instancetype) init{
    self = [super init];
    
    if (self) {
        
        prewMoveY=0;
        
        UILabel * iconLb=[[UILabel alloc] init];
        iconLb.textColor =[UIColor whiteColor];
//        iconLb.text=@"";
//        iconLb.frame = CGRectMake(10, 10, 40, 30);
//        iconLb.textAlignment =NSTextAlignmentCenter;
        
        iconLb.frame = CGRectMake(10, 10, 10, 30);
        iconLb.textAlignment =NSTextAlignmentCenter;
        
        self.pIconLable =iconLb;
        
        self.leftView =self.pIconLable;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.placeholder=@" ";
        
        [self blackColorStyle];
        
        //为控件绑定开始编辑与结束编辑的事件
        [self addTarget:self action:@selector(editStrat:) forControlEvents:UIControlEventEditingDidBegin];
        [self addTarget:self action:@selector(editEnd:) forControlEvents:UIControlEventEditingDidEnd];
        
//        [self addTarget:self action:@selector(editVal:) forControlEvents:UIControlEventAllEvents];
        
    }
    
    return self;
}

- (void)editVal:(ComTextFiled *) textFiled
{
    
    NSLog(@"12311");
}

/**
 *  文本得到焦点，触发事件
 *
 *  @param textFiled
 */
-(void) editStrat:(ComTextFiled *) textFiled{
    //编辑样式
    textFiled.oldTextFiledColorStyle =textFiled.textFiledColorStyle;
    
    switch (textFiled.textFiledColorStyle) {
        case ColorBlack:
            [textFiled whiteColorStyle];
            break;
        case ColorGray:
            [textFiled blackColorStyle];
            break;
        case ColorWhite:
            [textFiled blackColorStyle];
            break;
        case ColorGreen:
            [self colorStyleFor:@"49bdcc" andTxtColor:@"ffffff"];
            break;
        case ColorClear:
            
            break;
        default:
            [textFiled blackColorStyle];
            break;
    }
    
    CGRect textFrame =  textFiled.frame;
    float textY = textFrame.origin.y+textFrame.size.height+100;
    
    float bottomY = textFiled.superview.frame.size.height-textY;
    if(bottomY>=216)  //判断当前的高度是否已经有216，如果超过了就不需要再移动主界面的View高度
    {
        return;
    }
    
    float moveY = 216-bottomY;
    prewMoveY = moveY;
    
    NSTimeInterval animationDuration = 0.0f;
    CGRect frame = textFiled.superview.frame;
    frame.origin.y -=moveY;//view的Y轴上移
    frame.size.height +=moveY; //View的高度增加
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    textFiled.superview.frame = frame;
    [UIView commitAnimations];//设置调整界面的动画效果

}

/**
 *  文本失去焦点，触发事件
 *
 *  @param textFiled
 */
-(void) editEnd:(ComTextFiled *) textFiled{
    
    [textFiled setColorStyle:textFiled.oldTextFiledColorStyle];
    
    float moveY ;
    NSTimeInterval animationDuration = 0.40f;
    CGRect frame = textFiled.superview.frame;
    if(prewMoveY != 0) //当结束编辑的View的TAG是上次的就移动
    {   //还原界面
        moveY =  prewMoveY;
        frame.origin.y +=moveY;
        frame.size. height -=moveY;
        textFiled.superview.frame = frame;
    }
    //self.view移回原位置
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    textFiled.superview.frame = frame;
    [UIView commitAnimations];
    
    prewMoveY=0;
}

/**
 *  根据颜色样式加载按钮
 *
 *  @param colorStyle 颜色的样式
 *
 *  @return 对象实例
 */
-(instancetype) initForColorStyle:(ColorStyle) colorStyle{
    self = [super init];
    
    if (self) {
        
        [self setColorStyle:colorStyle];
    }
    
    return self;
}

/**
 *  设置文本控件颜色样式
 *
 *  @param colorStyle 颜色枚举
 */
-(void) setColorStyle:(ColorStyle) colorStyle{
    switch (colorStyle) {
        case ColorBlack:
            [self blackColorStyle];
            break;
        case ColorGray:
            [self grayColorStyle];
            break;
        case ColorWhite:
            [self whiteColorStyle];
            break;
        case ColorGreen:
            [self greenColorStyle];
            break;
        case ColorClear:
            
            break;
        default:
            
            [self blackColorStyle];
            break;
    }
    
}

/**
 *  黑色样式
 */
-(void) blackColorStyle{
    
    NSString * bcColor=@"#323745";
    NSString * txtColor = @"#ffffff";
    
    self.textFiledColorStyle = ColorBlack;
    
    [self colorStyleFor:bcColor andTxtColor:txtColor];
}

/**
 *  绿色样式
 */
-(void) greenColorStyle{
    NSString * bcColor=@"#ffffff";
    NSString * txtColor = @"#b3b3b3";
    
    self.textFiledColorStyle = ColorGreen;
    
    [self colorStyleFor:bcColor andTxtColor:txtColor];
}

/**
 *  灰色样式
 */
-(void) grayColorStyle{
    NSString * bcColor=@"#292d39";
    NSString * txtColor = @"#77829c";
    
    self.textFiledColorStyle = ColorGray;
    
    [self colorStyleFor:bcColor andTxtColor:txtColor];
}


/**
 *  白色样式
 */
-(void) whiteColorStyle{

    
    NSString * bcColor=@"#ffffff";
    NSString * txtColor = @"#323745";
    
    self.textFiledColorStyle = ColorWhite;
    
    [self colorStyleFor:bcColor andTxtColor:txtColor];
    
}

/**
 *  透明样式
 */
-(void) clearColorStyle{
    NSString * bcColor=@"#ffffffff";
    NSString * txtColor = @"#ffffff";
    
    self.textFiledColorStyle =ColorClear;
    
    [self colorStyleFor:bcColor andTxtColor:txtColor];
}


/**
 *  （私有）根据颜色构造样式
 *
 *  @param color        背景颜色
 *  @param txtColor     文字颜色
 */
-(void) colorStyleFor:(NSString *) color andTxtColor:(NSString *) txtColor{
    [self.layer setCornerRadius:4.0]; //设置矩圆角半径
    [self.layer setBorderWidth:0];   //边框宽度
    
    self.borderStyle =UITextBorderStyleNone;
    self.backgroundColor =[UIColor HexString:color];
    self.textColor = [UIColor HexString:txtColor];
    
    [self setValue:[UIColor HexString:txtColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    
    self.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    self.pIconLable.textColor= [UIColor HexString:txtColor];
}

/**
 *  设置TextFieldIcon图标
 *
 *  @param faicon
 *  @param size
 */
-(void) setIconLable:(FAIcon)faicon size:(int) size{
    self.pIconLable.textColor= self.textColor;
    
    self.pIconLable.text=[NSString stringFromAwesomeIcon:faicon];
    self.pIconLable.font = [UIFont fontWithName:@"FontAwesome" size:size];
    self.pIconLable.frame = CGRectMake(10, 10, size*2, 30);
}

/**
 *  设置清空按钮颜色
 *
 *  @param color 颜色
 */
-(void) setClearIconColor:(UIColor *) color{
    ComLable * clearLib = [[ComLable alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
    [clearLib setIconLable:FAIconRemoveSign size:16];
    clearLib.textColor=color;
    
    [clearLib onClick:^{
        self.text = @"";
    
    }];
    self.rightView = clearLib;
    self.rightViewMode = UITextFieldViewModeAlways;
    
    
}

/*邮箱验证 MODIFIED BY HELENSONG*/
-(BOOL)isValidateEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self.text];
}

/*手机号码验证 MODIFIED BY HELENSONG*/
-(BOOL) isValidateMobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:self.text];
}

@end
