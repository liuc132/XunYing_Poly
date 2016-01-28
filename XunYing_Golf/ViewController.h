//
//  ViewController.h
//  XunYing_Golf
//
//  Created by LiuC on 15/8/27.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface ViewController : UIViewController<AGSMapViewLayerDelegate,AGSFeatureLayerQueryDelegate,AGSMapViewTouchDelegate>

@property (strong, nonatomic) IBOutlet AGSMapView *mapView;

@property (strong, nonatomic) AGSPoint *GpsPoint;
@property (nonatomic) BOOL  confirmGetGPS;

@end

