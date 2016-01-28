//
//  NSDate+Con.m
//  CommonLibrary
//
//  Created by 周杨 on 15/1/19.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "NSDate+Con.h"

@implementation NSDate (Con)

/**
 *  根据StringFormat转换为字符串
 *
 *  @param formatStr 日期格式
 *
 *  @return 字符串
 */
-(NSString *) toString:(NSString *) formatStr{
    NSDateFormatter * dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatStr];
    
    NSString * dateStr = [dateFormatter stringFromDate:self];
    return dateStr;
}

/**
 *  根据字符串转换为date实例
 *
 *  @param dateString 日期类字符串 如：yyyy-MM-dd HH:mm:ss
 *
 *  @return 日期类对象实例
 */
+ (NSDate *) dateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
}

@end
