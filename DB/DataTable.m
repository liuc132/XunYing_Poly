//
//  DataTable.m
//  Common
//
//  Created by 周杨 on 14/12/22.
//  Copyright (c) 2014年 zhouy. All rights reserved.
//

#import "DataTable.h"

@implementation SectionObj

@end


@implementation DataTable

-(instancetype) init{
    self = [super init];
    
    self.Columns = [[NSMutableArray alloc] init];
    self.Rows = [[NSMutableArray alloc] init];
    self.Section = [[NSMutableArray alloc] init];
    
    return self;
    
}


/**
 *  通过数组方式构造数据集
 *
 *  @param columnArry 属性数组
 *
 *  @return DataTable的结果记录集
 */
-(instancetype) init:(NSArray *) columnArry{
    self = [super init];
    
    self.Columns = [[NSMutableArray alloc] initWithArray:columnArry];
    self.Rows = [[NSMutableArray alloc] init];
    
    return self;
}

/**
 *  通用相对路径来构造数据集    fileType为文件类型
 *
 *  @param parh     文件路径
 *  @param fileType 文件类型 【json 、plist 、xml】
 *
 *  @return DataTable的结果记录集
 */
-(instancetype) init:(NSString *) path forType:(NSString *) fileType{
    self = [super init];
    if (self) {
        NSString *toParh = [[NSBundle mainBundle] pathForResource:path ofType:fileType inDirectory:@""];
        
        NSArray * arr =  [[NSMutableDictionary alloc] initWithContentsOfFile:toParh][@"Rows"];
        
        self.Rows = [[NSMutableArray alloc] init];
        
        for (NSMutableDictionary * dic in arr) {
            
            if (self.Columns==nil) {
                self.Columns = [[NSMutableArray alloc] init];
                //得到词典中所有KEY值
                NSEnumerator * enumeratorKey = [dic keyEnumerator];
                //快速枚举遍历所有KEY的值
                for (NSString * key in enumeratorKey) {
                    [self.Columns addObject:key];
                }
            }
            
            
            [self.Rows addObject:dic];
            
        }
    }
    
    return self;
}

/**
 *  清空数据集
 */
-(void) clear{

    [self.Columns removeAllObjects];
    [self.Rows removeAllObjects];
}

/**
 *  在原有的结果记录集上  附加plist文件
 *
 *  @param dic 附加后新结果记录集
 */
-(void) appendByPlist:(NSDictionary *) dic{
    NSArray * arr =  dic[@"rows"];//The "rows" is the specified dictionary's key
    
    for (NSMutableDictionary * dic in arr) {
        
        if (self.Columns==nil) {
            self.Columns = [[NSMutableArray alloc] init];
            //得到词典中所有KEY值
            NSEnumerator * enumeratorKey = [dic keyEnumerator];
            //快速枚举遍历所有KEY的值
            for (NSString * key in enumeratorKey) {
                [self.Columns addObject:key];
            }
        }
        
        [self.Rows addObject:dic];
    }
    
}


/**
 *  在原有的结果记录集上  附加DataTable记录集
 *
 *  @param dt 附加后新结果记录集
 */
-(void) appendByDataTable:(DataTable *) dt{
    
    
    for (NSMutableDictionary * dic in dt.Rows) {
        
        if (self.Columns==nil) {
            self.Columns = [[NSMutableArray alloc] init];
            //得到词典中所有KEY值
            NSEnumerator * enumeratorKey = [dic keyEnumerator];
            //快速枚举遍历所有KEY的值
            for (NSString * key in enumeratorKey) {
                [self.Columns addObject:key];
            }
        }
        
        [self.Rows addObject:dic];
    }
    
}

/**
 *  添加测试数据
 *
 *  @param rows
 */
-(void) appendByTest:(int) rows{
    for (int i=0,size=rows;i<size; i++) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setValue:[[NSString alloc] initWithFormat:@"obj:%i",i ] forKey:@"test1"];
        [dic setValue:[[NSString alloc] initWithFormat:@"test:%i",50-i ] forKey:@"test2"];
        
        [dic setValue:[[NSString alloc] initWithFormat:@"obj:%i",i ] forKey:@"qdm"];
        [dic setValue:[[NSString alloc] initWithFormat:@"test:%i",50-i ] forKey:@"qdsm"];
        
        
        [self.Rows addObject:dic];
    }
}

/**
 *  根据字段名进行表格分区
 *
 *  @param columnName 区别的字段名称
 */
-(void) sectionBy:(NSString *) columnName{
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    
    for (NSMutableDictionary * dic in [self Rows]) {
        if (![arr containsObject:dic[columnName]]) {
            //            NSLog(@" xxx:%@",dic[columnName]);
            
            
            [arr addObject:dic[columnName]];
        }
    }
    
    [self setSection:arr];
}

/**
 *  根据分区得到行Array记录集
 *
 *  @param columnName    列名
 *  @param sectionIndex 分区号
 *
 *  @return NSMutableArray 列的结果记录集
 */
-(NSMutableArray *) getRows:(NSString *) columnName forSection: (NSInteger) sectionIndex{
    NSMutableArray * arr =[[NSMutableArray alloc] init];
    
    for (NSMutableDictionary * dic in [self Rows]) {
        NSString * typeStr =[self Section][sectionIndex];
        NSString * str = dic[columnName];
        
        if ( [ typeStr isEqual:str]) {
            [arr addObject:dic];
        }
    }
    
    
    
    
    
    return arr;
}

/**
 *  增加行记录
 *
 *  @param row NSMutableDictionary 行数据
 */
-(void) addRow:(NSMutableDictionary *) row{
    
    [[self Rows] addObject:row];
}

/**
 *  在某一行后，增加行记录
 *
 *  @param row   NSMutableDictionary 行数据
 *  @param index 行号
 */
-(void) addRow:(NSMutableDictionary *) row andIndex:(int) index{
    [[self Rows] insertObject:row atIndex:index];
}

/**
 *  清空行数据
 */
-(void) clearRows{
    [[self Rows] removeAllObjects];
    
    
}

/**
 *  DataTable实体类的返回空行，只有列名
 *
 *  @return NSMutableDictionary 空行数据
 */
-(NSMutableDictionary * ) newRow{
    NSMutableDictionary * row = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in [self Columns]) {
        [row setObject:@" " forKey:key];
    }
    
    return row;
}

/**
 *  返回某一行的数据
 *
 *  @param index 行号
 *
 *  @return NSMutableDictionary 数据
 */
-(NSMutableDictionary *)rowIndex:(int) index{
    NSMutableDictionary * row = [self Rows][index];
    return row;
}

/**
 *  查询事件
 *
 *  @param key 字段名
 *  @param str 比较的值
 *
 *  @return DT对象
 */
-(DataTable *) QueryBy:(NSString *) key like:(NSString *) str{
    DataTable * newDt = [[DataTable alloc] init];
    newDt.Columns = [[NSMutableArray alloc] initWithArray:self.Columns];
    
    if ([str isEqualToString:@""]) {
        newDt.Rows = [[NSMutableArray alloc] initWithArray:self.Rows];
        
        return newDt;
    }
    
    
    NSMutableArray * newRow =[[NSMutableArray alloc] init];
    for (NSMutableDictionary * dic in self.Rows) {
        if ([dic[key] rangeOfString:str].location != NSNotFound) {
            [newRow addObject:dic];
        }
    }
    newDt.Rows =newRow;
    
    
    
    return newDt;
}

@end
