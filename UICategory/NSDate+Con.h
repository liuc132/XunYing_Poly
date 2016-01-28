//
//  NSDate+Con.h
//  CommonLibrary
//
//  Created by 周杨 on 15/1/19.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Con)

/**
 *  根据StringFormat转换为字符串
 *
 *  @param formatStr 日期格式
 *
 *  @return 字符串
 */
-(NSString *) toString:(NSString *) formatStr;

/**
 *  根据字符串转换为date实例
 *
 *  @param dateString 日期类字符串 如：yyyy-MM-dd hh:mm:ss
 *
 *  @return 日期类对象实例
 */
+ (NSDate *) dateFromString:(NSString *)dateString;

@end
