//
//  BLMessageProvider.h
//  BackgroundLocation
//
//  Created by Nick Martin on 10/1/14.
//  Copyright (c) 2014 BuggyList. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLMessageProvider : NSObject
+(instancetype)sharedProvider;
-(void)sendLocation:(NSString *)longitude
           latitude:(NSString *)latitude
   applicationState:(NSString *)state;
@end
