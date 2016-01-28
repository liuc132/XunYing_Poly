//
//  ChineseString.m
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/12.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "ChineseString.h"
@implementation ChineseString
@synthesize string;
@synthesize pinYin;

#pragma mark - 返回tableview右方 indexArray

/**
 *  返回字母索引
 *
 *  @param dt         数据集
 *  @param columnName 中文字段列名
 *
 *  @return 字母索引数组
 */
+(NSMutableArray*)IndexArray:(DataTable *) dt forColumnName:(NSString *) columnName{
    
    NSMutableArray *tempArray = [self ReturnSortChineseArrar:dt.Rows forColumnName:columnName];
    NSMutableArray *A_Result=[NSMutableArray array];
    NSString *tempString ;
    
    for (NSString* object in tempArray)
    {
        NSString *pinyin = [((ChineseString*)object).pinYin substringToIndex:1];
        //不同
        if(![tempString isEqualToString:pinyin])
        {
//            NSLog(@"IndexArray----->%@",pinyin);
            [A_Result addObject:pinyin];
            tempString = pinyin;
        }
    }
    return A_Result;
}

/**
 *  返回字母索引
 *
 *  @param dt
 *
 *  @return
 */
+(NSMutableArray*) IndexArray:(DataTable *)dt{
    NSMutableArray * tempArr = [[NSMutableArray alloc] init];
    
    for (SectionObj* obj in dt.Section)
    {
        [tempArr addObject:obj.HeaderTitle];
    }
    
    return tempArr;
}

//过滤指定字符串   里面的指定字符根据自己的需要添加
+(NSString*)RemoveSpecialCharacter: (NSString *)str {
    NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @",.？、 ~￥#&<>《》()[]{}【】^@/￡¤|§¨「」『』￠￢￣~@#&*（）——+|《》$_€"]];
    if (urgentRange.location != NSNotFound)
    {
        return [self RemoveSpecialCharacter:[str stringByReplacingCharactersInRange:urgentRange withString:@""]];
    }
    return str;
}

/**
 *  返回排序好的字符拼音
 *
 *  @param stringArr  数组
 *  @param columnName 字段名
 *
 *  @return <#return value description#>
 */
+(NSMutableArray*)ReturnSortChineseArrar:(NSArray*)stringArr forColumnName:(NSString *) columnName
{
    //获取字符串中文字的拼音首字母并与字符串共同存放
    NSMutableArray *chineseStringsArray=[NSMutableArray array];
    
    for (NSMutableDictionary * dic in stringArr) {
        [chineseStringsArray addObject:[self validationChineseString:dic[columnName]]];
    }
    
    //按照拼音首字母对这些Strings进行排序
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    
    return chineseStringsArray;
    
}

/**
 *  <#Description#>
 *
 *  @param zhStr <#zhStr description#>
 *
 *  @return return value description
 */
+(ChineseString *) validationChineseString:(NSString *) zhStr{
    ChineseString *chineseString=[[ChineseString alloc]init];
    chineseString.string=[NSString stringWithString:zhStr];
    if(chineseString.string==nil){
        chineseString.string=@"";
    }
    //去除两端空格和回车
    chineseString.string  = [chineseString.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //这里我自己写了一个递归过滤指定字符串   RemoveSpecialCharacter
    chineseString.string =[ChineseString RemoveSpecialCharacter:chineseString.string];
    
    //判断首字符是否为字母
    NSString *regex = @"[A-Za-z]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    NSString *initialStr = [chineseString.string length]?[chineseString.string substringToIndex:1]:@"";
    if ([predicate evaluateWithObject:initialStr])
    {
        NSLog(@"chineseString.string== %@",chineseString.string);
        //首字母大写
        chineseString.pinYin = [chineseString.string capitalizedString] ;
    }else{
        if(![chineseString.string isEqualToString:@""]){
            NSString *pinYinResult=[NSString string];
            for(int j=0;j<chineseString.string.length;j++){
                
//                NSLog(@"%hu",[chineseString.string characterAtIndex:j]);
                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",
                                               
                                               pinyinFirstLetter([chineseString.string characterAtIndex:j])]uppercaseString];
                
                
                
                
                
                pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            chineseString.pinYin=pinYinResult;
        }else{
            chineseString.pinYin=@"";
        }
    }


    return chineseString;
}

#pragma mark - 返回一组字母排序数组

+(void)SortArray:(DataTable *) dt forColumnName:(NSString *) columnName{
    
    /**
     *  构造分组数据
     */
    NSMutableArray *tempArray = [self IndexArray:dt forColumnName:columnName];
    for (NSString * chineseStr in tempArray) {
//        chineseStr.pinYin =[chineseStr.pinYin substringToIndex:1];
        
        SectionObj * sectionObj = [[SectionObj alloc] init];
        sectionObj.HeaderTitle =chineseStr;
        sectionObj.Rows = [[NSMutableArray alloc] init];
        
        [dt.Section addObject:sectionObj];
    }
    
    //把排序好的内容从ChineseString类中提取出来
    for (NSMutableDictionary * dic in dt.Rows) {
        for (SectionObj * sectionObj in dt.Section) {
            
            if ([sectionObj.HeaderTitle isEqualToString:[[self validationChineseString:dic[columnName]].pinYin substringToIndex:1]]) {
//                dic[@"byPinYin"] = sectionObj.HeaderTitle;
                
                [sectionObj.Rows addObject:dic];
            }
        }
    }
    
    
    
    
    //排序
//    NSSortDescriptor *sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"byPinYin" ascending:YES];
//    NSArray *sortDescriptors=[[NSArray alloc] initWithObjects:&sortDescriptor count:1];
//    [dt.Rows sortUsingDescriptors:sortDescriptors];
    
}

@end
