//
//  ComTextFieldEvent.m
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/7.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "ComTextFieldEvent.h"

@implementation ComTextFieldEvent



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
    NSInteger strLength = textField.text.length - range.length + string.length;
    
    return (strLength <= self.maxLength);
    
}
@end
