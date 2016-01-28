//
//  DBCon.m
//  Common
//
//  Created by 周杨 on 14/12/22.
//  Copyright (c) 2014年 zhouy. All rights reserved.
//

#import "DBCon.h"

@implementation DBCon

static DBCon * myInstance;

+(id) allocWithZone:(struct _NSZone *) zone {
    @synchronized(self){
        if (myInstance==nil) {
            myInstance = [super allocWithZone:zone];
        }
        return myInstance;
    }
    
}
/**
 *  单例构造方法
 *
 *  @return DBCon的实例
 */
+(DBCon *) instance{
    @synchronized(self) {
        if (myInstance==nil) {
            myInstance =[[self alloc] init];
        }
        
        return myInstance;
    }
}

/**
 *  单例构造方法 数据库连接字符串
 *
 *  @param dbConStr 数据库连接字符串
 *
 *  @return DBCon的实例
 */
+(DBCon *) instance:(NSString *) dbConStr{
    @synchronized(self) {
        if (myInstance==nil) {
            myInstance =[[self alloc] init];
        }
        
        myInstance.dbConnectionStr =dbConStr;
        
        return myInstance;
    }
}

/**
 *  执行无返结果的SQL语句
 *
 *  @param sql SQL 语句
 */
-(void) ExecNonQuery:(NSString *) sql{
    sqlite3 * db;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [paths objectAtIndex:0];
    
//    NSLog(@"%@",docPath);
    
    const char * sqlFilePath= [[docPath stringByAppendingPathComponent:self.dbConnectionStr] UTF8String];
    //    const char * sqlFilePath= [[NSHomeDirectory() stringByAppendingPathComponent:self.dbConnectionStr] UTF8String];
    //NSLog(@"生成sqlite数据库路径：  %s",sqlFilePath);
    //NSLog(@"生成sqlite数据库路径：  %s",sqlFilePath);
    int result = sqlite3_open(sqlFilePath, &db);
    if (result == SQLITE_OK) {
        //NSLog(@"\n成功打开数据库 %s",sqlFilePath);
    }else {
        NSAssert1(0,@"Error:%s",sqlite3_errmsg(db));
    }
    
    [self execSql:sql andDb:db];
    
    sqlite3_close(db);
}

/**
 *  执行SQL查询语句并返回DataTable的结果记录集
 *
 *  @param sql SQL语句
 *
 *  @return DataTable结果集
 */
-(DataTable *) ExecDataTable:(NSString *) sql{
    DataTable * dt= [[DataTable alloc] init];
    
    sqlite3 * db;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [paths objectAtIndex:0];
    
//    NSLog(@"%@",docPath);
    
    
//    const char * sqlFilePath= [[NSHomeDirectory() stringByAppendingPathComponent:self.dbConnectionStr] UTF8String];
    const char * sqlFilePath= [[docPath stringByAppendingPathComponent:self.dbConnectionStr] UTF8String];
    //NSLog(@"生成sqlite数据库路径：  %s",sqlFilePath);
    int result = sqlite3_open(sqlFilePath, &db);
    if (result == SQLITE_OK) {
        //NSLog(@"\n成功打开数据库 %s",sqlFilePath);
        
        sqlite3_stmt * stmt;
        result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
        if (result==SQLITE_OK) {
            
            int colCount = sqlite3_column_count(stmt);
            
            for (int i=0,size=colCount; i<size; i++) {
                NSString * coloumn = [[NSString alloc] initWithUTF8String:sqlite3_column_name(stmt, i)];
                [dt.Columns addObject:coloumn];
                
            }
            
            while (sqlite3_step(stmt)==SQLITE_ROW) {
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
                for (int i=0,size=(int)dt.Columns.count; i<size; i++) {
                    
                    char * tempChar = (char *)sqlite3_column_text(stmt, i);
                    NSString * val;
                    if (tempChar!=nil) {
                        val=[[NSString alloc] initWithCString:tempChar encoding:NSUTF8StringEncoding];
                        
                    }
                    else{
                        val=@"";
                    }
                    
                    [dic setObject:val forKey:dt.Columns[i]];
                }
                
                [dt.Rows addObject:dic];
            }
        }
        else {
            NSAssert1(0,@"Error:%s",sqlite3_errmsg(db));
        }
        
        sqlite3_finalize(stmt);
    }
    
    sqlite3_close(db);
    return dt;
}

/**
 *  执行占位符方式的SQL语句
 *
 *  @param sql    SQL语句 占位符语句（select * from tbl where par='?' or insert into tbl1(filed1,filed2) values('?','?')）
 *  @param params arr(String) 方法参数集
 */
-(void) ExecNonQuery:(NSString *)sql forParameter:(NSMutableArray *) params{
    sqlite3 * db;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [paths objectAtIndex:0];
    
//    NSLog(@"%@",docPath);
    
    const char * sqlFilePath= [[docPath stringByAppendingPathComponent:self.dbConnectionStr] UTF8String];
//    const char * sqlFilePath= [[NSHomeDirectory() stringByAppendingPathComponent:self.dbConnectionStr] UTF8String];
    //NSLog(@"生成sqlite数据库路径：  %s",sqlFilePath);
    int result = sqlite3_open(sqlFilePath, &db);
    if (result == SQLITE_OK) {
        
        //根据不同类型的数据代入参数
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            for (int i = 1; i <= params.count; i++) {
                id param = [params objectAtIndex:i-1];
                
                if([param isKindOfClass:[NSNumber class]])
                {
                    sqlite3_bind_int(stmt, i, (int)[param integerValue]);
                }
                else
                {
                    sqlite3_bind_text(stmt, i, [param UTF8String], -1, SQLITE_TRANSIENT);
                }
                
            }
        }
        else {
            NSAssert1(0,@"Error:%s",sqlite3_errmsg(db));
        }
        
        NSInteger result  =sqlite3_step(stmt);
        if (result != SQLITE_DONE){
#ifdef DEBUG_MODE
            NSLog(@"执行出错%@",sql);
#endif
        }
        
        sqlite3_finalize(stmt);
    }
    sqlite3_close(db);
}

/**
 *  (私有方法) 执行SQL的函数
 *
 *  @param sql sql语句
 *  @param db  SQLITE 连接对象
 */
-(void) execSql:(NSString *) sql andDb:(sqlite3 *) db{
    
    char * errmg;
    int result = sqlite3_exec(db, [sql UTF8String], nil, nil, &errmg);
    if (result==SQLITE_OK) {
#ifdef DEBUG_MODE
        NSLog(@"\n执行SQL: %@ 成功。",sql);
#endif
    }
    else{
#ifdef DEBUG_MODE
        NSLog(@"\n执行SQL: %@  出错 \n错误信息：%s",sql,errmg);
#endif
    }
}


@end
