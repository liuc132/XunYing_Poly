//
//  ComTextFieldEvent.h
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/7.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ComTextFieldEvent : NSObject<UITextFieldDelegate>

/**
 *  最大长度
 */
@property (nonatomic) int maxLength;

/**
 *  文本框字符输入事件
 *
 *  @param textField <#textField description#>
 *  @param range     <#range description#>
 *  @param string    <#string description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;


@end
