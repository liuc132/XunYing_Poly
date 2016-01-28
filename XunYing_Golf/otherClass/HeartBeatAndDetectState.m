//
//  HeartBeatAndDetectState.m
//  XunYing_Golf
//
//  Created by LiuC on 15/10/14.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "HeartBeatAndDetectState.h"
#import "DataTable.h"
#import "DBCon.h"
#import "XunYingPre.h"
#import "GetGPSLocationData.h"
#import "HttpTools.h"
#import "GetRequestIPAddress.h"

//extern BOOL allowDownCourt;

typedef enum eventType{
    changeCart = 1, //换球车
    changeCaddy,    //换球童
    jumpHole,       //跳洞
    mendHole,       //补洞
    order,          //点餐
    leaveToRest     //离场休息
}eventTypeEnum;
typedef enum eventOrder{
    _caddy,
    _cart,
    _jump,
    _mend,
    _order,
    _leave
}eventOrder;


@interface HeartBeatAndDetectState ()


//@property(strong, nonatomic)NSTimer *heartBeatTime;

//
@property(strong, nonatomic)NSArray *simulationGPSData;
//
@property (strong, nonatomic) DBCon *lcDBCon;
@property (strong, nonatomic) DataTable *groupInformation;
@property (strong, nonatomic) DataTable *userData;
//
@property (strong, nonatomic) CLLocation *getGPSLocation;
@property (strong, nonatomic) GetGPSLocationData *gpsData;
@property (strong, nonatomic) NSArray    *observerNameArray;
@property                     BOOL      canEnterHeartBeat;
//@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) NSTimer *heartBeatTime;

@end

@implementation HeartBeatAndDetectState
//
-(void)initHeartBeat
{
    NSLog(@"初始化心跳");
    //
    self.simulationGPSData = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"106.28256131500",@"29.49389984490", nil],[[NSArray alloc] initWithObjects:@"106.28256669700",@"29.49432700910", nil],[[NSArray alloc] initWithObjects:@"106.28281553500",@"29.49458953090", nil],[[NSArray alloc] initWithObjects:@"106.28298506800",@"29.49505329810", nil],[[NSArray alloc] initWithObjects:@"106.28341349200",@"29.49527828640", nil],[[NSArray alloc] initWithObjects:@"106.28296532100",@"29.49592164420", nil],[[NSArray alloc] initWithObjects:@"106.28253196400",@"29.49611735560", nil],[[NSArray alloc] initWithObjects:@"106.28209158900",@"29.49624332170", nil],[[NSArray alloc] initWithObjects:@"106.28165696300",@"29.49617591050", nil],[[NSArray alloc] initWithObjects:@"106.28128793600",@"29.49595571510", nil],[[NSArray alloc] initWithObjects:@"106.28105536100",@"29.49573897710", nil],[[NSArray alloc] initWithObjects:@"106.28060691900",@"29.49565737550", nil],[[NSArray alloc] initWithObjects:@"106.28037981600",@"29.49538747980", nil],[[NSArray alloc] initWithObjects:@"106.27988107400",@"29.49521089300", nil],[[NSArray alloc] initWithObjects:@"106.27950619300",@"29.49490423120", nil],[[NSArray alloc] initWithObjects:@"106.27896363000",@"29.49471374150", nil],[[NSArray alloc] initWithObjects:@"106.27818672000",@"29.49454459560", nil],[[NSArray alloc] initWithObjects:@"106.27752617100",@"29.49495190530", nil],[[NSArray alloc] initWithObjects:@"106.27742754600",@"29.49535381570", nil],[[NSArray alloc] initWithObjects:@"106.27757328600",@"29.49566268470", nil],[[NSArray alloc] initWithObjects:@"106.27758683300",@"29.49598117650", nil],[[NSArray alloc] initWithObjects:@"106.27708125300",@"29.49612923310", nil],[[NSArray alloc] initWithObjects:@"106.27679707600",@"29.49631096300", nil],[[NSArray alloc] initWithObjects:@"106.27649706800",@"29.49653580450", nil],[[NSArray alloc] initWithObjects:@"106.27621136300",@"29.49659582670", nil],[[NSArray alloc] initWithObjects:@"106.27582844200",@"29.49673554190", nil],[[NSArray alloc] initWithObjects:@"106.27543652900",@"29.49681090140", nil],[[NSArray alloc] initWithObjects:@"106.27538489600",@"29.49726248040", nil],[[NSArray alloc] initWithObjects:@"106.27509396400",@"29.49755883220", nil],[[NSArray alloc] initWithObjects:@"106.27518694400",@"29.49779422250", nil],[[NSArray alloc] initWithObjects:@"106.27533291100",@"29.49793095230", nil],[[NSArray alloc] initWithObjects:@"106.27555281500",@"29.49808964580", nil],[[NSArray alloc] initWithObjects:@"106.27586363900",@"29.49829191900", nil],[[NSArray alloc] initWithObjects:@"106.27598903800",@"29.49806636830", nil],[[NSArray alloc] initWithObjects:@"106.27603221000",@"29.49781057860", nil],[[NSArray alloc] initWithObjects:@"106.27643308900",@"29.49779718520", nil],[[NSArray alloc] initWithObjects:@"106.27678636200",@"29.49790358100", nil],[[NSArray alloc] initWithObjects:@"106.27701748600",@"29.49762450680", nil],[[NSArray alloc] initWithObjects:@"106.27744573200",@"29.49761800720", nil],[[NSArray alloc] initWithObjects:@"106.27762187300",@"29.49774042310", nil],[[NSArray alloc] initWithObjects:@"106.27779414900",@"29.49774503270", nil],[[NSArray alloc] initWithObjects:@"106.27799078300",@"29.49724522150", nil],[[NSArray alloc] initWithObjects:@"106.27841002000",@"29.49668449810", nil],[[NSArray alloc] initWithObjects:@"106.27860578000",@"29.49625122350", nil],[[NSArray alloc] initWithObjects:@"106.27894704300",@"29.49599913010", nil],[[NSArray alloc] initWithObjects:@"106.27976262200",@"29.49631348670", nil],[[NSArray alloc] initWithObjects:@"106.28051225100",@"29.49626450440", nil],[[NSArray alloc] initWithObjects:@"106.28123775500",@"29.49646635190", nil],[[NSArray alloc] initWithObjects:@"106.28149653900",@"29.49697699490", nil],[[NSArray alloc] initWithObjects:@"106.28151023800",@"29.49643986010", nil],[[NSArray alloc] initWithObjects:@"106.28205570100",@"29.49648054630", nil],[[NSArray alloc] initWithObjects:@"106.28217423800",@"29.49679444580", nil],[[NSArray alloc] initWithObjects:@"106.28226058300",@"29.49715161490", nil],[[NSArray alloc] initWithObjects:@"106.28195402700",@"29.49750541300", nil],[[NSArray alloc] initWithObjects:@"106.28224297800",@"29.49770310830", nil],[[NSArray alloc] initWithObjects:@"106.28205926400",@"29.49806288180", nil],[[NSArray alloc] initWithObjects:@"106.28229435800",@"29.49853317810", nil],[[NSArray alloc] initWithObjects:@"106.28273618600",@"29.49852175670", nil],[[NSArray alloc] initWithObjects:@"106.28278907800",@"29.49882196860", nil],[[NSArray alloc] initWithObjects:@"106.28319936100",@"29.49922971260", nil],[[NSArray alloc] initWithObjects:@"106.28339751600",@"29.49936622830", nil],[[NSArray alloc] initWithObjects:@"106.28344986900",@"29.49962348490", nil],[[NSArray alloc] initWithObjects:@"106.28362758600",@"29.49986998410", nil],[[NSArray alloc] initWithObjects:@"106.28396807700",@"29.50004331140", nil],[[NSArray alloc] initWithObjects:@"106.28419788500",@"29.50009359890", nil],[[NSArray alloc] initWithObjects:@"106.28435366100",@"29.50033076260", nil],[[NSArray alloc] initWithObjects:@"106.28450343900",@"29.50052502390", nil],[[NSArray alloc] initWithObjects:@"106.28440176500",@"29.50068352650", nil],[[NSArray alloc] initWithObjects:@"106.28455651800",@"29.50083955310", nil],[[NSArray alloc] initWithObjects:@"106.28478843600",@"29.50078659490", nil],[[NSArray alloc] initWithObjects:@"106.28489986500",@"29.50059040760", nil],[[NSArray alloc] initWithObjects:@"106.28486279100",@"29.50024708380", nil],[[NSArray alloc] initWithObjects:@"106.28469345200",@"29.49980002470", nil],[[NSArray alloc] initWithObjects:@"106.28428514100",@"29.49944119270", nil],[[NSArray alloc] initWithObjects:@"106.28412503100",@"29.49886038950", nil],[[NSArray alloc] initWithObjects:@"106.28385592800",@"29.49829018370", nil],[[NSArray alloc] initWithObjects:@"106.28345288100",@"29.49748260270", nil],[[NSArray alloc] initWithObjects:@"106.28333666600",@"29.49692046740", nil],[[NSArray alloc] initWithObjects:@"106.28374515800",@"29.49642964210", nil],[[NSArray alloc] initWithObjects:@"106.28436614000",@"29.49634727270", nil],[[NSArray alloc] initWithObjects:@"106.28464074300",@"29.49643471820", nil],[[NSArray alloc] initWithObjects:@"106.28523031500",@"29.49667365630", nil],[[NSArray alloc] initWithObjects:@"106.28487671700",@"29.49621763690", nil],[[NSArray alloc] initWithObjects:@"106.28519893300",@"29.49580878840", nil],[[NSArray alloc] initWithObjects:@"106.28502076500",@"29.49547219770", nil],[[NSArray alloc] initWithObjects:@"106.28463092200",@"29.49511617180", nil],[[NSArray alloc] initWithObjects:@"106.28442743500",@"29.49466466790", nil],[[NSArray alloc] initWithObjects:@"106.28393904000",@"29.49433524770", nil],[[NSArray alloc] initWithObjects:@"106.28347920300",@"29.49410698470", nil],[[NSArray alloc] initWithObjects:@"106.28303960100",@"29.49386062470", nil],[[NSArray alloc] initWithObjects:@"106.28304341300",@"29.49362191950", nil],[[NSArray alloc] initWithObjects:@"106.28344771300",@"29.49377315350", nil],[[NSArray alloc] initWithObjects:@"106.28390799900",@"29.49403721200", nil],[[NSArray alloc] initWithObjects:@"106.28437224700",@"29.49407449730", nil],[[NSArray alloc] initWithObjects:@"106.28474343200",@"29.49430361350", nil],[[NSArray alloc] initWithObjects:@"106.28528766600",@"29.49473392400", nil],[[NSArray alloc] initWithObjects:@"106.28575176700",@"29.49475927170", nil],[[NSArray alloc] initWithObjects:@"106.28590620200",@"29.49456684430", nil],[[NSArray alloc] initWithObjects:@"106.28637218700",@"29.49474133920", nil],[[NSArray alloc] initWithObjects:@"106.28679169700",@"29.49474623120", nil],[[NSArray alloc] initWithObjects:@"106.28713493300",@"29.49492191100", nil],[[NSArray alloc] initWithObjects:@"106.28754787400",@"29.49521624910", nil],[[NSArray alloc] initWithObjects:@"106.28783806700",@"29.49551177450", nil],[[NSArray alloc] initWithObjects:@"106.28765346100",@"29.49601476450", nil],[[NSArray alloc] initWithObjects:@"106.28753674600",@"29.49649322970", nil],[[NSArray alloc] initWithObjects:@"106.28739290300",@"29.49698389150", nil],[[NSArray alloc] initWithObjects:@"106.28764595600",@"29.49757811170", nil],[[NSArray alloc] initWithObjects:@"106.28764595600",@"29.49757811170", nil],[[NSArray alloc] initWithObjects:@"106.28774747100",@"29.49805446480", nil],[[NSArray alloc] initWithObjects:@"106.28748026800",@"29.49849858730", nil],[[NSArray alloc] initWithObjects:@"106.28706106800",@"29.49878904670", nil],[[NSArray alloc] initWithObjects:@"106.28708669300",@"29.49908951960", nil],[[NSArray alloc] initWithObjects:@"106.28708249300",@"29.49940460210", nil],[[NSArray alloc] initWithObjects:@"106.28715895400",@"29.49962582310", nil],[[NSArray alloc] initWithObjects:@"106.28749331000",@"29.49952950580", nil],[[NSArray alloc] initWithObjects:@"106.28776464100",@"29.49962711890", nil],[[NSArray alloc] initWithObjects:@"106.28811817300",@"29.49975257630", nil],[[NSArray alloc] initWithObjects:@"106.28851208100",@"29.49983468050", nil],[[NSArray alloc] initWithObjects:@"106.28880642400",@"29.49981034770", nil],[[NSArray alloc] initWithObjects:@"106.28898782700",@"29.49991599020", nil],[[NSArray alloc] initWithObjects:@"106.28919341800",@"29.49999275800", nil],[[NSArray alloc] initWithObjects:@"106.28945475500",@"29.49994726420", nil],[[NSArray alloc] initWithObjects:@"106.28935974400",@"29.49955438310", nil],[[NSArray alloc] initWithObjects:@"106.28934330700",@"29.49890297940", nil],[[NSArray alloc] initWithObjects:@"106.28950854300",@"29.49837869560", nil],[[NSArray alloc] initWithObjects:@"106.28970705600",@"29.49789704800", nil],[[NSArray alloc] initWithObjects:@"106.28954503700",@"29.49738309680", nil],[[NSArray alloc] initWithObjects:@"106.28957033300",@"29.49679572900", nil],[[NSArray alloc] initWithObjects:@"106.28937730500",@"29.49641811810", nil],[[NSArray alloc] initWithObjects:@"106.28893177100",@"29.49613603600", nil],[[NSArray alloc] initWithObjects:@"106.28858405200",@"29.49646876650", nil],[[NSArray alloc] initWithObjects:@"106.28876291600",@"29.49583575710", nil],[[NSArray alloc] initWithObjects:@"106.28872224900",@"29.49564044330", nil],[[NSArray alloc] initWithObjects:@"106.28892156800",@"29.49543803110", nil],[[NSArray alloc] initWithObjects:@"106.28907106100",@"29.49517882050", nil],[[NSArray alloc] initWithObjects:@"106.28933596600",@"29.49498531850", nil],[[NSArray alloc] initWithObjects:@"106.28966094300",@"29.49479600710", nil],[[NSArray alloc] initWithObjects:@"106.28991711300",@"29.49477442910", nil],[[NSArray alloc] initWithObjects:@"106.28996330900",@"29.49454486040", nil],[[NSArray alloc] initWithObjects:@"106.29019105100",@"29.49443286370", nil],[[NSArray alloc] initWithObjects:@"106.29021488100",@"29.49416055080", nil],[[NSArray alloc] initWithObjects:@"106.29019607900",@"29.49396860560", nil],[[NSArray alloc] initWithObjects:@"106.29014123300",@"29.49351566890", nil],[[NSArray alloc] initWithObjects:@"106.29010754400",@"29.49301001960", nil],[[NSArray alloc] initWithObjects:@"106.29013344100",@"29.49247037930", nil],[[NSArray alloc] initWithObjects:@"106.29028439000",@"29.49189611230", nil],[[NSArray alloc] initWithObjects:@"106.29024015300",@"29.49141920520", nil],[[NSArray alloc] initWithObjects:@"106.28997727900",@"29.49091100500", nil],[[NSArray alloc] initWithObjects:@"106.28922862700",@"29.49081802320", nil],[[NSArray alloc] initWithObjects:@"106.28848871100",@"29.49055311100", nil],[[NSArray alloc] initWithObjects:@"106.28785230800",@"29.49070724860", nil],[[NSArray alloc] initWithObjects:@"106.28770454000",@"29.49077908700", nil],[[NSArray alloc] initWithObjects:@"106.28765432300",@"29.49101466120", nil],[[NSArray alloc] initWithObjects:@"106.28781599000",@"29.49117897050", nil],[[NSArray alloc] initWithObjects:@"106.28788270300",@"29.49138477240", nil],[[NSArray alloc] initWithObjects:@"106.28809042900",@"29.49141617380", nil],[[NSArray alloc] initWithObjects:@"106.28820666400",@"29.49165490970", nil],[[NSArray alloc] initWithObjects:@"106.28845417000",@"29.49170382630", nil],[[NSArray alloc] initWithObjects:@"106.28860999200",@"29.49183716430", nil],[[NSArray alloc] initWithObjects:@"106.28875287100",@"29.49202552090", nil],[[NSArray alloc] initWithObjects:@"106.28894758400",@"29.49199857340", nil],[[NSArray alloc] initWithObjects:@"106.28912059800",@"29.49214308110", nil],[[NSArray alloc] initWithObjects:@"106.28904754700",@"29.49240632370", nil],[[NSArray alloc] initWithObjects:@"106.28883259200",@"29.49266616860", nil],[[NSArray alloc] initWithObjects:@"106.28863909500",@"29.49289716430", nil],[[NSArray alloc] initWithObjects:@"106.28840946400",@"29.49329080480", nil],[[NSArray alloc] initWithObjects:@"106.28818401800",@"29.49358416320", nil],[[NSArray alloc] initWithObjects:@"106.28786844400",@"29.49365404680", nil],[[NSArray alloc] initWithObjects:@"106.28728579100",@"29.49374560770", nil],[[NSArray alloc] initWithObjects:@"106.28677309300",@"29.49376011540", nil],[[NSArray alloc] initWithObjects:@"106.28635259600",@"29.49373077010", nil],[[NSArray alloc] initWithObjects:@"106.28618725000",@"29.49370730840", nil],[[NSArray alloc] initWithObjects:@"106.28582411100",@"29.49346737860", nil],[[NSArray alloc] initWithObjects:@"106.28539605200",@"29.49327103450", nil],[[NSArray alloc] initWithObjects:@"106.28482096500",@"29.49309758990", nil],[[NSArray alloc] initWithObjects:@"106.28446791200",@"29.49300792000", nil],[[NSArray alloc] initWithObjects:@"106.28400065600",@"29.49294799090", nil],[[NSArray alloc] initWithObjects:@"106.28362242300",@"29.49280844110", nil],[[NSArray alloc] initWithObjects:@"106.28318781100",@"29.49274103450", nil],[[NSArray alloc] initWithObjects:@"106.28274564700",@"29.49272381900", nil],[[NSArray alloc] initWithObjects:@"106.28233303600",@"29.49285996000", nil], nil];
    //初始化通知中的observerName
    self.observerNameArray = [[NSArray alloc] initWithObjects:@"changeCaddy",@"changeCart",@"jumpHole",@"mendHole",@"Order",@"leaveToRest", nil];
    
    
    
    //
    self.lcDBCon = [[DBCon alloc] init];
    self.userData = [[DataTable alloc] init];
    self.groupInformation = [[DataTable alloc] init];
    
//    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timelySend)];
//    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    //启动心跳功能
//    [self enableHeartBeat];
}

- (void)DisAbleTimer:(NSNotification *)sender
{
    __weak typeof(self) weakSelf = self;
    NSLog(@"version:%f",[[[UIDevice currentDevice] systemVersion] floatValue]);
    if (![sender.userInfo[@"disableHeart"] isEqualToString:@"1"] || sender == nil)
    {
        return;
    }
    //
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC ) ;
        dispatch_after(time,dispatch_get_main_queue(), ^{
            //3接收到了心跳信息之后，移除通知
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            //1关闭心跳
            [weakSelf.heartBeatTime invalidate];
            weakSelf.heartBeatTime = nil;
            weakSelf.canEnterHeartBeat = NO;
            
            //2关闭GPS更新
            [weakSelf.gpsData stopUpdateLocation];
            
        });
    }
    else
    {
        //3接收到了心跳信息之后，移除通知
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //1关闭心跳
        [self.heartBeatTime invalidate];
        self.heartBeatTime = nil;
        self.canEnterHeartBeat = NO;
        //2关闭GPS更新
        [self.gpsData stopUpdateLocation];
        
    }
}

- (void)initAndGetGpsLocation
{
    //1、获取GPS数据,初始化实例变量
    self.gpsData = [[GetGPSLocationData alloc] init];
    //2、启动GPS，并进行相关参数的设置,第三步放在下边执行！
    [self.gpsData initGPSLocation];
}

//
-(void)enableHeartBeat
{
    NSLog(@"使能心跳");
    //获取到心跳间隔时长
    NSString *intervalTimeStr = [GetRequestIPAddress getIntervalTime];
    NSTimeInterval heartBeatInterval = [intervalTimeStr doubleValue];
    //1开启心跳功能
    self.heartBeatTime = [NSTimer timerWithTimeInterval:heartBeatInterval target:self selector:@selector(timelySend) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.heartBeatTime forMode:NSRunLoopCommonModes];
    self.canEnterHeartBeat = YES;
    //2开启GPS功能
    [self initAndGetGpsLocation];
    //3添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DisAbleTimer:) name:@"HeartBeat" object:nil];
    
}


//m15000204330@163.com
+(void)disableHeartBeat
{
    NSLog(@"除能心跳");
    //关闭心跳定时计数器
    HeartBeatAndDetectState *heartBeat;// = [[HeartBeatAndDetectState alloc] init];
    [heartBeat.heartBeatTime invalidate];
    
}

- (void)disableHeart
{
    __weak typeof(self) weakSelf = self;
    //
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC ) ;
        dispatch_after(time,dispatch_get_main_queue(), ^{
            //3接收到了心跳信息之后，移除通知
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            //1关闭心跳
            [weakSelf.heartBeatTime invalidate];
            weakSelf.heartBeatTime = nil;
            weakSelf.canEnterHeartBeat = NO;
            //2关闭GPS更新
            [weakSelf.gpsData stopUpdateLocation];
            
        });
    }
    else
    {
        //3接收到了心跳信息之后，移除通知
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //1关闭心跳
        [self.heartBeatTime invalidate];
        self.heartBeatTime = nil;
        self.canEnterHeartBeat = NO;
        //2关闭GPS更新
        [self.gpsData stopUpdateLocation];
        
    }
}

//
-(void)timelySend
{
    __weak typeof(self) weakSelf = self;
    dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC ) ;
    dispatch_after(time,dispatch_get_main_queue(), ^{
        
        if (!self.canEnterHeartBeat) {
            return;
        }
        
        //计算发送次数
        static unsigned char SendGPStimes = 0;
        static unsigned char startCount = 0;
        
        //
        weakSelf.groupInformation = [self.lcDBCon ExecDataTable:@"select *from tbl_groupInf"];
        weakSelf.userData = [self.lcDBCon ExecDataTable:@"select *from tbl_logPerson"];
        
        weakSelf.allowDownStr = @"0";
        weakSelf.finalDic = [[NSMutableDictionary alloc] init];
        weakSelf.waitToAllow = @"0";
        //    self.allowDown = NO;
        weakSelf.haveDetectedDownEnable = @"1";
        //在这里发送心跳信息
        //    static unsigned int timeCounter = 0;
        //    timeCounter++;
        //    if(timeCounter > 9)
        {
#ifdef DEBUG_MODE
            NSLog(@"start send heartBeat");
#endif
            
            if(SendGPStimes < GPSSendTimes)
            {
                SendGPStimes++;
            }
            else
            {
                SendGPStimes = 0;
                
                if(startCount < [weakSelf.simulationGPSData count])
                    startCount++;
                else{
                    startCount = 0;
                }
            }
            //NSLog(@"longitude:%.8f; latitude:%.8f",self.getGPSLocation.coordinate.longitude,self.getGPSLocation.coordinate.latitude);
            //经度
            //
            //3、获取到GPS数据
            weakSelf.getGPSLocation = [weakSelf.gpsData getCurLocation];
            
            NSString *locx = [NSString stringWithFormat:@"%.10f",self.getGPSLocation.coordinate.longitude];//self.simulationGPSData[startCount][0];模拟数据调用之
            //纬度
            NSString *locy = [NSString stringWithFormat:@"%.10f",weakSelf.getGPSLocation.coordinate.latitude];//self.simulationGPSData[startCount][1];模拟数据调用之
#ifdef DEBUG_MODE
            NSLog(@"current locx:%@; locy:%@",locx,locy);
#endif
            //获取到mid号码
            NSString *theMid;
            theMid = [GetRequestIPAddress getUniqueID];
            theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
            //
            //获取到当前系统的时间，并生成相应的格式
            NSDateFormatter *dateFarmatter = [[NSDateFormatter alloc] init];
            [dateFarmatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *curDateTime = [dateFarmatter stringFromDate:[NSDate date]];
            //
            NSString *timestampsStr;
            if (weakSelf.groupInformation.Rows[0][@"timestamps"] != nil) {
                timestampsStr = self.groupInformation.Rows[0][@"timestamps"];
            }
            else
            {
                timestampsStr = @"";
            }
            //使用模拟数据时，则在此组建地图界面的当前位置点
            //start send and handle all what the server sends back
            //巡场和球童这两个角色所传的参数不一样：主要是 组“grocod”不一致，球童需要传该参数，而巡场则不传该参数或者传空
            //construct the parameters for the heartBeat
            NSMutableDictionary *heartBeatParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.userData.Rows[0][@"job"],@"job",[NSDate date],@"loct",locx,@"locx",locy,@"locy",weakSelf.groupInformation.Rows[0][@"grocod"],@"grocod",@"1",@"gpsType",weakSelf.userData.Rows[0][@"code"],@"bandcode",curDateTime,@"loct",timestampsStr,@"timestamps", nil];
            //获取到IP地址
            NSString *heartUrl;
            heartUrl = [GetRequestIPAddress getHeartBeatURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //request
                [HttpTools getHttp:heartUrl forParams:heartBeatParam success:^(NSData *nsData){
                    NSLog(@"success send HeartBeat");
                    
                    //                NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
                    NSDictionary *receiveDic;
                    receiveDic = (NSDictionary *)nsData;
                    //handle error
                    //            NSLog(@"Code:%@ and messege is:%@",receiveDic[@"Code"],receiveDic[@"Msg"]);
                    
                    if([receiveDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-1]])
                    {
                        NSString *errStr;
                        errStr = [NSString stringWithFormat:@"%@",receiveDic[@"Msg"]];
                        UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                        [hasGrpFailAlert show];
                        NSLog(@"fail");
                    }
                    
                    else if ([receiveDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-2]])
                    {
                        [weakSelf disableHeart];
                        NSLog(@"param is null");
                    }
                    else if ([receiveDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-3]])
                    {
                        NSString *errStr;
                        errStr = [NSString stringWithFormat:@"%@",receiveDic[@"Msg"]];
                        UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                        [hasGrpFailAlert show];
                        NSLog(@"The mid is illegal");
                    }
                    
                    else
                    {
                        //
                        NSArray *eventInfo = receiveDic[@"Msg"][@"eveinfo"];
                        //                NSLog(@"event:%@",eventInfo);
                        if ([eventInfo count]) {
                            //
                            //                    [weakSelf.lcDBCon ExecNonQuery:@"delete from tbl_taskInfo"];
                            //
                            NSDictionary *eventDic = eventInfo[0];
                            NSString *observerName = [[NSString alloc] init];
                            //                    NSMutableArray *taskInfo = [[NSMutableArray alloc] init];
                            //tbl_taskInfo(evecod text,evetyp text,evesta text,subtim text,result text,everea text,hantim text,oldCaddyCode text,newCaddyCode text,oldCartCode text,newCartCode text,jumpHoleCode text,toHoleCode text,destintime text,reqBackTime text,reHoleCode text,mendHoleCode text,ratifyHoleCode text,ratifyinTime text,selectedHoleCode text)
                            
                            NSLog(@"eventDic:%@",eventDic);
                            NSDictionary *newCart;// = [[NSDictionary alloc] init];
                            NSString *value;// = [[NSString alloc] init];
                            NSString *cartValue;// = [[NSString alloc] init];
                            NSString *decideValue;// = [[NSString alloc] init];
                            value = [eventDic objectForKey:@"hantim"];
                            //
                            switch ([eventDic[@"evetyp"] intValue]) {
                                case changeCaddy:
                                    observerName = weakSelf.observerNameArray[_caddy];
                                    //更新相应的数据
                                    //
                                    //                            value = [eventDic objectForKey:@"hantim"];
                                    if (value != nil) {
                                        //
                                        newCart = eventDic[@"everes"];
                                        cartValue = [newCart objectForKey:@"newcad"];
                                        if ((NSNull *)cartValue != [NSNull null]) {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET newCaddyCode = '%@' , result = '%@' , hantim = '%@' where evecod = '%@'",eventDic[@"everes"][@"newcad"][@"carcod"],eventDic[@"everes"][@"result"],eventDic[@"hantim"],eventDic[@"evecod"]]];
                                        }
                                        else
                                        {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET result = '%@' ,hantim = '%@' where evecod = '%@'",eventDic[@"everes"][@"result"],eventDic[@"hantim"],eventDic[@"evecod"]]];
                                        }
                                        //
                                        
                                    }
                                    
                                    break;
                                case changeCart:
                                    observerName = weakSelf.observerNameArray[_cart];
                                    //更新相应的数据
                                    //                            value = [eventDic objectForKey:@"hantim"];
                                    if (value != nil) {
                                        //
                                        newCart = eventDic[@"everes"];
                                        cartValue = [newCart objectForKey:@"newcar"];
                                        if ((NSNull *)cartValue != [NSNull null]) {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET newCartCode = '%@' , result = '%@' , hantim = '%@' where evecod = '%@'",eventDic[@"everes"][@"newcar"][@"carcod"],eventDic[@"everes"][@"result"],eventDic[@"hantim"],eventDic[@"evecod"]]];
                                        }
                                        else
                                        {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET result = '%@' ,hantim = '%@' where evecod = '%@'",eventDic[@"everes"][@"result"],eventDic[@"hantim"],eventDic[@"evecod"]]];
                                        }
                                        //
                                        
                                    }
                                    //                            table12 = [weakSelf.lcDBCon ExecDataTable:@"select *from tbl_taskInfo"];
                                    //                            NSLog(@"table12:%@",table12.Rows);
                                    
                                    break;
                                case jumpHole:
                                    observerName = weakSelf.observerNameArray[_jump];
                                    //                            value = [eventDic objectForKey:@"hantim"];
                                    if (value != nil) {
                                        //
                                        newCart = eventDic[@"everes"];
                                        cartValue = [newCart objectForKey:@"desthole"];
                                        if ((NSNull *)cartValue != [NSNull null]) {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET toHoleCode = '%@' , result = '%@' , destintime = '%@' , hantim = '%@' where evecod = '%@'",eventDic[@"everes"][@"desthole"][@"holcod"],eventDic[@"everes"][@"result"],eventDic[@"everes"][@"destintime"],eventDic[@"hantim"],eventDic[@"evecod"]]];
                                        }
                                        else
                                        {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET result = '%@' ,hantim = '%@' where evecod = '%@'",eventDic[@"everes"][@"result"],eventDic[@"hantim"],eventDic[@"evecod"]]];
                                        }
                                        //
                                        
                                    }
                                    
                                    break;
                                case mendHole:
                                    observerName = weakSelf.observerNameArray[_mend];
                                    //                            value = [eventDic objectForKey:@"hantim"];
                                    if (value != nil) {
                                        //
                                        newCart = eventDic[@"everes"];
                                        cartValue = [newCart objectForKey:@"ratifyhole"];
                                        if ((NSNull *)cartValue != [NSNull null]) {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET ratifyHoleCode = '%@' , result = '%@' , ratifyinTime = '%@' ,hantim = '%@' where evecod = '%@'",eventDic[@"everes"][@"ratifyhole"][@"holcod"],eventDic[@"everes"][@"result"],eventDic[@"everes"][@"ratifyintime"],eventDic[@"hantim"],eventDic[@"evecod"]]];
                                        }
                                        else
                                        {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET result = '%@' ,hantim = '%@' where evecod = '%@'",eventDic[@"everes"][@"result"],eventDic[@"hantim"],eventDic[@"evecod"]]];
                                        }
                                        //
                                        decideValue = [newCart objectForKey:@"selectedhole"];
                                        if ((NSNull *)decideValue != [NSNull null]) {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET selectedHoleCode = '%@' , result = '%@' where evecod = '%@'",eventDic[@"everes"][@"selectedhole"][@"holcod"],eventDic[@"everes"][@"result"],eventDic[@"evecod"]]];
                                            
                                        }
                                        
                                    }
                                    
                                    break;
                                case order:
                                    observerName = weakSelf.observerNameArray[_order];
                                    
                                    break;
                                case leaveToRest:
                                    observerName = weakSelf.observerNameArray[_leave];
                                    //                            value = [eventDic objectForKey:@"hantim"];
                                    if (value != nil) {
                                        //
                                        newCart = eventDic[@"everes"];
                                        cartValue = [newCart objectForKey:@"rehole"];
                                        if ((NSNull *)cartValue != [NSNull null]) {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET reHoleCode = '%@' , reqBackTime = '%@' , result = '%@' ,hantim = '%@' where evecod = '%@'",eventDic[@"everes"][@"rehole"][@"holcod"],eventDic[@"everes"][@"retime2"],eventDic[@"everes"][@"result"],eventDic[@"hantim"],eventDic[@"evecod"]]];
                                        }
                                        else
                                        {
                                            [weakSelf.lcDBCon ExecNonQuery:[NSString stringWithFormat:@"UPDATE tbl_taskInfo SET result = '%@' ,hantim = '%@' where evecod = '%@'",eventDic[@"everes"][@"result"],eventDic[@"hantim"],eventDic[@"evecod"]]];
                                        }
                                        //
                                        
                                        
                                        
                                    }
                                    
                                    break;
                                default:
                                    break;
                            }
                            
                            
                            //保存数据 tbl_taskInfo(evecod text,evetyp text,evesta text,subtim text,retime text,newCartNum text,rehole text)
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //                        DataTable *table111 = [[DataTable alloc] init];
                                //                        table111 = [weakSelf.lcDBCon ExecDataTable:@"select *from tbl_taskInfo"];
                                //                        NSLog(@"table111:%@",table111);
                                //通过通知发送到相应的界面中去
                                [[NSNotificationCenter defaultCenter] postNotificationName:observerName object:nil userInfo:eventDic];
                                //发送到事务通讯主界面中去 displayTaskResult
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"displayTaskResult" object:nil userInfo:eventDic];
                                //在详情视图界面也发送通知
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"detailRefresh" object:nil userInfo:eventDic];
                            });
                        }
                        
                        //
                        NSDictionary *messegaDic = receiveDic[@"Msg"];
#ifdef DEBUG_MODE
                        NSLog(@"reason Notice:%@",messegaDic[@"makeV"]);
#endif
                        //删除之前保存的数据
                        [self.lcDBCon ExecNonQuery:@"delete from tbl_groupHeartInf"];
                        [self.lcDBCon ExecNonQuery:@"delete from tbl_locHole"];
                        [self.lcDBCon ExecNonQuery:@"delete from tbl_padInfo"];
                        
                        //从服务器中返回来的信息，在此处保存
                        //组信息
                        //tbl_groupHeartInf(grocod text,grosta text,nextgrodistime text,nowblocks text,nowholcod text,nowholnum text,pladur text,stahol text,statim text,stddur text)
                        NSMutableArray *groupInfArray = [[NSMutableArray alloc] initWithObjects:messegaDic[@"groinfo"][@"grocod"],messegaDic[@"groinfo"][@"grosta"],messegaDic[@"groinfo"][@"nextgrodistime"],messegaDic[@"groinfo"][@"nowblocks"],messegaDic[@"groinfo"][@"nowholcod"],messegaDic[@"groinfo"][@"nowholnum"],messegaDic[@"groinfo"][@"pladur"],messegaDic[@"groinfo"][@"stahol"],messegaDic[@"groinfo"][@"statim"],messegaDic[@"groinfo"][@"stddur"], nil];
                        [weakSelf.lcDBCon ExecNonQuery:@"insert into tbl_groupHeartInf(grocod,grosta,nextgrodistime,nowblocks,nowholcod,nowholnum,pladur,stahol,statim,stddur) values(?,?,?,?,?,?,?,?,?,?)" forParameter:groupInfArray];
                        //当前所在球洞的位置信息
                        NSMutableArray *locHoleInf = [[NSMutableArray alloc] initWithObjects:messegaDic[@"lochole"][@"holcod"],messegaDic[@"lochole"][@"holnum"], nil];
                        [weakSelf.lcDBCon ExecNonQuery:@"insert into tbl_locHole(holcod,holnum) values(?,?)" forParameter:locHoleInf];
                        //移动设备的信息
                        NSDictionary *padInfDic = messegaDic[@"padinfo"][0];
                        //
                        NSMutableArray *padInf = [[NSMutableArray alloc] initWithObjects:padInfDic[@"padcod"],padInfDic[@"padnum"],padInfDic[@"padtag"], nil];
                        [weakSelf.lcDBCon ExecNonQuery:@"insert into tbl_padInfo(padcod,padnum,padtag) values(?,?,?)" forParameter:padInf];
                        //
                        if([messegaDic[@"make"] isEqualToNumber:[NSNumber numberWithInt:-1]])
                        {
                            NSLog(@"makev is:%@",messegaDic[@"makeV"]);
//                            NSLog(@"心跳异常");
                            //
                            weakSelf.allowDownStr = @"1";
                            //                    weakSelf.haveDetectedDownEnable = @"1";
                            //                    weakSelf.allowDownStr = @"1";
                        }
                        else if([messegaDic[@"make"] isEqualToNumber:[NSNumber numberWithInt:-2]])
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [weakSelf.heartBeatTime invalidate];
                                [weakSelf disableHeart];
                                weakSelf.allowDownStr = @"0";
                                weakSelf.haveDetectedDownEnable = @"0";
                                //发送通知，从当前界面跳回到建组界面（手动建组，二维码建组）
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"forceBackField" object:nil userInfo:@{@"forceBack":@"1"}];
                            });
//                            [weakSelf.heartBeatTime invalidate];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"forceBackField" object:nil userInfo:@{@"disableHeart":@"1"}];
#ifdef DEBUG_MODE
                            NSLog(@"小组已经回场");
#endif
                            //
//                            weakSelf.allowDownStr = @"0";
//                            weakSelf.haveDetectedDownEnable = @"0";
//                            //发送通知，从当前界面跳回到建组界面（手动建组，二维码建组）
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"forceBackField" object:nil userInfo:@{@"forceBack":@"1"}];
                            
                        }
                        else if([messegaDic[@"make"] isEqualToNumber:[NSNumber numberWithInt:0]])
                        {
                            //if([messegaDic[@"departstatus"] isEqualToNumber:[NSNumber numberWithInt:1]])
                            if([messegaDic[@"departstatus"] intValue] == 1)
                            {
                                weakSelf.allowDownStr = @"1";
                                weakSelf.haveDetectedDownEnable = @"1";
                            }
                            if ([messegaDic[@"departstatus"] intValue] == 0) {
                                weakSelf.waitToAllow = @"1";
                                weakSelf.allowDownStr = @"0";
                                weakSelf.haveDetectedDownEnable = @"0";
                            }
                            //
                            
#ifdef DEBUG_MODE
                            NSLog(@"correct heartbeat");
#endif
                            
                        }
                        //组装需要发送的数据
                        weakSelf.finalDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.allowDownStr,@"allowDown",weakSelf.waitToAllow,@"waitToAllow", nil];
                        //发送通知到LogIn界面
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"allowDown" object:nil userInfo:weakSelf.finalDic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"readyDown" object:nil userInfo:@{@"readyDown":weakSelf.haveDetectedDownEnable}];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"whereToGo" object:nil userInfo:weakSelf.finalDic];
                    }
                    
                }failure:^(NSError *err){
                    NSLog(@"send heartBeat fail");
                    weakSelf.allowDownStr = @"0";
                    weakSelf.waitToAllow  = @"0";
                    weakSelf.finalDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.allowDownStr,@"allowDown",weakSelf.waitToAllow,@"waitToAllow", nil];
                    //发送通知到LogIn界面
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"allowDown" object:nil userInfo:weakSelf.finalDic];
                    
                }];
            });
            
            
        }
    });
    
}
//
-(BOOL)checkState
{
    NSLog(@"检测当前状态");
    
    return self.heartBeatTime.valid;
    
    
    
}










@end
