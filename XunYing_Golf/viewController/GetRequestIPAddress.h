//
//  GetRequestIPAddress.h
//  XunYing_Golf
//
//  Created by LiuC on 16/1/5.
//  Copyright © 2016年 LiuC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetRequestIPAddress : NSObject

+ (NSString *)getUniqueID;
+ (NSString *)getIntervalTime;
+ (NSString *)getServerURL;
+ (NSString *)getHeartBeatURL;
+ (NSString *)getLogInURL;
+ (NSString *)getJumpHoleURL;
+ (NSString *)getMendHoleURL;
+ (NSString *)getCaddyCartInfURL;
+ (NSString *)getCustomInfURL;
+ (NSString *)getcreateGroupURL;
+ (NSString *)getCancleWaitingGroupURL;
+ (NSString *)getBackToFieldURL;
+ (NSString *)getDecideCreateGrpAndDownFieldURL;
+ (NSString *)getLogOutURL;
+ (NSString *)getChangeCaddyURL;
+ (NSString *)getChangeCartURL;
+ (NSString *)getPlayProcessURL;
+ (NSString *)getRequestLeaveTimeURL;
+ (NSString *)getRequestMsgHistoryURL;
+ (NSString *)getRequestSendMsgURL;
+ (NSString *)getRequestAddDeviceURL;
+ (NSString *)getMakeHoleCompleteStateURL;
+ (NSString *)getGetNeedMendHoleURL;



@end
