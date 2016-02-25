//
//  LogFilesProcess.h
//  XunYing_Golf
//
//  Created by LiuC on 16/2/25.
//  Copyright © 2016年 LiuC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogFilesProcess : NSObject


+ (void)redirectNSLogToDocument;
+ (void)createZipFile;
+ (void)sendTheZipLogFile;

@end
