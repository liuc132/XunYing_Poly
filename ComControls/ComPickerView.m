//
//  ComPickerView.m
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/27.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "ComPickerView.h"
#import "XunYingPre.h"

@implementation ComPickerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor whiteColor];
//    self.layer.opacity =0.1;
    
    float rectWidht = rect.size.width;
    float rectHeight = rect.size.height;
    
    //选择控件
    UIPickerView * selectPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 300)];
    selectPicker.delegate = self;
    selectPicker.dataSource = self;
    selectPicker.backgroundColor = [UIColor HexString:@"f5f5f5"];
    selectPicker.showsSelectionIndicator = YES;
    selectPicker.layer.borderWidth =0.3;
    selectPicker.frame = CGRectMake(0,rectHeight - 180, rectWidht, 180);  //    UIDatePicker * uiPi
    
    [self addSubview:selectPicker];
    
    //处理关闭键盘及失去文本焦点
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tgrAction:)];
    [self addGestureRecognizer:tgr];
}

-(void) tgrAction:(UITapGestureRecognizer*) sender{
    [self HideView];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.bingLib.text =self.dbArr[row];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.dbArr count];
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.dbArr objectAtIndex:row];
}

/**
 *  显示视图
 */
-(void) ShowView{
    [self setHidden:NO];
}

/**
 *  影藏视图
 */
-(void) HideView{
    self.bingLib.backgroundColor = [UIColor clearColor];
    
    [self setHidden:YES];
}

@end
