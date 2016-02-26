//
//  LogFilesProcess.m
//  XunYing_Golf
//
//  Created by LiuC on 16/2/25.
//  Copyright © 2016年 LiuC. All rights reserved.
//

#import "LogFilesProcess.h"
#import "GetRequestIPAddress.h"
#import "SSZipArchive.h"
#import "HttpTools.h"
#import "GetRequestIPAddress.h"
#import "AFNetworkTool.h"
#import "AFURLRequestSerialization.h"

@implementation LogFilesProcess


+ (void)redirectNSLogToDocument
{
    NSString *filePath;
    
    filePath = [LogFilesProcess getLogFilePath];
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:filePath error:nil];
    
    // 将log输入到文件
    freopen([filePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([filePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

+ (NSString *)getZipFilePath
{
    NSString *zipFilePath;
    //
    NSString *theZipFileName;//以当前时间以及uuid的号码组成
    
    theZipFileName = [NSString stringWithFormat:@"%@",[LogFilesProcess getLogFileName]];
    //
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.zip",theZipFileName];
    //get the path
    zipFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    return zipFilePath;
}

+ (NSString *)getLogFilePath
{
    NSString *logFilePath;
    //
    NSString *theLogFileName;//以当前时间以及uuid的号码组成
    
    theLogFileName = [NSString stringWithFormat:@"%@",[LogFilesProcess getLogFileName]];
    //
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.log",theLogFileName];
    //get the path
    logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    return logFilePath;
}

+ (NSString *)getLogFileName
{
    NSString *logFileName;
    
    //
    NSString *UUIDStr;
    UUIDStr = [NSString stringWithFormat:@"%@",[GetRequestIPAddress getUniqueID]];
    //获取到当前系统的时间，并生成相应的格式
    NSDateFormatter *dateFarmatter = [[NSDateFormatter alloc] init];
    [dateFarmatter setDateFormat:@"yyyy-MM-dd"];
    NSString *curDateTime = [dateFarmatter stringFromDate:[NSDate date]];
    //
    logFileName = [NSString stringWithFormat:@"LOG%@%@",curDateTime,UUIDStr];
    return logFileName;
}

+ (void)createZipFile
{
    NSString *zipFilePath;
    NSString *logFilePath;
    NSMutableArray *paths = [NSMutableArray array];
    
    zipFilePath = [LogFilesProcess getZipFilePath];
    logFilePath = [LogFilesProcess getLogFilePath];
    
    [paths addObject:logFilePath];
    //创建zip文件
    [SSZipArchive createZipFileAtPath:zipFilePath withFilesAtPaths:paths];
    
}

+ (void)sendTheZipLogFile
{
    __block NSString *updateLogURLStr;
    __block NSString *zipFilePath;
    __block NSURL *logZipURL;
    //添加压缩文件
    [LogFilesProcess createZipFile];
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        //获取到压缩文件的路径
        zipFilePath = [LogFilesProcess getZipFilePath];
        
        logZipURL = [NSURL URLWithString:zipFilePath];
        
        updateLogURLStr = [GetRequestIPAddress getLogUpdateURL];
        
        NSString *updateName;
        updateName = [NSString stringWithFormat:@"%@.zip",[LogFilesProcess getLogFileName]];
        
//        NSFileManager *defaultManager = [NSFileManager defaultManager];
        id<AFMultipartFormData> formdata;
        
        [formdata appendPartWithFileURL:logZipURL name:@"ins" error:nil];
//        
        NSMutableDictionary *updateLogParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:updateName,@"insFile Name",formdata,@"ins", nil];
        
        [HttpTools getHttp:updateLogURLStr forParams:updateLogParam success:^(NSData *nsData) {
            NSLog(@"success");
            
            
        } failure:^(NSError *err) {
            NSLog(@"fail");
            
            
        }];
        
//        NSFileManager *fm = [NSFileManager defaultManager];
//        NSArray *arr = [fm contentsOfDirectoryAtPath:zipFilePath error:nil];
        
        NSURL *filePath
        
        
//        NSLog(@"");
        
//        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@.zip",[LogFilesProcess getLogFileName]] withExtension:nil];
//        
//        NSLog(@"%@",fileURL);
        
        
        
        [AFNetworkTool postUploadWithUrl:updateLogURLStr fileUrl:logZipURL success:^(id responseObject) {
            
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            NSLog(@"");
            
            
        } fail:^{
            NSLog(@"upload logzipfile fail");
            
            
        }];
    });
    
}




@end
