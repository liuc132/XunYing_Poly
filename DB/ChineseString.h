//
//  ChineseString.h
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/12.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "pinyin.h"
#import "DataTable.h"

@interface ChineseString : NSObject
@property(retain,nonatomic)NSString *string;
@property(retain,nonatomic)NSString *pinYin;

/**
 *  返回字母索引
 *
 *  @param dt         数据集
 *  @param columnName
 *
 *  @return 字母索引数组
 */
+(NSMutableArray*)IndexArray:(DataTable *) dt forColumnName:(NSString *) columnName;

/**
 *  返回字母索引
 *
 *  @param dt
 *
 *  @return
 */
+(NSMutableArray*) IndexArray:(DataTable *)dt;

/**
 *  返回一组字母排序数组(中英混排)
 *
 *  @param dt         数据集
 *  @param columnName 中文字段列名
 *
 */
+(void)SortArray:(DataTable *) dt forColumnName:(NSString *) columnName;

@end
