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
@property (strong, nonatomic) CLLocation *storedGPSLocation;


@end

@implementation GetGPSLocationData

-(void)initGPSLocation
{
    //GPS初始化
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        self.locationManager.allowsBackgroundLocationUpdates = YES;
    
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
    
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请开启定位允许" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    
    [_locationManager startUpdatingLocation];
    //在此选择是传输实际的GPS数据还是模拟的数据
    if (_storedGPSLocation != _getGPSLocation) {
        _storedGPSLocation = _getGPSLocation;
    }
    
    curLocation = _storedGPSLocation;
    
    return curLocation;
}

#pragma -mark  didUpdateLocations
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //    _getGPSLocation = [locations lastObject];
    
    CLLocation *cacheLocation = [locations lastObject];
    NSDate *eventDate = cacheLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 1.0) {
        //if the event is recent,do something with it.
        _getGPSLocation = cacheLocation;
        
        [_locationManager stopUpdatingLocation];
    }
    
}

- (void)stopUpdateLocation
{
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    
    NSLog(@"error:%@",error.localizedDescription);
    
}



@end
