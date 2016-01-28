//
//  HttpTools.h
//
//  http协议工具类
//
//  返回值及同步异步的封装(编码为UTF8)
//
//  Created by 周杨 on 14/12/21.
//  Copyright (c) 2014年 zhouy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpTools : NSObject

/**
 *  Description 得到HTTP协议返回 NSData对象 (同步方法)
 *
 *  @param url  http地址
 *  @param params 参数键值,可以为nil
 *
 *  @return NSData对象
 */
+(NSData *) getNSDataHttp:(NSString *) url forParams:(NSMutableDictionary *) params;

/**
 *  Description 得到HTTP协议返回 NSData对象 (同步方法)
 *
 *  @param url  http地址
 *  @param params 参数键值,可以为nil
 *
 *  @return NSData对象
 */
+(NSString *) getStringHttp:(NSString *) url forParams:(NSMutableDictionary *) params;

/**
 *  Description 得到HTTP协议返回 Json对象 (同步方法)
 *
 *  @param url  http地址
 *  @param params 参数键值,可以为nil
 *
 *  @return NSDictionary对象
 */
+(NSDictionary *) getJsonHttp:(NSString *) url forParams:(NSMutableDictionary *) params;

/**
 *  Description 得到HTTP协议返回 Plist对象 (同步方法)
 *
 *  @param url  http地址
 *  @param params 参数键值,可以为nil
 *
 *  @return NSDictionary对象
 */
+(NSDictionary *) getPlistHttp:(NSString *) url forParams:(NSMutableDictionary *) params;


/**
 *  <#Description#>得到HTTP协议返回 NSData对象 (异步方法)
 *
 *  @param url     http地址
 *  @param params  参数键值,可以为nil
 *  @param success 成功事件回调
 *  @param failure 失败事件回调
 *
 */
+(void ) getHttp:(NSString *) url forParams:(NSMutableDictionary *) params success:(void (^)(NSData * nsData)) success failure:(void (^)(NSError * err)) failure;

@end
