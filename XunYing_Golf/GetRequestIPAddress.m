//
//  GetRequestIPAddress.m
//  XunYing_Golf
//
//  Created by LiuC on 16/1/5.
//  Copyright © 2016年 LiuC. All rights reserved.
//

#import "GetRequestIPAddress.h"
#import "DataTable.h"
#import "DBCon.h"
#import "XunYingPre.h"

@implementation GetRequestIPAddress

+ (DataTable *)getStoredData
{
    DataTable *settingInfo = [[DataTable alloc] init];
    DBCon     *lcDBCon     = [[DBCon alloc] init];
    //
    settingInfo = [lcDBCon ExecDataTable:@"select *from tbl_SettingInfo"];
    
    return settingInfo;
}

+ (DataTable *)getStoredUniqueID
{
    DataTable   *uniqueID   = [[DataTable alloc] init];
    DBCon       *DbCon      = [[DBCon alloc] init];
    //
    uniqueID = [DbCon ExecDataTable:@"select *from tbl_uniqueID"];
    
    return uniqueID;
}

+ (NSString *)getUniqueID
{
    NSString *uniqueIDStr;
    //
    DataTable *theStoredID = [GetRequestIPAddress getStoredUniqueID];
    if (![theStoredID.Rows count]) {
        uniqueIDStr = @"";
    }
    else
    {
        uniqueIDStr = theStoredID.Rows[0][@"uiniqueID"];
    }
    
    return uniqueIDStr;
    
}

+ (NSString *)getIntervalTime
{
    NSString *intervalTime;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        intervalTime = @"";
    }
    else
    {
        intervalTime = [NSString stringWithFormat:@"%@",theStoredData.Rows[0][@"interval"]];
    }
    //
    return intervalTime;
}

+ (NSString *)getServerURL
{
    NSString *heartURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        heartURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        heartURL = [NSString stringWithFormat:@"http://%@:%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"]];
    }
    //
    return heartURL;
}

+ (NSString *)getHeartBeatURL
{
    NSString *heartURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        heartURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        heartURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],HeartBeatSubURL];
    }
    //
    return heartURL;
}

+ (NSString *)getLogInURL
{
    NSString *logInURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        logInURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        logInURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],loginSubURL];
    }
    //
    return logInURL;
}

+ (NSString *)getJumpHoleURL
{
    NSString *jumpHoleURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        jumpHoleURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        jumpHoleURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],JumpHoleSubURL];
    }
    //
    return jumpHoleURL;
}
//
+ (NSString *)getMendHoleURL
{
    NSString *mendHoleURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        mendHoleURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        mendHoleURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],MendHoleSubURL];
    }
    //
    return mendHoleURL;
}

+ (NSString *)getCaddyCartInfURL
{
    NSString *caddyCartURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        caddyCartURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        caddyCartURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],CaddyCartInfSubURL];
    }
    //
    return caddyCartURL;
}

+ (NSString *)getCustomInfURL
{
    NSString *customURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        customURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        customURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],CustomInfSubURL];
    }
    //
    return customURL;
}

+ (NSString *)getcreateGroupURL
{
    NSString *creatGrpURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        creatGrpURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        creatGrpURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],createGroupSubURL];
    }
    //
    return creatGrpURL;
}

+ (NSString *)getCancleWaitingGroupURL
{
    NSString *cancleWaitURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        cancleWaitURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        cancleWaitURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],CancleWaitingGroupSubURL];
    }
    //
    return cancleWaitURL;
}

+ (NSString *)getBackToFieldURL
{
    NSString *backFieldURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        backFieldURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        backFieldURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],BackToFieldSubURL];
    }
    //
    return backFieldURL;
}

+ (NSString *)getDecideCreateGrpAndDownFieldURL
{
    NSString *decideCreateGrpAndDownURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        decideCreateGrpAndDownURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        decideCreateGrpAndDownURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],DecideCreateGrpAndDownFieldSubURL];
    }
    //
    return decideCreateGrpAndDownURL;
}

+ (NSString *)getLogOutURL
{
    NSString *logOutURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        logOutURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        logOutURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],LogOutSubURL];
    }
    //
    return logOutURL;
}

+ (NSString *)getChangeCaddyURL
{
    NSString *changeCaddyURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        changeCaddyURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        changeCaddyURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],ChangeCaddySubURL];
    }
    //
    return changeCaddyURL;
}

+ (NSString *)getChangeCartURL
{
    NSString *changeCartURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        changeCartURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        changeCartURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],ChangeCartSubURL];
    }
    //
    return changeCartURL;
}

+ (NSString *)getPlayProcessURL
{
    NSString *playProcessURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        playProcessURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        playProcessURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],PlayProcessSubURL];
    }
    //
    return playProcessURL;
}

+ (NSString *)getRequestLeaveTimeURL
{
    NSString *leaveTimeURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        leaveTimeURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        leaveTimeURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],RequestLeaveTimeSubURL];
    }
    //
    return leaveTimeURL;
}

+ (NSString *)getRequestMsgHistoryURL
{
    NSString *msgHistoryURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        msgHistoryURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        msgHistoryURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],RequestMsgHistorySubURL];
    }
    //
    return msgHistoryURL;
}

+ (NSString *)getRequestSendMsgURL
{
    NSString *sendMsgURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        sendMsgURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        sendMsgURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],RequestSendMsgSubURL];
    }
    //
    return sendMsgURL;
}

+ (NSString *)getRequestAddDeviceURL
{
    NSString *addDeviceURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        addDeviceURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        addDeviceURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],RequestAddDeviceSubURL];
    }
    //
    return addDeviceURL;
}

+ (NSString *)getMakeHoleCompleteStateURL
{
    NSString *completeStateURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        completeStateURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        completeStateURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],MakeHoleCompleteStateSubURL];
    }
    //
    return completeStateURL;
}

+ (NSString *)getGetNeedMendHoleURL
{
    NSString *needMendHoleURL;
    //
    DataTable *theStoredData = [[DataTable alloc] init];
    theStoredData = [GetRequestIPAddress getStoredData];
    if (![theStoredData.Rows count]) {
        needMendHoleURL = @"";
    }//(interval text,ipAddr text,portNum text)
    else
    {
        needMendHoleURL = [NSString stringWithFormat:@"http://%@:%@%@",theStoredData.Rows[0][@"ipAddr"],theStoredData.Rows[0][@"portNum"],MakeHoleCompleteStateSubURL];
    }
    //
    return needMendHoleURL;
}


@end
