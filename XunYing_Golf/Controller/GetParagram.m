//
//  GetParagram.m
//  XunYing_Golf
//
//  Created by LiuC on 16/1/28.
//  Copyright © 2016年 LiuC. All rights reserved.
//

#import "GetParagram.h"
#import "DataTable.h"
#import "DBCon.h"
#import "GetRequestIPAddress.h"
#import "HttpTools.h"

@interface GetParagram ()

@property (strong, nonatomic) DBCon *dbCon;
//@property (strong, nonatomic) DataTable *

@end


@implementation GetParagram

+ (void)getCaddyCartInf
{
    //
    DBCon *dbCon = [[DBCon alloc] init];
    //前九洞，后九洞，十八洞
    [dbCon ExecNonQuery:@"delete from tbl_threeTypeHoleInf"];
    [dbCon ExecNonQuery:@"delete from tbl_cartInf"];
    [dbCon ExecNonQuery:@"delete from tbl_caddyInf"];
    //获取到URL
    NSString *caddyCartURLStr;
    caddyCartURLStr = [GetRequestIPAddress getCaddyCartInfURL];
    
    dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC ) ;
    dispatch_after(time, dispatch_get_main_queue(), ^{
        //start request
        [HttpTools getHttp:caddyCartURLStr forParams:nil success:^(NSData *nsData){
            NSDictionary *receiveDic;
            receiveDic = (NSDictionary *)nsData;
#ifdef DEBUG_MODE
            NSLog(@"caddy count:%ld",[receiveDic[@"Msg"][@"caddys"] count]);
#endif
            //获取到当前的球车
            NSArray *allCarts = receiveDic[@"Msg"][@"carts"];
            //        NSDictionary *oneCart = [[NSDictionary alloc] init];
            for (NSDictionary *eachCart in allCarts) {
                NSMutableArray *eachCartParam = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
                //tbl_cartInf(carcod text,carnum text,carsea text)
                [dbCon ExecNonQuery:@"insert into tbl_cartInf(carcod,carnum,carsea) values(?,?,?)" forParameter:eachCartParam];
            }
            //保存所有可用球童的信息
            NSArray *allCaddies = receiveDic[@"Msg"][@"caddys"];
            for (NSDictionary *eachCaddy in allCaddies) {
                NSMutableArray *eachCaddyParam = [[NSMutableArray alloc] initWithObjects:eachCaddy[@"cadcod"],eachCaddy[@"cadnam"],eachCaddy[@"cadnum"],eachCaddy[@"cadsex"],eachCaddy[@"empcod"], nil];
                //tbl_caddyInf(cadcod text,cadnam text,cadnum text,cadsex text,empcod text)
                [dbCon ExecNonQuery:@"insert into tbl_caddyInf(cadcod,cadnam,cadnum,cadsex,empcod) values(?,?,?,?,?)" forParameter:eachCaddyParam];
            }
            
            //保存三种类型的球洞的参数
            NSArray *allHoles = receiveDic[@"Msg"][@"holes"];
            for (NSDictionary *eachTypeHole in allHoles) {
                NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachTypeHole[@"pdcod"],eachTypeHole[@"pdind"],eachTypeHole[@"pdnam"],eachTypeHole[@"pdpcod"],eachTypeHole[@"pdtag"],eachTypeHole[@"pdtcod"], nil];
                [dbCon ExecNonQuery:@"insert into tbl_threeTypeHoleInf(pdcod,pdind,pdnam,pdpcod,pdtag,pdtcod) values(?,?,?,?,?,?)" forParameter:eachHoleParam];
            }
        }failure:^(NSError *err){
#ifdef DEBUG_MODE
            NSLog(@"caddyCartInf request failed");
#endif
            
        }];
    });

}
#pragma -mark getCustomInf
+ (void)getCustomInf
{
    //
    DBCon *dbCon = [[DBCon alloc] init];
    //
    [dbCon ExecNonQuery:@"delete from tbl_CustomerNumbers"];
    //
    NSString *customURLStr;
    customURLStr = [GetRequestIPAddress getCustomInfURL];
    
    dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC ) ;
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        //start request
        [HttpTools getHttp:customURLStr forParams:nil success:^(NSData *nsData){
#ifdef DEBUG_MODE
            NSLog(@"request successfully");
#endif
            NSDictionary *receiveDic;
            receiveDic = (NSDictionary *)nsData;
            //
            NSString *cusNumberString;// = [[NSString alloc] init];
            cusNumberString = receiveDic[@"Msg"];
            NSArray *cusNumberArray = [cusNumberString componentsSeparatedByString:@";"];//拆分接收到的数据
            //将数据加载到创建的数据库中
            [dbCon ExecNonQuery:@"INSERT INTO tbl_CustomerNumbers(first,second,third,fourth) VALUES(?,?,?,?)" forParameter:(NSMutableArray *)cusNumberArray];
            
        }failure:^(NSError *err){
#ifdef DEBUG_MODE
            NSLog(@"request fail");
#endif
            
        }];
    });

}
#pragma -mark willLogOutHandle
+ (void)willLogOutHandle
{
    //
    DBCon *dbCon = [[DBCon alloc] init];
    DataTable *logCaddy;// = [[DataTable alloc] init];
    
    logCaddy = [dbCon ExecDataTable:@"select *from tbl_NamePassword"];
    
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //
    NSMutableDictionary *logOutDicParam = [[NSMutableDictionary alloc]initWithObjectsAndKeys:theMid,@"mid",logCaddy.Rows[0][@"user"],@"username",logCaddy.Rows[0][@"password"],@"pwd",@"0",@"panmull", nil];
    //
    NSString *logoutURLStr;
    logoutURLStr = [GetRequestIPAddress getLogOutURL];

    //删除本地的登录人信息以及组信息
    [dbCon ExecNonQuery:@"delete from tbl_logPerson"];
    [dbCon ExecNonQuery:@"delete from tbl_groupInf"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //request
        [HttpTools getHttp:logoutURLStr forParams:logOutDicParam success:^(NSData *nsData){
            NSLog(@"request success");
            //            NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *recDic;
            recDic = (NSDictionary *)nsData;
            
            NSLog(@"code:%@ msg:%@",recDic[@"Code"],recDic[@"Msg"]);
            if ([recDic[@"Code"] integerValue] > 0) {
                //删除本地的登录人信息以及组信息
                
            }
            
        }failure:^(NSError *err){
            NSLog(@"request failled");
            UIAlertView *errAlert = [[UIAlertView alloc] initWithTitle:@"退出登录失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [errAlert show];
            
        }];
    });
}



@end
