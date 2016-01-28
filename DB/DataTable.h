//
//  DataTable.h
//  Common
//
//  Created by 周杨 on 14/12/22.
//  Copyright (c) 2014年 zhouy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SectionObj : NSObject

/**
 *  分组的标题
 */
@property (nonatomic) NSString * HeaderTitle;

/**
 *  分组的行集
 */
@property (nonatomic) NSMutableArray * Rows;

@end


@interface DataTable : NSObject
/**
 *  列头
 */
@property (nonatomic,strong) NSMutableArray * Columns;
/**
 *  行集
 */
@property (nonatomic,strong) NSMutableArray * Rows;
/**
 *  当前分区
 */
@property (nonatomic,strong) NSMutableArray * Section;

/**
 *  通过数组方式构造数据集
 *
 *  @param columnArry 属性数组
 *
 *  @return DataTable的结果记录集
 */
-(instancetype) init:(NSArray *) columnArry;

/**
 *  通用相对路径来构造数据集    fileType为文件类型
 *
 *  @param path     文件路径
 *  @param fileType 文件类型 【json 、plist 、xml】
 *
 *  @return DataTable的结果记录集
 */
-(instancetype) init:(NSString *) path forType:(NSString *) fileType;

/**
 *  清空数据集
 */
-(void) clear;

/**
 *  在原有的结果记录集上  附加plist文件
 *
 *  @param dic 附加后新结果记录集
 */
-(void) appendByPlist:(NSDictionary *) dic;

/**
 *  在原有的结果记录集上  附加DataTable记录集
 *
 *  @param dt 附加后新结果记录集
 */
-(void) appendByDataTable:(DataTable *) dt;

/**
 *  添加测试数据
 *
 *  @param rows
 */
-(void) appendByTest:(int) rows;

/**
 *  根据字段名进行表格分区
 *
 *  @param columnName 区别的字段名称
 */
-(void) sectionBy:(NSString *) columnName;

/**
 *  清空行数据
 */
-(void) clearRows;

/**
 *  根据分区得到行Array记录集
 *
 *  @param columnName    列名
 *  @param sectionIndex 分区号
 *
 *  @return NSMutableArray 列的结果记录集
 */
-(NSMutableArray *) getRows:(NSString *) columnName forSection: (NSInteger) sectionIndex;


/**
 *  增加行记录
 *
 *  @param row NSMutableDictionary 行数据
 */
-(void) addRow:(NSMutableDictionary *) row;

/**
 *  在某一行后，增加行记录
 *
 *  @param row   NSMutableDictionary 行数据
 *  @param index 行号
 */
-(void) addRow:(NSMutableDictionary *) row andIndex:(int) index;

/**
 *  DataTable实体类的返回空行，只有列名
 *
 *  @return NSMutableDictionary 空行数据
 */
-(NSMutableDictionary * ) newRow;

/**
 *  返回某一行的数据
 *
 *  @param index 行号
 *
 *  @return NSMutableDictionary 数据
 */
-(NSMutableDictionary *)rowIndex:(int) index;


/**
 *  查询事件
 *
 *  @param key 字段名
 *  @param str 比较的值
 *
 *  @return DT对象
 */
-(DataTable *) QueryBy:(NSString *) key like:(NSString *) str;

@end
