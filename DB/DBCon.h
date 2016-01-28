//
//  DBCon.h
//
//  SQLITE DB类（单例）
//
//  执行语句及查询语句。与DataTable类关联。数据库查询语句返回DataTable类。
//
//  Created by 周杨 on 14/12/7.
//  Copyright (c) 2014年 zhouy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "DataTable.h"

/**
 *  SQLITE DB类（单例）.执行语句及查询语句。与DataTable类关联。数据库查询语句返回DataTable类。
 */
@interface DBCon : NSObject

/**
 *  数据库的连接字符串
 */
@property (nonatomic,strong) NSString * dbConnectionStr;

/**
 *  单例构造方法
 *
 *  @return DBCon的实例
 */
+(DBCon *) instance;

/**
 *  单例构造方法 数据库连接字符串
 *
 *  @param dbConStr 数据库连接字符串
 *
 *  @return DBCon的实例
 */
+(DBCon *) instance:(NSString *) dbConStr;

/**
 *  执行无返结果的SQL语句
 *
 *  @param sql SQL 语句
 */
-(void) ExecNonQuery:(NSString *) sql;

/**
 *  执行SQL查询语句并返回DataTable的结果记录集
 *
 *  @param sql SQL语句
 *
 *  @return DataTable结果集
 */
-(DataTable *) ExecDataTable:(NSString *) sql;

/**
 *  执行占位符方式的SQL语句
 *
 *  @param sql    SQL语句 占位符语句（select * from tbl where par='?' or insert into tbl1(filed1,filed2) values('?','?')）
 *  @param params arr(String) 方法参数集
 */
-(void) ExecNonQuery:(NSString *)sql forParameter:(NSMutableArray *) params;

@end
