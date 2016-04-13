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
#import "DBCon.h"
#import "DataTable.h"


#define CLIENT_ID   @"gKbc4lH2K27McsAe"


typedef struct GPSInf{
    double latitude;
    double longtitude;
    double altitude;
}GPSPoint;

GPSPoint currentGPS;

@interface ViewController ()<AGSQueryTaskDelegate,AGSLayerDelegate,AGSCalloutDelegate,UIActionSheetDelegate,AGSLayerCalloutDelegate>


- (IBAction)switchMapFunction:(UISegmentedControl *)sender;
@property (strong, nonatomic) IBOutlet UIView *chooseHoleView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchMapFunView;
- (IBAction)showCurLocation:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet AGSMapView *mapView;



@property(strong, nonatomic) AGSLocalTiledLayer     *backGroundLayer;
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

@property(strong, nonatomic) AGSGraphic             *mapGraphic;

@property(strong, nonatomic) AGSSketchGraphicsLayer *sketchLayer;

//location
//@property(strong, nonatomic) CLLocationManager *locationManager;

@property(strong, nonatomic) AGSLocator *locator;

@property (strong, nonatomic) AGSQuery *query;
@property (strong, nonatomic) AGSQueryTask *queryTask;
@property (strong, nonatomic) AGSLocationDisplay *locationDis;

@property (strong, nonatomic) AGSGeometryEngine *geometryEngineLocal;
@property (strong, nonatomic) AGSPoint          *startPoint;
//
@property (assign, nonatomic) NSInteger         theCourseIndex;
@property (strong, nonatomic) DBCon             *mapDbCon;
@property (strong, nonatomic) DataTable         *groInfo;
@property (strong, nonatomic) NSString          *curCourseTag;


@property (strong, nonatomic) AGSMutablePolyline *mutablePolyLine;

@property (strong, nonatomic) NSMutableArray     *tapPointArray;
@property (strong, nonatomic) NSMutableArray     *midPointArray;


@property (assign, nonatomic) BOOL               autoCalculateDistanceEnable;


- (IBAction)whichButton:(UIButton *)sender;



@end

@implementation ViewController
FixedPoint gpsScreenPoint;

/*
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
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.//
    NSError *error;
    [AGSRuntimeEnvironment setClientID:CLIENT_ID error:&error];
    if(error){
        NSLog(@"Error using client ID:%@",[error localizedDescription]);
    }
    //enable standard level functionality in your app using your license code 这句话是将eris的logo给去掉
    AGSLicenseResult result = [[AGSRuntimeEnvironment license] setLicenseCode:@"runtimestandard,101,rux00000,none,gKbc4lH2K27McsAe"];
    NSLog(@"%ld",(long)result);
    //
    self.mapDbCon = [[DBCon alloc] init];
    self.groInfo  = [[DataTable alloc] init];
    //
    self.groInfo = [self.mapDbCon ExecDataTable:@"select *from tbl_groupHeartInf"];
    
    
    if ([self.groInfo.Rows count]) {
        self.curCourseTag = self.groInfo.Rows[0][@"coursegrouptag"];
    }
    else
        self.curCourseTag = @"north";
    //
    //判断
    if ([self.curCourseTag isEqualToString:@"north"]) {
        self.theCourseIndex = 0;
    }
    else if ([self.curCourseTag isEqualToString:@"south"])
    {
        self.theCourseIndex = 1;
    }
    
    [self switchToCurCourse];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ForceBackField:) name:@"forceBackField" object:nil];
    //添加通知，接受心跳里边的相应的参数，进而来确定是否切换球场whetherCanSwitchCourse
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWhetherSwitchCourse:) name:@"whetherCanSwitchCourse" object:nil];
    //
    self.tapPointArray = [[NSMutableArray alloc] init];
    self.midPointArray = [[NSMutableArray alloc] init];
    //
    self.autoCalculateDistanceEnable = YES;
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

- (void)getWhetherSwitchCourse:(NSNotification *)sender
{
    self.curCourseTag = sender.userInfo[@"curCourseTag"];
    //判断
    if ([self.curCourseTag isEqualToString:@"north"]) {
        if (self.theCourseIndex == 0) {
            return;
        }
        self.theCourseIndex = 0;
    }
    else if ([self.curCourseTag isEqualToString:@"south"])
    {
        if (self.theCourseIndex ==1) {
            return;
        }
        self.theCourseIndex = 1;
    }
    //
    [self switchToCurCourse];
    
}

- (void)switchToCurCourse{
    [_mapView reset];
    //
    switch (self.theCourseIndex) {
        case 0://north
            //
            [self loadingNorthCourse];
            
            break;
            
        case 1://south
            //
            [self loadingSouthCourse];
            
            break;
            
        default:
            break;
    }
    //
    //地图中的当前GPS定位点的位置信息点的显示
    [_mapView.locationDisplay addObserver:self forKeyPath:@"autoPanMode" options:(NSKeyValueObservingOptionNew) context:NULL];
    //Listen to KVO notifications for map scale property
//    [_mapView addObserver:self forKeyPath:@"location" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    //callout的代理设置
    _mapView.callout.delegate = self;
    //
    self.geometryEngineLocal = [[AGSGeometryEngine alloc] init];
    //
    //set the layer delegate to self to check when the layers are loaded. Required to start the gps.
    _mapView.layerDelegate = self;
    
    _mapView.touchDelegate = self;
    
    //preparing the gps sketch layer.
    self.gpsSketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];
    [_mapView addMapLayer:self.gpsSketchLayer withName:@"Sketch layer"];
    
    self.sketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];
    [_mapView addMapLayer:self.sketchLayer withName:@"Sketch layer Distance"];
    
    //add graphicLayer
    self.graphicLayer = [AGSGraphicsLayer graphicsLayer];
    [_mapView addMapLayer:self.graphicLayer withName:@"graphic Layer"];
    
//    self.mutablePolyLine = [[AGSMutablePolyline alloc] initWithSpatialReference:_mapView.spatialReference];
//    
//    [self.mutablePolyLine addPathToPolyline];
    
    self.mapView.showMagnifierOnTapAndHold = YES;
    
    //we remove the previos part from the sketch layer as we are going to start a new GPS path.
//    [self.gpsSketchLayer removePartAtIndex:0];
    
    //add a new path to the geometry in preparation of adding vertices to the path
//    [self.gpsSketchLayer addPart];
    
//    self.gpsSketchLayer.calloutDelegate = self;
    
}

- (void)loadingNorthCourse
{
    //add tiled layer  step1
    NSString *path = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying.tpk"];//[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying.tpk"];
//    NSLog(@"backgroundlayer:%@",self.backGroundLayer);
    self.backGroundLayer = [AGSLocalTiledLayer localTiledLayerWithPath:path];
    //如果层被合适的初始化了之后，添加到地图
    if(self.backGroundLayer != nil && !self.backGroundLayer.error)
    {
//        NSLog(@"path:%@",[self.backGroundLayer cachePath]);
//        [self.mapView removeMapLayerWithName:@"Local Tiled Layer"];
        [_mapView addMapLayer:self.backGroundLayer withName:@"Local Tiled Layer"];
        
//        [self.mapView insertMapLayer:self.backGroundLayer withName:@"Local Tiled Layer" atIndex:0];
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"could not load tile package" message:[self.backGroundLayer.error localizedDescription] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil]show];
        
    }
    //南场地图范围
    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:3857];
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:11830339.77269565
                                                ymin:3438241.601529867
                                                xmax:11832598.78971369
                                                ymax:3439664.004374673
                                    spatialReference:sr];
    
    
    [_mapView zoomToEnvelope:env animated:YES];
    //
    NSError *hole_error;
    NSString *holePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying_hole.geodatabase"];//[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying_hole.geodatabase"];
    AGSGDBGeodatabase *gdbXunyinHole = [AGSGDBGeodatabase geodatabaseWithPath:holePath error:&hole_error];
    if(hole_error){
        NSLog(@"fail to open hole.geodatabase");
    }
    else{
        self.localHoleFeatureTable = [[gdbXunyinHole featureTables] objectAtIndex:0];
        self.localHoleFeatureTableLayer = [[AGSFeatureTableLayer alloc] initWithFeatureTable:self.localHoleFeatureTable];
        self.localHoleFeatureTableLayer.delegate = self;
        [_mapView addMapLayer:self.localHoleFeatureTableLayer withName:@"Hole Feature Layer"];
    }
    //xunying.geodatabase
    NSError *xunyingError;
    NSString *xunyingPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying.geodatabase"];//[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying.geodatabase"];
    AGSGDBGeodatabase *gdb_xunying = [[AGSGDBGeodatabase alloc]initWithPath:xunyingPath error:&xunyingError];
    //
    if(xunyingError)
    {
        NSLog(@"open elements.geodatabase error:%@",[xunyingError localizedDescription]);
    }
    else{
        //NSLog(@"open the geodatabase successfully");
        self.localFeatureTable = [[gdb_xunying featureTables] objectAtIndex:0];
        self.localFeatureTableLayer = [[AGSFeatureTableLayer alloc]initWithFeatureTable:self.localFeatureTable];
        self.localFeatureTableLayer.delegate = self;
        self.localFeatureTableLayer.opacity = 1;
        
        [_mapView addMapLayer:self.localFeatureTableLayer withName:@"Xunying Fearue Layer"];
    }
    
    
    self.queryTask = [[AGSQueryTask alloc] init];
    self.queryTask.delegate = self;
    
//    self.confirmGetGPS = YES;
    //
//    _mapView.touchDelegate = self;
}

- (void)loadingSouthCourse
{
    //add tiled layer  step1
    NSString *path = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying.tpk"];//[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying.tpk"];
    self.backGroundLayer = [AGSLocalTiledLayer localTiledLayerWithPath:path];
    //如果层被合适的初始化了之后，添加到地图
    if(self.backGroundLayer != nil && !self.backGroundLayer.error)
    {
        [_mapView addMapLayer:self.backGroundLayer withName:@"Local Tiled Layer"];
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"could not load tile package" message:[self.backGroundLayer.error localizedDescription] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil]show];
        
    }
    //南场地图范围
    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:3857];
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:11830339.77269565
                                                ymin:3438241.601529867
                                                xmax:11832598.78971369
                                                ymax:3439664.004374673
                                    spatialReference:sr];
    
    
    [_mapView zoomToEnvelope:env animated:YES];
    //
    NSError *hole_error;
    NSString *holePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying_hole.geodatabase"];//[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying_hole.geodatabase"];
    AGSGDBGeodatabase *gdbXunyinHole = [AGSGDBGeodatabase geodatabaseWithPath:holePath error:&hole_error];
    if(hole_error){
        NSLog(@"fail to open hole.geodatabase");
    }
    else{
        self.localHoleFeatureTable = [[gdbXunyinHole featureTables] objectAtIndex:0];
        self.localHoleFeatureTableLayer = [[AGSFeatureTableLayer alloc] initWithFeatureTable:self.localHoleFeatureTable];
        self.localHoleFeatureTableLayer.delegate = self;
        [_mapView addMapLayer:self.localHoleFeatureTableLayer withName:@"Hole Feature Layer"];
    }
    //xunying.geodatabase
    NSError *xunyingError;
    NSString *xunyingPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying.geodatabase"];//[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"offlineMapDataSK.bundle/xunying.geodatabase"];
    AGSGDBGeodatabase *gdb_xunying = [[AGSGDBGeodatabase alloc]initWithPath:xunyingPath error:&xunyingError];
    //
    if(xunyingError)
    {
        NSLog(@"open elements.geodatabase error:%@",[xunyingError localizedDescription]);
    }
    else{
        //NSLog(@"open the geodatabase successfully");
        self.localFeatureTable = [[gdb_xunying featureTables] objectAtIndex:0];
        self.localFeatureTableLayer = [[AGSFeatureTableLayer alloc]initWithFeatureTable:self.localFeatureTable];
        self.localFeatureTableLayer.delegate = self;
        self.localFeatureTableLayer.opacity = 1;
        
        [_mapView addMapLayer:self.localFeatureTableLayer withName:@"Xunying Fearue Layer"];
    }
    //add graphicLayer
    self.graphicLayer = [AGSGraphicsLayer graphicsLayer];
    [_mapView addMapLayer:self.graphicLayer withName:@"graphic Layer"];
    
    self.queryTask = [[AGSQueryTask alloc] init];
    self.queryTask.delegate = self;
    
//    self.confirmGetGPS = YES;
    //
//    _mapView.touchDelegate = self;
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
        _mapView.callout.customView = nil;
        //give related data
        _mapView.callout.title = [NSString stringWithFormat:@"%@%@%@",featureAttr[@"QCM"],@"号",featureAttr[@"leixing"]];
        
        _mapView.callout.accessoryButtonHidden = YES;   
        
        return YES;
    }
    
    return NO;
}
//
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    if(_mapView.locationDisplay.autoPanMode == AGSLocationDisplayAutoPanModeOff || _mapView.locationDisplay.autoPanMode == AGSLocationDisplayAutoPanModeDefault){
        [_mapView setRotationAngle:0 animated:YES];
    }
    //
    if([keyPath isEqual:@"location"]){
        NSLog(@"curLocation:%@",[_mapView.locationDisplay mapLocation]);
    }
    //
    if([keyPath isEqual:@"mapScale"]){
        if(_mapView.mapScale < 5000) {
            [_mapView zoomToScale:50000 withCenterPoint:nil animated:YES];
            [_mapView removeObserver:self forKeyPath:@"mapScale"];
        }
    }
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
//    __weak typeof(self) weakSelf = self;
    if (_autoCalculateDistanceEnable) {
        
        [_graphicLayer removeAllGraphics];
        
        for (id theLayer in self.mapView.mapLayers) {
            if ([theLayer isKindOfClass:[AGSSketchGraphicsLayer class]]) {
                [theLayer removeSelectedPart];
            }
            //
            if ([theLayer isKindOfClass:[AGSGraphicsLayer class]]) {
                [theLayer removeAllGraphics];
            }
            
        }
        
        //
        
        id<AGSFeature> theFeature;
        NSArray *theArray = (NSArray *)features[@"Hole Feature Layer"];
        theFeature = theArray[0];
        
        NSDictionary *theFeatureDic;// = [theFeature allAttributes];
        
        theFeatureDic = [theFeature allAttributes];
        
        __block NSString *querySQL;
        querySQL = [NSString stringWithFormat:@"QCM = '%ld' and leixing Not In ('发球台','果岭环','球道')",[theFeatureDic[@"QCM"] integerValue]];
        //
        self.query = [AGSQuery query];
        self.query.whereClause = querySQL;
        
        [self.localFeatureTable queryResultsWithParameters:self.query completion:^(NSArray *results, NSError *error) {
            
            NSLog(@"results:%@",results);
            for (AGSGDBFeature *curFeature in results) {
                NSDictionary *curDic = [curFeature allAttributes];
                
                AGSPoint *ObstaclePoint = [[AGSPoint alloc] initWithX:[curDic[@"X"] doubleValue] y:[curDic[@"Y"] doubleValue] spatialReference:self.mapView.spatialReference];
                //
                AGSSketchGraphicsLayer *localSketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:[[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference]];
                [_mapView addMapLayer:localSketchLayer withName:@"local Sketch layer"];
                //
                AGSGraphicsLayer *localgraphicLayer = [AGSGraphicsLayer graphicsLayer];
                [_mapView addMapLayer:localgraphicLayer withName:@"local graphic Layer"];
                
                localSketchLayer.midVertexSymbol = nil;
                //we remove the previos part from the sketch layer as we are going to start a new GPS path.
                [localSketchLayer removePartAtIndex:0];
                
                //add a new path to the geometry in preparation of adding vertices to the path
                [localSketchLayer addPart];
                
                [localSketchLayer insertVertex:mappoint inPart:0 atIndex:-1];
                
                [localSketchLayer insertVertex:ObstaclePoint inPart:0 atIndex:-1];
                
                AGSPoint *midPoint = [[AGSPoint alloc] initWithX:((mappoint.x + ObstaclePoint.x)/2) y:((mappoint.y + ObstaclePoint.y)/2) spatialReference:self.mapView.spatialReference];
                
                //
                NSLog(@"the distance:%.0f",[_geometryEngineLocal distanceFromGeometry:curDic[@"Shape"] toGeometry:mappoint]);
                
                NSString *distance = [NSString stringWithFormat:@"%.0f",[_geometryEngineLocal distanceFromGeometry:curDic[@"Shape"] toGeometry:mappoint]];
                
                AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
                // create outline
                AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbol];
                sls.color = [UIColor greenColor];
                sls.width = 2;
                sls.style=AGSSimpleLineSymbolStyleSolid;
                // create main circle
                AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
                sms.color = [UIColor whiteColor];
                sms.outline = sls;
                
                NSInteger strCount = [distance length];
                
                if (strCount <= 2) {
                    sms.size = CGSizeMake(20, 20);
                }
                if (strCount == 3) {
                    sms.size = CGSizeMake(25, 25);
                }
                else if(strCount >= 4)
                    sms.size = CGSizeMake(33, 33);
                
                
                sms.style=AGSSimpleMarkerSymbolStyleCircle;
                //create text to display the distance
                AGSTextSymbol *ts = [[AGSTextSymbol alloc] initWithText:[NSString stringWithFormat:@"%@",distance] color:[UIColor blueColor]];
                ts.backgroundColor = [UIColor whiteColor];
                ts.vAlignment = AGSTextSymbolVAlignmentMiddle;
                ts.hAlignment = AGSTextSymbolHAlignmentCenter;
                ts.fontSize	= 12;
                //add the symbol to compositeSymbol
                [cs addSymbol:sms];
                [cs addSymbol:ts];
                //create a AGSGraphic
                AGSGraphic *theGraphic = [[AGSGraphic alloc] initWithGeometry:midPoint symbol:cs attributes:nil];
                [localgraphicLayer addGraphic:theGraphic];
                //
                
                
            }
        }];

    }
    else
    {
//        [_graphicLayer removeAllGraphics];
        
        [_tapPointArray addObject:mappoint];
        //
        
        
        
        if (_tapPointArray.count >= 2) {
            
            NSString *distance = [NSString stringWithFormat:@"%.0f",[mappoint distanceToPoint:_tapPointArray[_tapPointArray.count - 2]]*1.09];
            NSLog(@"distance:%f",[mappoint distanceToPoint:_tapPointArray[_tapPointArray.count - 2]]);
            
            AGSPoint *lastSecondPoint = (AGSPoint *)_tapPointArray[_tapPointArray.count - 2];
            double _x = (mappoint.x + lastSecondPoint.x)/2;
            double _y = (mappoint.y + lastSecondPoint.y)/2;
            
            AGSPoint *midPoint = [[AGSPoint alloc] initWithX:_x y:_y spatialReference:self.mapView.spatialReference];
            
            [_midPointArray addObject:midPoint];
            
            AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
            // create outline
            AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbol];
            sls.color = [UIColor greenColor];
            sls.width = 2;
            sls.style=AGSSimpleLineSymbolStyleSolid;
            // create main circle
            AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
            sms.color = [UIColor whiteColor];
            sms.outline = sls;
            
            NSInteger strCount = [distance length];
            
            if (strCount <= 2) {
                sms.size = CGSizeMake(20, 20);
            }
            if (strCount == 3) {
                sms.size = CGSizeMake(25, 25);
            }
            else if(strCount >= 4)
                sms.size = CGSizeMake(33, 33);
            
            
            sms.style=AGSSimpleMarkerSymbolStyleCircle;
            //create text to display the distance
            AGSTextSymbol *ts = [[AGSTextSymbol alloc] initWithText:[NSString stringWithFormat:@"%@",distance] color:[UIColor blueColor]];
            ts.backgroundColor = [UIColor whiteColor];
            ts.vAlignment = AGSTextSymbolVAlignmentMiddle;
            ts.hAlignment = AGSTextSymbolHAlignmentCenter;
            ts.fontSize	= 12;
            //add the symbol to compositeSymbol
            [cs addSymbol:sms];
            [cs addSymbol:ts];
            //create a AGSGraphic
            AGSGraphic *theGraphic = [[AGSGraphic alloc] initWithGeometry:midPoint symbol:cs attributes:nil];
            //
            [self.graphicLayer addGraphic:theGraphic];
            self.sketchLayer.midVertexSymbol = nil;
            
        }
        
        [self.sketchLayer insertVertex:mappoint inPart:0 atIndex:-1];
    }
    
}

//
-(BOOL)mapView:(AGSMapView *)mapView shouldProcessClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    //若球洞选择框在界面中，则将相应的界面给隐藏掉
    _chooseHoleView.hidden = YES;
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //移除掉view以及将相应的通知给移除掉，从而释放内存
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_mapView.locationDisplay removeObserver:self forKeyPath:@"autoPanMode"];
//        [_mapView removeObserver:self forKeyPath:@"location"];
    });
//    //
//    dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 2ull * NSEC_PER_SEC );
//    dispatch_after(time, dispatch_get_main_queue(), ^{
////        self.view = nil;
////        [self.mapView removeFromSuperview];
////        self.mapView = nil;
//    });
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view = nil;
    });
}

+ (void)removeMapView
{
    ViewController *mapVC = [[ViewController alloc] init];
    [mapVC.mapView removeFromSuperview];
    
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
    //
    BOOL addMapView;
    addMapView = YES;
    NSArray *subViewsArray;
    subViewsArray = self.view.subviews;
    for (id subView in subViewsArray) {
        if ([subView isKindOfClass:[AGSMapView class]]) {
            addMapView = NO;
        }
    }
    //
    if (addMapView) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:self.mapView];
            //
            self.groInfo = [self.mapDbCon ExecDataTable:@"select *from tbl_groupHeartInf"];
            
            
            if ([self.groInfo.Rows count]) {
                self.curCourseTag = self.groInfo.Rows[0][@"coursegrouptag"];
            }
            else
                self.curCourseTag = @"north";
            //
            //判断
            if ([self.curCourseTag isEqualToString:@"north"]) {
                self.theCourseIndex = 0;
            }
            else if ([self.curCourseTag isEqualToString:@"south"])
            {
                self.theCourseIndex = 1;
            }
            
            [self switchToCurCourse];
        });
        
        
//        dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC );
//        dispatch_after(time, dispatch_get_main_queue(), ^{
//            [self.view addSubview:self.mapView];
//            //
//            self.groInfo = [self.mapDbCon ExecDataTable:@"select *from tbl_groupHeartInf"];
//            
//            
//            if ([self.groInfo.Rows count]) {
//                self.curCourseTag = self.groInfo.Rows[0][@"coursegrouptag"];
//            }
//            else
//                self.curCourseTag = @"north";
//            //
//            //判断
//            if ([self.curCourseTag isEqualToString:@"north"]) {
//                self.theCourseIndex = 0;
//            }
//            else if ([self.curCourseTag isEqualToString:@"south"])
//            {
//                self.theCourseIndex = 1;
//            }
//            
//            [self switchToCurCourse];
//        });
//        
    }
    
}
#pragma -mark mapViewDidLoad
/**
 *  mapViewDidLoad
 *
 *  @param mapView current mapView
 */
-(void)mapViewDidLoad:(AGSMapView *)mapView
{
    [_mapView.locationDisplay startDataSource];
    _mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    _mapView.locationDisplay.wanderExtentFactor = 0.75;
    
    //set the midvertex symbol to nil to avoid the default circle symbol appearing in between vertices
    self.gpsSketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
    self.gpsSketchLayer.midVertexSymbol = nil;
    
    //
    self.sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
    self.sketchLayer.midVertexSymbol = nil;
    
    dispatch_queue_t myQueue = dispatch_queue_create("the queue", NULL);
    
    dispatch_async(myQueue, ^{
    //we remove the previos part from the sketch layer as we are going to start a new GPS path.
    [self.sketchLayer removePartAtIndex:0];
    
    //add a new path to the geometry in preparation of adding vertices to the path
    [self.sketchLayer addPart];
    
    });
    
}
#pragma -mark switchMapFunction
- (IBAction)switchMapFunction:(UISegmentedControl *)sender {
    NSLog(@"segment's index:%ld",(long)sender.selectedSegmentIndex);
    NSInteger index = sender.selectedSegmentIndex;
    sender.selected = NO;
    //
    UIActionSheet *selectField = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"北场" otherButtonTitles:@"南场", nil];
    selectField.actionSheetStyle = UIActionSheetStyleDefault;
    //
    switch (index) {
        case 0: //自动测距
            [self.chooseHoleView removeFromSuperview];
            //
//            if (!_sketchLayer) {
//                self.sketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:[[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference]];
//                [_mapView addMapLayer:self.sketchLayer withName:@"My Sketch layer"];
//            }
            //
            [_mapView removeMapLayerWithName:@"My Sketch layer"];
            
            
            //we remove the previos part from the sketch layer as we are going to start a new GPS path.
//            [self.sketchLayer removePartAtIndex:0];
//            
//            //add a new path to the geometry in preparation of adding vertices to the path
//            [self.sketchLayer addPart];
            
            [_midPointArray removeAllObjects];
            [_tapPointArray removeAllObjects];
            
            self.autoCalculateDistanceEnable = YES;
            
            break;
            //
        case 1: //选择球洞
            //此处加载选择球洞的视图
            [self.chooseHoleView setFrame:CGRectMake(10, self.navView.frame.size.height+80, ScreenWidth-20, self.chooseHoleView.frame.size.height)];
            _chooseHoleView.hidden = NO;
            [self.view addSubview:self.chooseHoleView];
            
            [_sketchLayer removeSelectedPart];
            [_graphicLayer removeAllGraphics];
            
            self.autoCalculateDistanceEnable = NO;
            
            break;
            //
        case 2: //手动测距
            [self.chooseHoleView removeFromSuperview];
            //
            if (!_sketchLayer) {
                self.sketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:[[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference]];
                [_mapView addMapLayer:self.sketchLayer withName:@"My Sketch layer"];
                
                
            }
            //
            [_mapView removeMapLayerWithName:@"local Sketch layer"];
            [_mapView removeMapLayerWithName:@"local graphic Layer"];
                        //we remove the previos part from the sketch layer as we are going to start a new GPS path.
            [self.sketchLayer removePartAtIndex:0];
            
            //add a new path to the geometry in preparation of adding vertices to the path
            [self.sketchLayer addPart];
            
            [_midPointArray removeAllObjects];
            [_tapPointArray removeAllObjects];
            
            self.autoCalculateDistanceEnable = NO;
            
            break;
            
        case 3://切换球场
            [self.chooseHoleView removeFromSuperview];
            [selectField showInView:self.view];
            
            break;
        default:
            break;
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex:%ld",buttonIndex);
    //
    switch (buttonIndex) {
        case 0:
            if (self.theCourseIndex == 1) {
                self.theCourseIndex = 0;
                
                [self switchToCurCourse];
            }
            
            break;
            
        case 1:
            if (self.theCourseIndex == 0) {
                self.theCourseIndex = 1;
                
                [self switchToCurCourse];
            }
            
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
            //将选择的球洞放大到屏幕中央
            [_mapView zoomToGeometry:curDic[@"Shape"] withPadding:120 animated:YES];
            
        }];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//    if ([self.view window] == nil) {
//        //保存数据
//        
//        //
//        self.mapView = nil;
//    }
    
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
    [_mapView centerAtPoint:[_mapView.locationDisplay mapLocation] animated:YES];
    _mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
}



@end
