//
//  GetGPSLocationData.m
//  XunYing_Golf
//
//  Created by LiuC on 15/11/3.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "GetGPSLocationData.h"
#import <UIKit/UIKit.h>


@interface GetGPSLocationData ()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *getGPSLocation;


@end

@implementation GetGPSLocationData

-(void)initGPSLocation
{
    //GPS初始化
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //    self.locationManager.allowsBackgroundLocationUpdates = YES;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
    {
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
            NSLog(@"ENTER requestAlwaysAuthorization");
        }
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9)
    {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    if([CLLocationManager significantLocationChangeMonitoringAvailable] == YES)
    {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    
    [self.locationManager startUpdatingLocation];
}

//- (void)startMonitoringSignificantLocationChanges
//{
//    if(nil == self.locationManager)
//        self.locationManager = [[CLLocationManager alloc] init];
//    
//    self.locationManager.delegate = self;
//    
//}

-(CLLocation *)getCurLocation
{
    CLLocation *curLocation;
    
    //在此选择是传输实际的GPS数据还是模拟的数据
    curLocation = self.getGPSLocation;
    
    return curLocation;
}

#pragma -mark  didUpdateLocations
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    self.getGPSLocation = [locations lastObject];
}

- (void)stopUpdateLocation
{
    [self.locationManager stopUpdatingLocation];
}

@end
