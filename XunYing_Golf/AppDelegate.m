//
//  AppDelegate.m
//  XunYing_Golf
//
//  Created by LiuC on 15/8/27.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "AppDelegate.h"
#import "DBCon.h"
#import "DataTable.h"
#import "XunYingPre.h"
#import "HttpTools.h"
#import "BLMessageProvider.h"
#import <CoreLocation/CoreLocation.h>
#import "HeartBeatAndDetectState.h"
#import "ChooseCreateGroupViewController.h"
#import "LogInViewController.h"
#import "UIDevice+IdentifierAddition.h"
#import "KeychainItemWrapper.h"
#import "GetRequestIPAddress.h"
#import "GetParagram.h"
#import "LogInViewController.h"
//#import <KSCrash/KSCrashInstallationStandard.h>
#import "MobClick.h"
#import "LogFilesProcess.h"


@interface AppDelegate ()<CLLocationManagerDelegate>
{
    NSTimer *backgroundTimer;
    //
    UIBackgroundTaskIdentifier m_taskID;
    BOOL                       m_bRun;
}
@property (strong, nonatomic) DBCon *dbCon;
@property (strong, nonatomic) DataTable *logInCount;
@property (nonatomic)         BOOL  changeState;

@property (strong, nonatomic) NSString *enableHeartBeat;
@property (strong, nonatomic) NSString *canEnterCreatGrp;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) KeychainItemWrapper *keychainWrapper;
//
@property (strong, nonatomic) UIImageView   *launchAnimateImage;
@property (strong, nonatomic) UIImageView   *subImage2;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //
//    KSCrashInstallationStandard* installation = [KSCrashInstallationStandard sharedInstance];
//    installation.url = [NSURL URLWithString:@"https://collector.bughd.com/kscrash?key=c223583ac200d9e06cb44050312b4771"];
//    [installation install];
//    [installation sendAllReportsWithCompletion:nil];
    
    //
    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy)REALTIME channelId:nil];
    //
    [self initLocalDB];
    // Override point for customization after application launch.
    _window = [[WINDOW_CLASS alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.dbCon = [[DBCon alloc]init];
    self.logInCount = [[DataTable alloc] init];
    //查询数据库
    self.logInCount = [self.dbCon ExecDataTable:@"select *from tbl_NamePassword"];
    
    //
    self.rootVC = [[LogInViewController alloc]init];
    self.rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
    self.window.rootViewController = self.rootVC;
    
    [self.window makeKeyAndVisible];
    
    if (self.logInCount.Rows.count) {
//        [self setLaunchAnimation];
    }
    //请求接口：是否可以建组，是否可以下场
    [self requestWhetherDownOrCreatGrp];
    //
    NSLog(@"%@",launchOptions);
    self.changeState = NO;
    
    if(ScreenHeight > 480)
    {
        self.autoSizeScaleX = ScreenWidth/320;
        self.autoSizeScaleY = ScreenHeight/568;
    }
    else
    {
        self.autoSizeScaleX = 1.0;
        self.autoSizeScaleY = 1.0;
    }
    //
    [self.dbCon ExecNonQuery:@"delete from tbl_uniqueID"];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"MY_APP_CREDENTIALS" accessGroup:nil];
    self.keychainWrapper = wrapper;
    //
    NSString *theResultKey;
    theResultKey = [self.keychainWrapper objectForKey:(id)kSecValueData];
    
    NSLog(@"theresult:%@",theResultKey);
    //tbl_uniqueID(uiniqueID text)
    if ((theResultKey != nil) && (![theResultKey  isEqual: @""])) {
        theResultKey = [theResultKey substringWithRange:NSMakeRange(0, 30)];
        NSLog(@"theresult:%@",theResultKey);
        NSMutableArray *uniqueIDArray = [[NSMutableArray alloc] initWithObjects:theResultKey, nil];
        [self.dbCon ExecNonQuery:@"insert into tbl_uniqueID(uiniqueID) values(?)" forParameter:uniqueIDArray];
    }
    else
    {
        [self.keychainWrapper setObject:@"MY_APP_CREDENTIALS" forKey:(id)kSecAttrService];
        [self.keychainWrapper setObject:[self gen_uuid] forKey:(id)kSecValueData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *theResultKey1;
            theResultKey1 = [self.keychainWrapper objectForKey:(id)kSecValueData];
            NSLog(@"theresult:%@",theResultKey1);
            //tbl_uniqueID(uiniqueID text)
            if ((theResultKey1 != nil) && (![theResultKey1  isEqual: @""])) {
                theResultKey1 = [theResultKey1 substringWithRange:NSMakeRange(0, 30)];
                NSLog(@"theresult:%@",theResultKey1);
                NSMutableArray *uniqueIDArray = [[NSMutableArray alloc] initWithObjects:theResultKey1, nil];
                [self.dbCon ExecNonQuery:@"insert into tbl_uniqueID(uiniqueID) values(?)" forParameter:uniqueIDArray];
            }
        });
        
    }
    
    UIDevice *device = [UIDevice currentDevice];
    
    if (![[device model] isEqualToString:@"iPhone Simulator"]) {
        //test
//        [LogFilesProcess redirectNSLogToDocument];
    }
    
    return YES;
}

- (void)setLaunchAnimation{
    self.launchAnimateImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.launchAnimateImage.image = [UIImage imageNamed:@"enterBackImage"];
    [self.window addSubview:self.launchAnimateImage];
    [self.window bringSubviewToFront:self.launchAnimateImage];
    //
    UIImageView *subImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenWidth/4, ScreenHeight/2 - ScreenWidth/4, ScreenWidth/2, ScreenWidth/2)];
    subImage1.image = [UIImage imageNamed:@"enter_image"];
    [self.launchAnimateImage addSubview:subImage1];
    //
    self.subImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenWidth/4, ScreenHeight/2 - ScreenWidth/4, ScreenWidth/2, ScreenWidth/2)];
    self.subImage2.image = [UIImage imageNamed:@"enter_circle"];
    [self.launchAnimateImage addSubview:self.subImage2];
    //
//    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(rotationTheSubImage2) userInfo:nil repeats:YES];
}

- (void)rotationTheSubImage2{
    static float angle;
    angle += 0.02;//angle角度 double angle;
    if (angle > 6.28) {//大于 M_PI*2(360度) 角度再次从0开始
        angle = 0;
    }
    CGAffineTransform transform=CGAffineTransformMakeRotation(angle);
    self.subImage2.transform = transform;
}
#pragma  -mark 请求是否可以建组，是否可以下场的接口
- (void)requestWhetherDownOrCreatGrp
{
    __weak typeof(self) weakSelf = self;
    //
    self.canEnterCreatGrp = @"0";
    self.enableHeartBeat  = @"0";
    //如果本地没有保存到登录人的账户，密码；则返回
    if (!self.logInCount.Rows.count) {
        return;
    }
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //获取到下场接口
    NSString *downFieldURLStr;
    downFieldURLStr = [GetRequestIPAddress getDecideCreateGrpAndDownFieldURL];
    //构建请求接口的参数 theMid,@"mid",logCaddyStr,@"username",password,@"pwd",@"0",@"panmull",@"0",@"forceLogin"
    NSMutableDictionary *theReqParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.logInCount.Rows[self.logInCount.Rows.count - 1][@"user"],@"username",self.logInCount.Rows[self.logInCount.Rows.count - 1][@"password"],@"pwd",@"0",@"panmull",@"0",@"forceLogin", nil];
    //开始接口请求
    [HttpTools getHttp:downFieldURLStr forParams:theReqParam success:^(NSData *nsData) {
        NSDictionary *recDic;
        recDic = (NSDictionary *)nsData;
        
        [weakSelf.launchAnimateImage removeFromSuperview];
//        [[NSTimer alloc] invalidate];
        
        if ([recDic[@"Code"] integerValue] > 0) {
            //对相应的数据进行保存,并执行通知
            [self.dbCon ExecDataTable:@"delete from tbl_groupInf"];
            [self.dbCon ExecDataTable:@"delete from tbl_holeInf"];
            [self.dbCon ExecDataTable:@"delete from tbl_CustomersInfo"];
            [self.dbCon ExecDataTable:@"delete from tbl_logPerson"];
            //
            NSString *value1;
            NSDictionary *allEmps;
            allEmps = recDic[@"Msg"];
            value1 = [allEmps objectForKey:@"logemp"];
            
            if (![value1  isEqual: @"null"]) {
                NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"logemp"][@"cadCode"],recDic[@"Msg"][@"logemp"][@"empcod"],recDic[@"Msg"][@"logemp"][@"empjob"],recDic[@"Msg"][@"logemp"][@"empnam"],recDic[@"Msg"][@"logemp"][@"empnum"],recDic[@"Msg"][@"logemp"][@"empsex"],recDic[@"Msg"][@"logemp"][@"cadShowNum"], nil];
                //将数据加载到创建的数据库中cadCode text,empCode
                [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(cadCode,empCode,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?,?)" forParameter:logPersonInf];
                self.canEnterCreatGrp = @"1";
                
            }
            //获取到球洞信息，并将相应的信息保存到内存中
            NSArray *allHolesInfo = recDic[@"Msg"][@"holes"];
            for (NSDictionary *eachHole in allHolesInfo) {
                NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachHole[@"forecasttime"],eachHole[@"gronum"],eachHole[@"holcod"],eachHole[@"holcue"],eachHole[@"holfla"],eachHole[@"holgro"],eachHole[@"holind"],eachHole[@"hollen"],eachHole[@"holnam"],eachHole[@"holnum"],eachHole[@"holspe"],eachHole[@"holsta"],eachHole[@"nowgroups"],eachHole[@"stan1"],eachHole[@"stan2"],eachHole[@"stan3"],eachHole[@"stan4"],eachHole[@"usestatus"],eachHole[@"x"],eachHole[@"y"],eachHole[@"coursegrouptag"], nil];
                [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y,coursegrouptag) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleParam];
            }
            //
            NSString *groupValue = [recDic[@"Msg"] objectForKey:@"group"];
            if([(NSNull *)groupValue isEqual: @"null"])//
            {
                //[self logIn];
            }
            else//
            {
                [self.dbCon ExecDataTable:@"delete from tbl_selectCart"];
                //获取到登录小组的所有客户的信息courseTag text
                NSArray *allCustomers = recDic[@"Msg"][@"group"][@"cuss"];
                for (NSDictionary *eachCus in allCustomers) {
                    NSMutableArray *eachCusParam = [[NSMutableArray alloc] initWithObjects:eachCus[@"bansta"],eachCus[@"bantim"],eachCus[@"cadcod"],eachCus[@"carcod"],eachCus[@"cuscod"],eachCus[@"cuslev"],eachCus[@"cusnam"],eachCus[@"cusnum"],eachCus[@"cussex"],eachCus[@"depsta"],eachCus[@"endtim"],eachCus[@"grocod"],eachCus[@"memnum"],eachCus[@"padcod"],eachCus[@"phone"],eachCus[@"statim"],recDic[@"Msg"][@"coursegrouptag"], nil];
                    [weakSelf.dbCon ExecNonQuery:@"insert into tbl_CustomersInfo(bansta,bantim,cadcod,carcod,cuscod,cuslev,cusnam,cusnum,cussex,depsta,endtim,grocod,memnum,padcod,phone,statim,courseTag) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachCusParam];
                }
                //将所选择的球车的信息保存下来
                //保存添加的球车的信息 tbl_selectCart(carcod text,carnum text,carsea text)
                NSArray *allSelectedCartsArray = recDic[@"Msg"][@"group"][@"cars"];
                for (NSDictionary *eachCart in allSelectedCartsArray) {
                    NSMutableArray *selectedCart = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
                    [weakSelf.dbCon ExecNonQuery:@"insert into tbl_selectCart(carcod,carnum,carsea) values(?,?,?)" forParameter:selectedCart];
                }
                //此处的数据还没有传递到需要的地方去
                //self.customerCount = [recDic[@"Msg"][@"group"][@"cuss"] count] - 1;
                //self.curHoleName = recDic[@"Msg"][@"group"][@"hgcod"];
                
                
                if(recDic[@"Msg"][@"group"][@"grocod"] != nil)
                {
                    NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"logemp"][@"cadCode"],recDic[@"Msg"][@"logemp"][@"empcod"],recDic[@"Msg"][@"logemp"][@"empjob"],recDic[@"Msg"][@"logemp"][@"empnam"],recDic[@"Msg"][@"logemp"][@"empnum"],recDic[@"Msg"][@"logemp"][@"empsex"],recDic[@"Msg"][@"logemp"][@"cadShowNum"], nil];
                    //将数据加载到创建的数据库中cadCode text,empCode
                    [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(cadCode,empCode,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?,?)" forParameter:logPersonInf];
                    //组建获取到的组信息的数组
                    NSMutableArray *groupInfArray = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"group"][@"grocod"],recDic[@"Msg"][@"group"][@"groind"],recDic[@"Msg"][@"group"][@"grolev"],recDic[@"Msg"][@"group"][@"gronum"],recDic[@"Msg"][@"group"][@"grosta"],recDic[@"Msg"][@"group"][@"hgcod"],recDic[@"Msg"][@"group"][@"onlinestatus"],recDic[@"Msg"][@"group"][@"createdate"],recDic[@"Msg"][@"group"][@"timestamps"], nil];
                    //将数据加载到创建的数据库中
                    //grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text
                    [weakSelf.dbCon ExecNonQuery:@"insert into  tbl_groupInf(grocod,groind,grolev,gronum,grosta,hgcod,onlinestatus,createdate,timestamps)values(?,?,?,?,?,?,?,?,?)" forParameter:groupInfArray];
                    //
                    self.enableHeartBeat = @"1";
                    self.canEnterCreatGrp = @"0";
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:@"allowDown" object:nil userInfo:@{@"allowDown":@"1"}];
                    
                    //weakSelf.haveGroupNotDown = YES;
                    
                    //
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [GetParagram getCustomInf];
                        [GetParagram getCaddyCartInf];
                    });
                    
                }
                else
                {
                    [weakSelf.dbCon ExecNonQuery:@"delete from tbl_taskInfo"];
                }
            }
            //执行通知
            NSDictionary *requestBackParam = [[NSDictionary alloc] initWithObjectsAndKeys:self.canEnterCreatGrp,@"enterCreateGrp",self.enableHeartBeat,@"enableHeartBeat", nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"canEnterCreatGrp" object:nil userInfo:requestBackParam];
        }
        else if ([recDic[@"Code"] integerValue] == -4){
            NSString *errStr;
            errStr = recDic[@"Msg"];
            UIAlertView *errAlertV = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [errAlertV show];
            //
            
        }
        else if ([recDic[@"Code"] integerValue] == -1){
            NSString *errStr;
            errStr = recDic[@"Msg"];
            UIAlertView *errAlertV = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [errAlertV show];
            //requestServerFail
            NSDictionary *requestBackParam = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"requestServerFail", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"canEnterCreatGrp" object:nil userInfo:requestBackParam];
        }
        else//否则提示错误信息
        {
            NSString *errStr;
            errStr = recDic[@"Msg"];
            UIAlertView *errAlertV = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [errAlertV show];
            //
            
        }
        
        
    } failure:^(NSError *err) {
        
        [weakSelf.launchAnimateImage removeFromSuperview];
        NSLog(@"网络请求失败");
        UIAlertView *errAlert = [[UIAlertView alloc] initWithTitle:@"网络请求失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [errAlert show];
        //
        NSDictionary *requestBackParam = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"requestServerFail", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"canEnterCreatGrp" object:nil userInfo:requestBackParam];
        
    }];
    
}


-(NSString *) gen_uuid
{
    CFUUIDRef uuid_ref=CFUUIDCreate(nil);
    CFStringRef uuid_string_ref;//=CFUUIDCreateString(nil, uuid_ref);
    uuid_string_ref=CFUUIDCreateString(nil, uuid_ref);
    NSString *uuid;//=[NSString stringWithString:(__bridge NSString * _Nonnull)(uuid_string_ref)];
    uuid=[NSString stringWithString:(__bridge NSString * _Nonnull)(uuid_string_ref)];
    NSLog(@"uuid:%@",uuid);
    //
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    
    return uuid;
}

- (void)setAnimation:(UIImageView *)nowView
{
//    [UIView animateWithDuration:0.6f animations:^{
//        // 执行的动画code
//        [nowView setFrame:CGRectMake(nowView.frame.origin.x- nowView.frame.size.width*0.1, nowView.frame.origin.y-nowView.frame.size.height*0.1, nowView.frame.size.width*1.2, nowView.frame.size.height*1.2)];
//        
//    }completion:^(BOOL isFinished){
//       //执行完成之后
//        [nowView removeFromSuperview];
//    }];
    //
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(M_PI / 180.0f);
    
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        nowView.transform = endAngle;
        
        
    } completion:^(BOOL finished) {
        if (finished) {
            
        }
        
    }];
    //
    [UIView animateWithDuration:0.6f animations:^{
        nowView.transform = endAngle;
    }completion:^(BOOL finished){
        
    }];
    
}

/**
 *  初始化本地数据库,数据库文件及列表
 */
-(void)initLocalDB{
    //初始化本地数据库
    DBCon *dbCon = [DBCon instance:@"ProDtata.db"];
    //
    [dbCon ExecDataTable:@"create table if not exists tbl_NamePassword(user text,password text,logOutOrNot text)"];
    
    //创建登录人信息列表 sex cadShowNum empcod empnam empnum empjob
    [dbCon ExecDataTable:@"create table if not exists tbl_logPerson(cadCode text,empCode text,job text,name text,number text,sex text,caddyLogIn text)"];
    //球洞信息
    [dbCon ExecDataTable:@"create table if not exists tbl_holeInf(forecasttime text,gronum text,holcod text,holcue text,holfla text,holgro text,holind text,hollen text,holnam text,holenum text,holspe text,holsta text,nowgroups text,stan1 text,stan2 text,stan3 text,stan4 text,usestatus text,x text,y text,coursegrouptag text)"];
    //其他球员的信息，用于通讯
    [dbCon ExecDataTable:@"create table if not exists tbl_EmployeeInf(empcod text,empjob text,empnam text,empnum text,empsex text,loctime text,online text,x text,y text)"];
    //获取到的消费卡号
    [dbCon ExecDataTable:@"create table if not exists tbl_CustomerNumbers(first text,second text,third text,fourth text)"];
    //所选择的球洞的信息，上九洞，下九洞，十八洞
    [dbCon ExecDataTable:@"create table if not exists tbl_threeTypeHoleInf(pdcod text,pdind text,pdnam text,pdpcod text,pdtag text,pdtcod text)"];
    //建组成功之后，获取到的组信息
    [dbCon ExecDataTable:@"create table if not exists tbl_groupInf(grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text,createdate text,timestamps text)"];
    //建组成功之后，获取返回的平板的信息
    [dbCon ExecDataTable:@"create table if not exists tbl_PadsInf(isprim text,locsta text,loctim text,onlsta text,padcod text,padnum text,padtag text,revx text,revy text)"];
    //获取到所有球童的信息
    [dbCon ExecDataTable:@"create table if not exists tbl_caddyInf(cadcod text,cadnam text,cadnum text,cadsex text,empcod text)"];
    //获取到所有球车的信息
    [dbCon ExecDataTable:@"create table if not exists tbl_cartInf(carcod text,carnum text,carsea text)"];
    //当前创建的小组所选择的球车
    [dbCon ExecDataTable:@"create table if not exists tbl_selectCart(carcod text,carnum text,carsea text)"];
    //当前所创建的小组所添加的球童
    [dbCon ExecDataTable:@"create table if not exists tbl_addCaddy(cadcod text,cadnam text,cadnum text,cadsex text,empcod text)"];
    //获取心跳中的组信息
    /*
     grocod:小组编码
     pladur:打球时长
     stddur:标准完成时长
     grosta:小组状态0正常 1较慢 2慢 3前方有慢组 4球洞较慢 5球洞慢
     statim:下场时间
     stahol:开始球洞编码
     nowholcod:当前所在球洞系统编码
     nowholnum:当前所在球洞系统编号
     nextgrodistime
     nowblocks:所在球洞段号：1发球台 2球道 3果岭
     hgcod:球洞组（上九洞，下九洞，十八洞）
     */
    [dbCon ExecDataTable:@"create table if not exists tbl_groupHeartInf(grocod text,grosta text,nextgrodistime text,nowblocks text,nowholcod text,nowholnum text,pladur text,stahol text,statim text,stddur text,coursegrouptag text)"];
    //心跳中显示的当前的定位位置
    [dbCon ExecDataTable:@"create table if not exists tbl_locHole(holcod text,holnum text)"];
    //获取到移动设备的信息
    [dbCon ExecDataTable:@"create table if not exists tbl_padInfo(padcod text,padnum text,padtag text)"];
    //球洞规划组对象
    [dbCon ExecDataTable:@"create table if not exists tbl_holePlanInfo(ghcod text,ghind text,ghsta text,grocod text,gronum text,holcod text,holnum text,pintim text,pladur text,poutim text,rintim text,routim text,stadur text)"];
    //客户组对象
    [dbCon ExecDataTable:@"create table if not exists tbl_CusGroInf(grocod text,grosta text,nextgrodistime text,nowblocks text,nowholcod text,nowholnum text,pladur text,stahol text,statim text,stddur text)"];
    //当前所创建的小组的顾客的信息
    [dbCon ExecDataTable:@"create table if not exists tbl_CustomersInfo(bansta text,bantim text,cadcod text,carcod text,cuscod text,cuslev text,cusnam text,cusnum text,cussex text,depsta text,endtim text,grocod text,memnum text,padcod text,phone text,statim text,courseTag text)"];
    //事件处理的信息
    [dbCon ExecDataTable:@"create table if not exists tbl_taskChangeCartInfo(evecod text,evesta text,subtim text,oldCartNum text,oldCartCode text,newCartNum text,newCartCode text,result text,everea text)"];
    [dbCon ExecDataTable:@"create table if not exists tbl_taskChangeCaddyInfo(evecod text,everea text,result text,evesta text,oldCaddy text,oldCaddyCode text,newCaddy text,newCaddyCode,subtim text)"];
    [dbCon ExecDataTable:@"create table if not exists tbl_taskJumpHoleInfo(evecod text,everea text,result text,evesta text,jumpHoleCode text,jumpHoleNum text,toHoleCode text,toHoleNum text,subtim text)"];
    [dbCon ExecDataTable:@"create table if not exists tbl_taskLeaveRest(evecod text,everea text,result text,evesta text,subtim text,hantim text,reholeCode text)"];
    [dbCon ExecDataTable:@"create table if not exists tbl_taskMendHoleInfo(evecod text,everea text,result text,evesta text,subtim text,mendHoleNum text)"];
    
    [dbCon ExecDataTable:@"create table if not exists tbl_taskInfo(evecod text,evetyp text,evesta text,subtim text,result text,everea text,hantim text,oldCaddyCode text,oldcadnum text,oldcadnam text,oldcadempcod text,newCaddyCode text,newcadnum text,newcadnam text,newcadempcod text,oldCartCode text,oldcarnum text,oldcarsea text,newCartCode text,newcarnum text,newcarsea text,jumpHoleCode text,toHoleCode text,destintime text,reqBackTime text,reHoleCode text,mendHoleCode text,ratifyHoleCode text,ratifyinTime text,selectedHoleCode text)"];
    //设置界面中的，心跳间隔，IP地址，端口号
    [dbCon ExecDataTable:@"create table if not exists tbl_SettingInfo(interval text,ipAddr text,portNum text)"];
    //保存ID号
    [dbCon ExecDataTable:@"create table if not exists tbl_uniqueID(uiniqueID text)"];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    //实现方案一（该方案的缺点是：在手机插上电源的时候可以很好的保持后台发送心跳）
//    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
//    backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(timer) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:backgroundTimer forMode: NSRunLoopCommonModes];
    //实现方案二（目前还在试验中20151030）
    __weak typeof(self) weakSelf = self;
    
//    [self registerBackgroundTask];
    self.changeState = YES;
    //
    __block UIBackgroundTaskIdentifier bgTask;
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(bgTask != UIBackgroundTaskInvalid)
                bgTask = UIBackgroundTaskInvalid;
            //通过判断是否还有组信息来确定是否已经下场，若没有组信息则不启动心跳
            DataTable *grpInf;// = [[DataTable alloc] init];
            grpInf = [weakSelf.dbCon ExecDataTable:@"select *from tbl_groupInf"];
            
            NSLog(@"background1,baIdentifier:%lu",(unsigned long)bgTask);
            if (![grpInf.Rows count]) {
                grpInf = nil;
                return ;
            }
            grpInf = nil;
            //重启心跳服务
            HeartBeatAndDetectState *backGroundHeartbeat = [[HeartBeatAndDetectState alloc] init];
            [backGroundHeartbeat initHeartBeat];
            [backGroundHeartbeat enableHeartBeat];
            
        });
        
        NSLog(@"background2");
        
    }];
    //
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
           if(bgTask != UIBackgroundTaskInvalid)
               bgTask = UIBackgroundTaskInvalid;
            NSLog(@"background3");
        });
        NSLog(@"background4");
    });
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [backgroundTimer invalidate];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"已经进入前台，激活");
    //重启心跳服务
//    if(self.changeState)
//    {
//        HeartBeatAndDetectState *backGroundHeartbeat = [[HeartBeatAndDetectState alloc] init];
//        [backGroundHeartbeat initHeartBeat];
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"app 终止");
}










//
-(void)getLocation{
    if(nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

//
-(void)timer
{
    [self getLocation];
}
#pragma -mark CLLocation Delegate Methods
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"err:%@",error);
}
//
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    
    //
    NSString *longitude = [NSString stringWithFormat:@"%+.6f",location.coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%+.6f",location.coordinate.latitude];
    [[BLMessageProvider sharedProvider] sendLocation:longitude latitude:latitude applicationState:@"background"];
}

//判断设备是否支持后台任务
-(BOOL)isMultitaskingSupported{
    BOOL bResult = NO;
    
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        bResult = [[UIDevice currentDevice] isMultitaskingSupported];
    }
    return bResult;
}
//启动后台任务,并记录ID
-(void)startbackgroundTask{
    NSLog(@"startbackgroundTask");
    
    
    __weak AppDelegate *weakSelf = self;
    m_taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [weakSelf restartbackgroundTask];
        
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf bgTask:m_taskID];
    });
}
-(void)bgTask:(UIBackgroundTaskIdentifier)taskId
{
    while (m_bRun) {
        if(m_taskID != taskId)
        {
            break;
        }
        NSLog(@"this is background execute, taskID:%lu",(unsigned long)taskId);
        usleep(3 * 1000);
    }
}



//重启后台任务，由于iOS后台任务都是有实效性的，最长时3min，然后将会被系统回收，所以需要一个函数来重启任务
-(void)restartbackgroundTask
{
    NSLog(@"stop backgroundTask");
    
    //save old task id
    UIBackgroundTaskIdentifier taskId = m_taskID;
    m_taskID = UIBackgroundTaskInvalid;
    
    //start new task
    [self startbackgroundTask];
    
    //stop old task
    [[UIApplication sharedApplication] endBackgroundTask:taskId];
}
//注册后台任务，这是函数的唯一入口函数，在applicationDidEnterBackground中调用，用于app在推出时，启动后台任务
-(void)registerBackgroundTask
{
    if([self isMultitaskingSupported] == NO)
    {
        NSLog(@"Don't support multiTask");
        return;
    }
    //the background has been run,and is not allowed to run again
    if(m_bRun)
    {
        NSLog(@"task has been running");
        return;
    }
    
    m_bRun = YES;
    
    __weak AppDelegate *weakSelf = self;
    
//    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
//        [weakSelf restartbackgroundTask];
//    }];
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [weakSelf restartbackgroundTask];
    }];
    
    [self startbackgroundTask];
}
//唯一的出口函数,在需要结束后台任务的时候，调用该函数来结束后台任务
-(void)unregisterBackgroundTask
{
    if(m_bRun)
    {
        NSLog(@"task has been stoping");
        return;
    }
    
    m_bRun = NO;
    [[UIApplication sharedApplication] endBackgroundTask:m_taskID];
    m_taskID = UIBackgroundTaskInvalid;
}





@end


