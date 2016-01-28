//
//  BLLocationProvider.h
//  BackgroundLocation
//
//  Created by Nick Martin on 10/4/14.
//  Copyright (c) 2014 BuggyList. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationProviderDelegate <NSObject>
    -(void)locationUpdatedWith:(NSString *)longitude andLatitude:(NSString *)latitude;
    -(void)error:(NSError *)error;
@end

@interface BLLocationProvider : NSObject<CLLocationManagerDelegate>
    @property(nonatomic, strong)CLLocationManager *locationManager;
    -(instancetype)initWithDelegate:(id <LocationProviderDelegate>)delegate;
    -(void)getLocation;
@end
