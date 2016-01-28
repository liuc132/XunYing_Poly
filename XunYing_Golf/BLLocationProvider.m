//
//  BLLocationProvider.m
//  BackgroundLocation
//
//  Created by Nick Martin on 10/4/14.
//  Copyright (c) 2014 BuggyList. All rights reserved.
//

#import "BLLocationProvider.h"
#import "BLMessageProvider.h"

@interface BLLocationProvider()
@property(nonatomic,strong)id <LocationProviderDelegate> locationDelegate;
@end

@implementation BLLocationProvider
-(instancetype)initWithDelegate:(id <LocationProviderDelegate>)delegate;
{
    self = [super init];
    if (self) {
        self.locationDelegate = delegate;
    }
    return self;
}

-(void)getLocation{
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocation Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.locationDelegate error:error];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    
        // If the event is recent, do something with it.
        NSString *logitude = [NSString stringWithFormat:@"%+.6f", location.coordinate.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%+.6f", location.coordinate.latitude];
        [self.locationDelegate locationUpdatedWith:logitude andLatitude:latitude];
        [manager stopUpdatingLocation];
        
    
}

@end
