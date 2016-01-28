//
//  ViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/8/27.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "XunYingPre.h"


#define CLIENT_ID   @"gKbc4lH2K27McsAe"


typedef struct GPSInf{
    double latitude;
    double longtitude;
    double altitude;
}GPSPoint;

GPSPoint currentGPS;

@interface ViewController ()<AGSQueryTaskDelegate,AGSLayerDelegate,AGSCalloutDelegate>


- (IBAction)switchMapFunction:(UISegmentedControl *)sender;
@property (strong, nonatomic) IBOutlet UIView *chooseHoleView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchMapFunView;
- (IBAction)showCurLocation:(UIButton *)sender;





@property(strong, nonatomic) AGSGDBFeatureTable     *localFeatureTable;
@property(strong, nonatomic) AGSFeatureTableLayer   *localFeatureTableLayer;
@property(strong, nonatomic) AGSGDBFeatureTable     *localHoleFeatureTable;
@property(strong, nonatomic) AGSFeatureTableLayer   *localHoleFeatureTableLayer;
@property(strong, nonatomic) AGSGraphicsLayer       *graphicLayer;
@property(strong, nonatomic) AGSSymbol              *gpsSymbol;
@property(strong, nonatomic) AGSMapViewBase         *mapViewBase;
//the sketch layer used to draw the gps track
@property (nonatomic, strong) AGSSketchGraphicsLayer *gpsSketchLayer;

@property(strong, nonatomic) AGSMutablePolyline     *route;

//location
//@property(strong, nonatomic) CLLocationManager *locationManager;

@property(strong, nonatomic) AGSLocator *locator;

//heartBeat
@property(strong, nonatomic) NSTimer *heartBeat;

@property (strong, nonatomic) AGSQuery *query;
@property (strong, nonatomic) AGSQueryTask *queryTask;
@property (strong, nonatomic) AGSLocationDisplay *locationDis;

@property (strong, nonatomic) AGSGeometryEngine *geometryEngineLocal;
@property (strong, nonatomic) AGSPoint          *startPoint;


- (IBAction)whichButton:(UIButton *)sender;



@end

@implementation ViewController
FixedPoint gpsScreenPoint;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    __weak typeof(self) weakSelf = self;
    
    
    NSError *error;
    [AGSRuntimeEnvironment setClientID:CLIENT_ID error:&error];
    if(error){
        NSLog(@"Error using client ID:%@",[error localizedDescription]);
    }
    //enable standard level functionality in your app using your license code 这句话是将eris的logo给去掉
    AGSLicenseResult result = [[AGSRuntimeEnvironment license] setLicenseCode:@"runtimestandard,101,rux00000,none,gKbc4lH2K27McsAe"];
    NSLog(@"%ld",(long)result);
    
    
    //add tiled layer  step1
    NSString *path = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapData.bundle/xunying.tpk"];
    AGSLocalTiledLayer *layer = [AGSLocalTiledLayer localTiledLayerWithPath:path];
    //如果层被合适的初始化了之后，添加到地图
    if(layer != nil && !layer.error)
    {
        [self.mapView addMapLayer:layer withName:@"Local Tiled Layer"];
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"could not load tile package" message:[layer.error localizedDescription] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil]show];
        
    }
    
//    NSURL *mapUrl = [NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
//    AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
//    [self.mapView addMapLayer:tiledLyr withName:@"Tiled Layer"];
//    
//    //Zooming to an initial envelope with the specified spatial reference of the map.
//    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:102100];
//    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-13639984
//                                                ymin:4537387
//                                                xmax:-13606734
//                                                ymax:4558866
//                                    spatialReference:sr];
//    [self.mapView zoomToEnvelope:env animated:YES];
    
//    Zooming to an initial envelope with the specified spatial reference of the map. 上邦地图范围
//    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:3857];
//    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:11830220.9410906
//                                                ymin:3439691.60124628
//                                                xmax:11832488.6845279
//                                                ymax:3438114.33915628
//                                    spatialReference:sr];
//    
//    
//    [self.mapView zoomToEnvelope:env animated:YES];
    
    //测试场地之花卉园地图范围
    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:3857];
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:11856404.596390
                                                ymin:3450433.501542
                                                xmax:11856986.392327
                                                ymax:3450038.812739
                                    spatialReference:sr];
    
    
    [self.mapView zoomToEnvelope:env animated:YES];
//    //xunying_hole.geodatabase
    NSError *hole_error;
    NSString *holePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapData.bundle/xunying_hole.geodatabase"];
    AGSGDBGeodatabase *gdbXunyinHole = [AGSGDBGeodatabase geodatabaseWithPath:holePath error:&hole_error];
    if(hole_error){
        NSLog(@"fail to open xunying_hole.geodatabase");
    }
    else{
        self.localHoleFeatureTable = [[gdbXunyinHole featureTables] objectAtIndex:0];
        self.localHoleFeatureTableLayer = [[AGSFeatureTableLayer alloc] initWithFeatureTable:self.localHoleFeatureTable];
        self.localHoleFeatureTableLayer.delegate = self;
        [self.mapView addMapLayer:self.localHoleFeatureTableLayer withName:@"Hole Feature Layer"];
    }
    //xunying.geodatabase
    NSError *xunyingError;
    NSString *xunyingPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapData.bundle/xunying.geodatabase"];
    AGSGDBGeodatabase *gdb_xunying = [[AGSGDBGeodatabase alloc]initWithPath:xunyingPath error:&xunyingError];
    //
    if(xunyingError)
    {
        NSLog(@"open xunying.geodatabase error:%@",[xunyingError localizedDescription]);
    }
    else{
        //NSLog(@"open the geodatabase successfully");
        self.localFeatureTable = [[gdb_xunying featureTables] objectAtIndex:0];
        self.localFeatureTableLayer = [[AGSFeatureTableLayer alloc]initWithFeatureTable:self.localFeatureTable];
        self.localFeatureTableLayer.delegate = self;
        self.localFeatureTableLayer.opacity = 1;
        
        [self.mapView addMapLayer:self.localFeatureTableLayer withName:@"Xunying Fearue Layer"];
    }
    //add graphicLayer
    self.graphicLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.graphicLayer withName:@"graphic Layer"];
    
    self.queryTask = [[AGSQueryTask alloc] init];
    self.queryTask.delegate = self;
    
    self.confirmGetGPS = YES;
    //
    self.mapView.touchDelegate = self;
    //
    
    //地图中的当前GPS定位点的位置信息点的显示
    [self.mapView.locationDisplay addObserver:self forKeyPath:@"autoPanMode" options:(NSKeyValueObservingOptionNew) context:NULL];
    //Listen to KVO notifications for map scale property
    [self.mapView addObserver:self
                   forKeyPath:@"location"
                      options:(NSKeyValueObservingOptionNew)
                      context:NULL];
    
    //callout的代理设置
    self.mapView.callout.delegate = self;
    //
    self.geometryEngineLocal = [[AGSGeometryEngine alloc] init];
    //
    //set the layer delegate to self to check when the layers are loaded. Required to start the gps.
    self.mapView.layerDelegate = self;
    
    //preparing the gps sketch layer.
    self.gpsSketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];
    [self.mapView addMapLayer:self.gpsSketchLayer withName:@"Sketch layer"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ForceBackField:) name:@"forceBackField" object:nil];
    
}

- (void)ForceBackField:(NSNotification *)sender
{
    __weak typeof(self) weakSelf = self;
    if ([sender.userInfo[@"forceBack"] isEqualToString:@"1"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *serverForceBackAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的小组已回场" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [serverForceBackAlert show];
            
            [weakSelf performSegueWithIdentifier:@"serVerBackField" sender:nil];
        });
        
        
    }
}


//
-(BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint
{
    NSDictionary *featureAttr = [feature allAttributes];
    //先判断，是否是点击到了球洞中的相应要素
    if(featureAttr[@"leixing"])
    {
        AGSSimpleFillSymbol *fillSymbol = [[AGSSimpleFillSymbol alloc] initWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.15] outlineColor:[UIColor blackColor]];
        AGSGraphic *leixingGraphic = [[AGSGraphic alloc] initWithGeometry:featureAttr[@"Shape"] symbol:fillSymbol attributes:nil];
        [self.graphicLayer addGraphic:leixingGraphic];
        
        //clear the custom view
        self.mapView.callout.customView = nil;
        //give related data
        self.mapView.callout.title = [NSString stringWithFormat:@"%@%@%@",featureAttr[@"QCM"],@"号",featureAttr[@"leixing"]];
        
        self.mapView.callout.accessoryButtonHidden = YES;
        
        return YES;
    }
    return NO;
}
//
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    if(self.mapView.locationDisplay.autoPanMode == AGSLocationDisplayAutoPanModeOff || self.mapView.locationDisplay.autoPanMode == AGSLocationDisplayAutoPanModeDefault){
        [self.mapView setRotationAngle:0 animated:YES];
    }
    //
    if([keyPath isEqual:@"location"]){
        NSLog(@"curLocation:%@",[self.mapView.locationDisplay mapLocation]);
    }
    //
    if([keyPath isEqual:@"mapScale"]){
        if(self.mapView.mapScale < 5000) {
            [self.mapView zoomToScale:50000 withCenterPoint:nil animated:YES];
            [self.mapView removeObserver:self forKeyPath:@"mapScale"];
        }
    }
}
//
-(BOOL)mapView:(AGSMapView *)mapView shouldProcessClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    [self.graphicLayer removeAllGraphics];
//    AGSSimpleMarkerSymbol *markSymbol = [[AGSSimpleMarkerSymbol alloc] initWithColor:[UIColor redColor]];
    //
//    AGSSimpleLineSymbol *simpleLineSymbol = [[AGSSimpleLineSymbol alloc] initWithColor:[UIColor blueColor] width:1.0f];
    //添加标记点
    /*
    AGSGraphic *myLineSymbol = [[AGSGraphic alloc] initWithGeometry:mappoint symbol:markSymbol attributes:nil];
    AGSGraphic *myStartSymbol = [[AGSGraphic alloc] initWithGeometry:self.startPoint symbol:markSymbol attributes:nil];
    [self.graphicLayer addGraphic:myLineSymbol];
    [self.graphicLayer addGraphic:myStartSymbol];
     */
//    NSLog(@"enter showProcessClickAtPoint");
    NSLog(@"currentLocation,altitude:%f;latitude:%f;longtitude:%f",currentGPS.altitude,currentGPS.latitude,currentGPS.longtitude);
    
    NSLog(@"mappoint  latitude:%f,longitude:%f",mappoint.x,mappoint.y);
    
    AGSPoint *gpsPoint = [[AGSPoint alloc]initWithX:currentGPS.latitude y:currentGPS.longtitude spatialReference:[AGSSpatialReference wgs84SpatialReference]];
//    AGSPoint *gpsPoint = [[AGSPoint alloc]initWithX:mappoint.x y:mappoint.y spatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    NSLog(@"gpsPoint latitude:%f,longitude:%f",gpsPoint.x,gpsPoint.y);
    
    //print current location
    NSLog(@"curLocation:%@",[self.mapView.locationDisplay mapLocation]);
    
//    AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    //如下是手动测距的方法，不过还得继续优化，添加两点之间的连接线，同时标记起点，终点以及把几个点击点给连接起来
    if(self.startPoint)
    {
        NSLog(@"distance:%f",[self.geometryEngineLocal distanceFromGeometry:self.startPoint toGeometry:mappoint]);
        NSLog(@"startPoint:%@",self.startPoint);
    }
    else{
        self.startPoint = mappoint;
        
    }
    __weak ViewController *weakSelf = self;
    //test query function  从第376行到392行是查询相应的障碍物，并测试了相应的两个障碍物之间的距离，同时如果想要查询一个定位点则通过[self.mapView.locationDisplay mappoint]获取到，在通过组装成AGSGeometry类型，再通过测距（相应的方法是：- (double)distanceFromGeometry:(AGSGeometry *)geometry1 toGeometry:(AGSGeometry *)geometry2）来得到距离结果！
    self.query.whereClause = @"QCM = '7'";
    [self.localFeatureTable queryResultsWithParameters:self.query completion:^(NSArray *results, NSError *err){
//        NSLog(@"results:%@ and count:%lu",results,(unsigned long)[results count]);
        static unsigned char totalCount;
        if(totalCount < [results count])
            totalCount++;
        else
            totalCount = 0;
        AGSGDBFeature *featureLoc = results[0];
        AGSGDBFeature *featureLoc1  = results[totalCount];
        NSLog(@"featureLoc:%@ and totalCount:%d",featureLoc1,totalCount);
        AGSGeometry *geometry1 = [featureLoc geometry];
        AGSGeometry *geometry2 = [featureLoc1 geometry];
        
//        [self.geometryEngineLocal distanceFromGeometry:geometry1 toGeometry:geometry2];
        NSLog(@"the distance is :%f",[weakSelf.geometryEngineLocal distanceFromGeometry:geometry1 toGeometry:geometry2]);
        NSLog(@"finish measuring the distance");
        
    }];
    
    
    
    return YES;
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return (UIInterfaceOrientationLandscapeRight);
}

#pragma -mark orientation
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma -mark prefersStatus
-(BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma -mark GPS_viewDidAppear
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.locationManager stopUpdatingLocation];
}
#pragma -mark GPS_viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    self.navigationController.navigationBarHidden = YES;
}
#pragma -mark mapViewDidLoad
/**
 *  mapViewDidLoad
 *
 *  @param mapView current mapView
 */
-(void)mapViewDidLoad:(AGSMapView *)mapView
{
    [self.mapView.locationDisplay startDataSource];
    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    self.mapView.locationDisplay.wanderExtentFactor = 0.75;
    //setting the geometry of the gps sketch layer to polyline.
    self.gpsSketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
    
    //set the midvertex symbol to nil to avoid the default circle symbol appearing in between vertices
    self.gpsSketchLayer.midVertexSymbol = nil;
    
}
#pragma -mark switchMapFunction
- (IBAction)switchMapFunction:(UISegmentedControl *)sender {
    NSLog(@"segment's index:%ld",(long)sender.selectedSegmentIndex);
    NSInteger index = sender.selectedSegmentIndex;
    sender.selected = NO;
    switch (index) {
        case 0: //自动测距
            
            break;
            //
        case 1: //选择球洞
            //此处加载选择球洞的视图
            [self.chooseHoleView setFrame:CGRectMake(10, self.navView.frame.size.height+80, ScreenWidth-20, self.chooseHoleView.frame.size.height)];
            [self.view addSubview:self.chooseHoleView];
            
            break;
            //
        case 2: //手动测距
            
            break;
        default:
            break;
    }
    
}

- (IBAction)whichButton:(UIButton *)sender {
    [self.chooseHoleView removeFromSuperview];
//    NSLog(@"curButton:%ld",[sender.titleLabel.text integerValue]);
    //
    [self.graphicLayer removeAllGraphics];
    //construct query SQL
    __block NSString *querySQL;
    querySQL = [NSString stringWithFormat:@"QCM = '%ld'",[sender.titleLabel.text integerValue]];
    //测试状态
    querySQL = [NSString stringWithFormat:@"QCM"];
    //
    self.query = [AGSQuery query];
    self.query.whereClause = querySQL;
    //
    __block NSDictionary *curDic = [[NSDictionary alloc] init];
    __weak ViewController *weakSelf = self;
    [self.localHoleFeatureTable queryResultsWithParameters:self.query completion:^(NSArray *results, NSError *error){
        if ([sender.titleLabel.text integerValue] > [results count]) {
            UIAlertView *errAlert = [[UIAlertView alloc] initWithTitle:@"当前球场无此球洞" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [errAlert show];
            return;
        }
        querySQL = [NSString stringWithFormat:@"QCM = '%ld'",[sender.titleLabel.text integerValue]];
        weakSelf.query.whereClause = querySQL;
        //
        [weakSelf.localHoleFeatureTable queryResultsWithParameters:self.query completion:^(NSArray *results, NSError *error){
            AGSGDBFeature *curFeatrue = results[0];
            curDic = [curFeatrue allAttributes];
            
            AGSSimpleFillSymbol *fillSymbolView = [[AGSSimpleFillSymbol alloc] initWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.15] outlineColor:[UIColor blueColor]];
            AGSGraphic *holeGraphic = [[AGSGraphic alloc] initWithGeometry:curDic[@"Shape"] symbol:fillSymbolView attributes:nil];
            [weakSelf.graphicLayer addGraphic:holeGraphic];
            
        }];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//构建模拟路径
-(void)constructPolyline
{
    //
    [self.route addPathToPolyline];
    //
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28256131500 y:29.49389984490 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28256669700 y:29.49432700910 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28281553500 y:29.49458953090 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28298506800 y:29.49505329810 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28341349200 y:29.49527828640 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28296532100 y:29.49592164420 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28253196400 y:29.49611735560 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28209158900 y:29.49624332170 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28165696300 y:29.49617591050 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28128793600 y:29.49595571510 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28105536100 y:29.49573897710 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28060691900 y:29.49565737550 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.28037981600 y:29.49538747980 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.27988107400 y:29.49521089300 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
    [self.route addPointToPath:[[AGSPoint alloc] initWithX:106.27950619300 y:29.49490423120 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:3857]]];
}

- (IBAction)showCurLocation:(UIButton *)sender {
    [self.mapView centerAtPoint:[self.mapView.locationDisplay mapLocation] animated:YES];
    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
}
@end
