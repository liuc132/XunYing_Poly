//
//  GetGPSLocationData.h
//  XunYing_Golf
//
//  Created by LiuC on 15/11/3.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GetGPSLocationData : NSObject

-(void)initGPSLocation;

-(CLLocation *)getCurLocation;
- (void)stopUpdateLocation;



@end
