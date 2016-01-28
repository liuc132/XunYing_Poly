//
//  HeartBeatAndDetectState.h
//  XunYing_Golf
//
//  Created by LiuC on 15/10/14.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//BOOL successSendHeart;

@interface HeartBeatAndDetectState : NSObject


@property (nonatomic) BOOL allowDown;
@property (strong, nonatomic) NSString *allowDownStr;
@property (strong, nonatomic) NSString *waitToAllow;
@property (strong, nonatomic) NSString *haveDetectedDownEnable;
@property (strong, nonatomic) NSMutableDictionary *finalDic;

//初始化处理
-(void)initHeartBeat;
//开启心跳服务
-(void)enableHeartBeat;
//关闭心跳服务
+(void)disableHeartBeat;
//心跳主程序
//+(void)timelySend;
//检测状态
-(BOOL)checkState;

//-(void)requestHeartSuccess:(void (^)(BOOL reqSuccess))success;


@end
