//
//  BLMessageProvider.m
//  BackgroundLocation
//
//  Created by Nick Martin on 10/1/14.
//  Copyright (c) 2014 BuggyList. All rights reserved.
//

#import "BLMessageProvider.h"
#import "AFHTTPRequestOperationManager.h"
#import "XunYingPre.h"
#import "DataTable.h"
#import "DBCon.h"

static BLMessageProvider *instance = nil;
//添加心跳接口
static NSString *urlFormat = @"http://jlcmobile.com/nick.nsf/test?openagent&%@&%@&%@";

@interface BLMessageProvider ()

@property (strong, nonatomic) DataTable *grpInf;
@property (strong, nonatomic) DataTable *userInf;
@property (strong, nonatomic) DBCon     *lcDBCon;

@end


@implementation BLMessageProvider

+(instancetype)sharedProvider{
    if(instance == nil){
        instance = [[super allocWithZone:NULL] init];
        urlFormat = HeartBeatSubURL;
        //
        
    }
    
    return instance;
}

-(void)sendLocation:(NSString *)logitude
           latitude:(NSString *)latitude
   applicationState:(NSString *)state{
    
    self.grpInf = [[DataTable alloc] init];
    self.userInf = [[DataTable alloc] init];
    self.lcDBCon = [[DBCon alloc] init];
    //在内存中查询相应的参数
    self.grpInf = [self.lcDBCon ExecDataTable:@"select *from tbl_groupInf"];
    self.userInf = [self.lcDBCon ExecDataTable:@"select *from tbl_logPerson"];
    //
    NSLog(@"url:%@",urlFormat);
    NSString *requestUrl = urlFormat;
    //NSMutableDictionary *heartBeatParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:TESTMIDCODE,@"mid",self.userData.Rows[0][@"job"],@"job",[NSData data],@"loct",self.simulationGPSData[startCount][0],@"locx",self.simulationGPSData[startCount][1],@"locy",self.groupInformation.Rows[0][@"grocod"],@"grocod",@"1",@"gpsType",self.userData.Rows[0][@"code"],@"bandcode", nil];
    
    
    //构建请求参数
    NSMutableDictionary *heartParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:MIDCODE,@"mid",self.userInf.Rows[0][@"job"],@"job",[NSDate date],@"loct",logitude,@"locx",latitude,@"locy", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestUrl parameters:heartParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
