//
//  LogInViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/7.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "LogInViewController.h"
#import "DBCon.h"
#import "HttpTools.h"
#import "ActivityIndicatorView.h"
#import "UIColor+UICon.h"
#import "ViewController.h"
#import "MainViewController.h"
#import "Reachability.h"
#import "HeartBeatAndDetectState.h"
#import "passValueLogInDelegate.h"
#import "AppDelegate.h"
#import "GetRequestIPAddress.h"
#import "AFHTTPRequestOperationManager.h"
//#import "GpsLocation.h"

extern NSString *CTSettingCopyMyPhoneNumber();
//extern BOOL allowDownCourt;

@interface LogInViewController ()<UIGestureRecognizerDelegate,UITextFieldDelegate>

//@property(strong, nonatomic) ActivityIndicatorView *activityView;
@property (nonatomic) BOOL forgetCode;
@property (nonatomic) BOOL remCode;

@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) Reachability *wifiReachability;
@property (strong, nonatomic) Reachability *hostReachability;
@property (nonatomic) NetworkStatus curNetworkStatus;
@property (strong, nonatomic) UIAlertView *forceLogInAlert;
@property (strong, nonatomic) NSMutableDictionary *logInParams;
@property (strong, nonatomic)NSMutableDictionary *checkCreatGroupState;

@property (strong, nonatomic)UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic)           BOOL    canReceiveNotification;
//
@property (strong, nonatomic) DBCon *dbCon;
@property (strong, nonatomic) DataTable *logInPerson;
@property (strong, nonatomic) DataTable *logPersonInf;


@property (strong, nonatomic) AFHTTPRequestOperationManager *requestManager;

@property (strong, nonatomic) IBOutlet UITextField *account;

@property (strong, nonatomic) IBOutlet UITextField *password;

@property (nonatomic) BOOL haveGroupNotDown;
@property (nonatomic) BOOL showNetWorkErr;


- (IBAction)logInButton:(UIButton *)sender;
- (IBAction)forgetPassword:(UIButton *)sender;
- (IBAction)settingIPAddr:(UIBarButtonItem *)sender;




@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap:)];
    self.tap.delegate = self;
    [self.view addGestureRecognizer:self.tap];
    
    //init activityIndicatorView
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 100, ScreenHeight/2 - 100, 200, 200)];
    self.activityIndicatorView.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.2];
    self.activityIndicatorView.layer.cornerRadius = 20;
    
    [self.view addSubview:self.activityIndicatorView];
    
    self.activityIndicatorView.hidden = YES;
    
    //init and alloc dbCon
    self.dbCon = [[DBCon alloc] init];
    //
    self.logInPerson = [[DataTable alloc] init];
    self.logPersonInf = [[DataTable alloc] init];
    //
    self.showNetWorkErr = YES;
    //
#ifdef DEBUG_MODE
    NSLog(@"logPersonInf:%@",self.logInPerson);
#endif
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canDownCourt:) name:@"allowDown" object:nil];
    //
    self.forceLogInAlert = [[UIAlertView alloc]initWithTitle:@"是否强制登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.forceLogInAlert.tag = 1;
    //
    self.password.borderStyle   = UITextBorderStyleNone;
    self.account.borderStyle    = UITextBorderStyleNone;
    self.password.delegate      = self;
    self.account.delegate       = self;
    //
    self.canReceiveNotification = NO;
    //
    self.requestManager = [[AFHTTPRequestOperationManager alloc] init];
    //
    [self settingNetWork];
    //
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, period * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"enter dispatch_timer test");
    });
    dispatch_resume(timer);
    
}

- (void)settingNetWork
{
    //添加网络状态监测初始化设置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentNetworkState:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    //
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
}

-(void)canDownCourt:(NSNotification *)sender
{
//    NSLog(@"sender:%@",sender);
    if (!self.canReceiveNotification) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //
    if ([sender.userInfo[@"allowDown"] isEqualToString:@"1"]) {
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        //检查心跳是否在继续
//        HeartBeatAndDetectState *heartBeat = [[HeartBeatAndDetectState alloc]init];
//        [heartBeat initHeartBeat];
//        [heartBeat enableHeartBeat];
        //
        [self performSegueWithIdentifier:@"ToMainMapView" sender:nil];
    }
    else if([sender.userInfo[@"waitToAllow"] isEqualToString:@"1"])
    {
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        [self performSegueWithIdentifier:@"shouldWaitToAllow" sender:nil];
    }
    //若没有退出则直接跳转到建组方式的界面（手动，二维码等）
    else if([self.logInPerson.Rows count]) {
        [self checkCurStateOnServer];
        if([self.logInPerson.Rows[[self.logInPerson.Rows count] - 1][@"logOutOrNot"] boolValue])
        {
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
            //
            [self performSegueWithIdentifier:@"jumpToCreateGroup" sender:nil];
        }
    }

}

#pragma -mark currentNetworkState
-(void)currentNetworkState:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    //
    [self checkNetworkState:curReach];
}
#pragma -mark checkNetworkState
-(void)checkNetworkState:(Reachability *)reachability
{
    
    //wifi state
    Reachability *wifiState = [Reachability reachabilityForLocalWiFi];
    //监测手机上能否上网络（wifi/3G/2.5G）
    Reachability *connectState = [Reachability reachabilityForInternetConnection];
    //判断网络状态
    if([wifiState currentReachabilityStatus] != NotReachable)
    {
//        self.showNetWorkErr = NO;
        NSLog(@"连接上了WI-FI");
        self.curNetworkStatus = ReachableViaWiFi;
    }
    else if([connectState currentReachabilityStatus] != NotReachable)
    {
//        self.showNetWorkErr = NO;
        NSLog(@"使用自己的手机上的蜂窝网络进行上网");
        self.curNetworkStatus = ReachableViaWWAN;
    }
    else
    {
        NSLog(@"没有网络");
        self.curNetworkStatus = NotReachable;
        //
        if (self.showNetWorkErr) {
            self.showNetWorkErr = NO;
            //
            UIAlertView *netWorkAlert = [[UIAlertView alloc] initWithTitle:@"网络连接异常,请检查网络设置" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [netWorkAlert show];
        }
    }
}
#pragma -mark updateInterfaceWithReachability
-(NetworkStatus)updateInterfaceWithReachability:(Reachability *)curReach
{
    self.curNetworkStatus = [curReach currentReachabilityStatus];
    
    return self.curNetworkStatus;
}


-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

//-(NSInteger)application

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //
    [self.view removeGestureRecognizer:self.tap];
    //
#ifdef DEBUG_MODE
    NSLog(@"holeType:%@  holeCount:%ld",self.curHoleName,(long)self.customerCount);
#endif
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //research the logPerson's information
    self.logInPerson = [self.dbCon ExecDataTable:@"select *from tbl_NamePassword"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.logInPerson.Rows count])
        {
            self.account.text = self.logInPerson.Rows[[self.logInPerson.Rows count] - 1][@"user"];
            self.password.text = self.logInPerson.Rows[[self.logInPerson.Rows count] -1][@"password"];
            //检查当前的状态 暂时把自动登录功能屏蔽掉
            //        [self checkCurStateOnServer];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    });
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canDownCourt:) name:@"allowDown" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view addGestureRecognizer:self.tap];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    self.navigationController.navigationBarHidden = NO;
}


/**
 *  忘记密码
 *
 *  @param sender 对应的按键信息
 */
- (IBAction)forgetPassword:(UIButton *)sender {
//    NSLog(@"forgetPassword");
    //
    if(!self.forgetCode){
        self.forgetCode = YES;
        //change image
        [sender setImage:[UIImage imageNamed:@"logInUnselected.png"] forState:UIControlStateNormal];
    }
    else{
        self.forgetCode = NO;
        //change image
        [sender setImage:[UIImage imageNamed:@"logInSelected.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)settingIPAddr:(UIBarButtonItem *)sender {
    self.activityIndicatorView.hidden = YES;
    
    [self performSegueWithIdentifier:@"settingIPAddress" sender:nil];
}

#pragma -mark getCaddyCartInf
-(void)getCaddyCartInf
{
//    NSLog(@"enter getCaddyCartInf");
    __weak typeof(self) wealSelf = self;
    //删除保存在内存中的以前的数据
    //前九洞，后九洞，十八洞
    [self.dbCon ExecNonQuery:@"delete from tbl_threeTypeHoleInf"];
    [self.dbCon ExecNonQuery:@"delete from tbl_cartInf"];
    [self.dbCon ExecNonQuery:@"delete from tbl_caddyInf"];
    //获取到URL
    NSString *caddyCartURLStr;
    caddyCartURLStr = [GetRequestIPAddress getCaddyCartInfURL];
    
    dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC ) ;
    dispatch_after(time, dispatch_get_main_queue(), ^{
        //start request
        [HttpTools getHttp:caddyCartURLStr forParams:nil success:^(NSData *nsData){
            //        NSLog(@"successfully request");
//            NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *receiveDic;
            receiveDic = (NSDictionary *)nsData;
#ifdef DEBUG_MODE
            NSLog(@"caddy count:%ld",[receiveDic[@"Msg"][@"caddys"] count]);
#endif
            //获取到当前的球车
            NSArray *allCarts = receiveDic[@"Msg"][@"carts"];
            //        NSDictionary *oneCart = [[NSDictionary alloc] init];
            for (NSDictionary *eachCart in allCarts) {
                NSMutableArray *eachCartParam = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
                //tbl_cartInf(carcod text,carnum text,carsea text)
                [wealSelf.dbCon ExecNonQuery:@"insert into tbl_cartInf(carcod,carnum,carsea) values(?,?,?)" forParameter:eachCartParam];
            }
            //保存所有可用球童的信息
            NSArray *allCaddies = receiveDic[@"Msg"][@"caddys"];
            for (NSDictionary *eachCaddy in allCaddies) {
                NSMutableArray *eachCaddyParam = [[NSMutableArray alloc] initWithObjects:eachCaddy[@"cadcod"],eachCaddy[@"cadnam"],eachCaddy[@"cadnum"],eachCaddy[@"cadsex"],eachCaddy[@"empcod"], nil];
                //tbl_caddyInf(cadcod text,cadnam text,cadnum text,cadsex text,empcod text)
                [self.dbCon ExecNonQuery:@"insert into tbl_caddyInf(cadcod,cadnam,cadnum,cadsex,empcod) values(?,?,?,?,?)" forParameter:eachCaddyParam];
            }
            
            //保存三种类型的球洞的参数
            NSArray *allHoles = receiveDic[@"Msg"][@"holes"];
            for (NSDictionary *eachTypeHole in allHoles) {
                NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachTypeHole[@"pdcod"],eachTypeHole[@"pdind"],eachTypeHole[@"pdnam"],eachTypeHole[@"pdpcod"],eachTypeHole[@"pdtag"],eachTypeHole[@"pdtcod"], nil];
                [self.dbCon ExecNonQuery:@"insert into tbl_threeTypeHoleInf(pdcod,pdind,pdnam,pdpcod,pdtag,pdtcod) values(?,?,?,?,?,?)" forParameter:eachHoleParam];
            }
            //执行查询数据库中的参数的例子
            //    DataTable *table = [[DataTable alloc] init];
            //    table = [dbCon ExecDataTable:@"select *from tbl_logPerson"];
            //    NSLog(@"Table.Rows[0]:%@",table.Rows[0][@"code"]);
//            DataTable *threeHolesInf;// = [[DataTable alloc]init];
//            threeHolesInf = [self.dbCon ExecDataTable:@"select *from tbl_threeTypeHoleInf"];
            //NSLog(@"top9:%@\n down9:%@\n all:%@",threeHolesInf.Rows[0],threeHolesInf.Rows[1],threeHolesInf.Rows[2]);
            //        NSLog(@"holeInf:%@",threeHolesInf);
            //NSLog(@"end store the three holes information");
            
            
            
        }failure:^(NSError *err){
#ifdef DEBUG_MODE
            NSLog(@"caddyCartInf request failed");
#endif
            
        }];
    });
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//    });
    
}
#pragma -mark getCustomInf
-(void)getCustomInf
{
//    NSLog(@"enter getCustomInf");
    __weak typeof(self) weakSelf = self;
    
    //delete the old data in the database
    [self.dbCon ExecNonQuery:@"delete from tbl_CustomerNumbers"];
    
    //
    NSString *customURLStr;
    customURLStr = [GetRequestIPAddress getCustomInfURL];
    
    dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC ) ;
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        //start request
        [HttpTools getHttp:customURLStr forParams:nil success:^(NSData *nsData){
#ifdef DEBUG_MODE
            NSLog(@"request successfully");
#endif
//            NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *receiveDic;
            receiveDic = (NSDictionary *)nsData;
            //
            NSString *cusNumberString;// = [[NSString alloc] init];
            cusNumberString = receiveDic[@"Msg"];
            NSArray *cusNumberArray = [cusNumberString componentsSeparatedByString:@";"];//拆分接收到的数据
            //将数据加载到创建的数据库中
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //first text,second text,third text,fourth text
            [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_CustomerNumbers(first,second,third,fourth) VALUES(?,?,?,?)" forParameter:(NSMutableArray *)cusNumberArray];
            //            });
            
            
        }failure:^(NSError *err){
#ifdef DEBUG_MODE
            NSLog(@"request fail");
#endif
            
        }];
    });
//    dispatch_sync( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
//        
//    });
    
}


-(void)backgroundTap:(id)sender
{
    //NSLog(@"enter backgroundTap");
    [self.account resignFirstResponder];
    [self.password resignFirstResponder];
}
#pragma -mark forceLogInAlert
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __weak LogInViewController *weakSelf = self;
    
    NSString *theMid;
    //
    if(alertView.tag == 1)
    {
        switch (buttonIndex) {
            case 0:
#ifdef DEBUG_MODE
                NSLog(@"取消强制登录");
#endif
                //关闭activityIndicator
                [self.activityIndicatorView stopAnimating];
                self.activityIndicatorView.hidden = YES;
                
                break;
            case 1:
#ifdef DEBUG_MODE
                NSLog(@"执行强制登录");
#endif
                //调用强制登录接口
                //获取到mid号码
                theMid = [GetRequestIPAddress getUniqueID];
                theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
                //修改强制登录的参数为1
                NSMutableDictionary *forceLogInParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.account.text,@"username",self.password.text,@"pwd",@"1",@"panmull",@"1",@"forceLogin", nil];
                //调用接口进行传参数
                [HttpTools getHttp:[self getTheSettingIP] forParams:forceLogInParam success:^(NSData *nsData){
#ifdef DEBUG_MODE
                    NSLog(@"成功强制登录");
#endif
                    //
//                    NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
                    NSDictionary *recDic;
                    recDic = (NSDictionary *)nsData;
#ifdef DEBUG_MODE
                    NSLog(@"msg:%@",recDic[@"Msg"]);
#endif
                    //创建登录人信息数组
                    //1sex cadShowNum 1empcod 1empnam 1empnum 1empjob
                    //code text,job text,name text,number text,sex text,caddyLogIn text
                    if ([recDic[@"Code"] intValue] > 0) {
                        
                        //
                        [self.dbCon ExecDataTable:@"delete from tbl_CustomersInfo"];
                        [self.dbCon ExecDataTable:@"delete from tbl_selectCart"];
                        [self.dbCon ExecDataTable:@"delete from tbl_addCaddy"];
                        //获取到登录小组的所有客户的信息
                        NSString *value;
                        value = [NSString stringWithFormat:@"%@",recDic[@"Msg"][@"group"]];
                        if (![value isEqualToString:@"null"]) {
                            NSArray *allCustomers = recDic[@"Msg"][@"group"][@"cuss"];
                            for (NSDictionary *eachCus in allCustomers) {
                                NSMutableArray *eachCusParam = [[NSMutableArray alloc] initWithObjects:eachCus[@"bansta"],eachCus[@"bantim"],eachCus[@"cadcod"],eachCus[@"carcod"],eachCus[@"cuscod"],eachCus[@"cuslev"],eachCus[@"cusnam"],eachCus[@"cusnum"],eachCus[@"cussex"],eachCus[@"depsta"],eachCus[@"endtim"],eachCus[@"grocod"],eachCus[@"memnum"],eachCus[@"padcod"],eachCus[@"phone"],eachCus[@"statim"], nil];
                                [weakSelf.dbCon ExecNonQuery:@"insert into tbl_CustomersInfo(bansta,bantim,cadcod,carcod,cuscod,cuslev,cusnam,cusnum,cussex,depsta,endtim,grocod,memnum,padcod,phone,statim) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachCusParam];
                            }
                            //保存添加的球车的信息 tbl_selectCart(carcod text,carnum text,carsea text)
                            NSArray *allSelectedCartsArray = recDic[@"Msg"][@"group"][@"cars"];
                            for (NSDictionary *eachCart in allSelectedCartsArray) {
                                NSMutableArray *selectedCart = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
                                [weakSelf.dbCon ExecNonQuery:@"insert into tbl_selectCart(carcod,carnum,carsea) values(?,?,?)" forParameter:selectedCart];
                            }
                            //保存添加的球童的信息 tbl_addCaddy(cadcod text,cadnam text,cadnum text,cadsex text,empcod text)
                            NSArray *allSelectedCaddiesArray = recDic[@"Msg"][@"group"][@"cads"];
                            for (NSDictionary *eachCaddy in allSelectedCaddiesArray) {
                                NSMutableArray *selectedCaddy = [[NSMutableArray alloc] initWithObjects:eachCaddy[@"cadcod"],eachCaddy[@"cadnam"],eachCaddy[@"cadnum"],eachCaddy[@"cadsex"],eachCaddy[@"empcod"], nil];
                                [weakSelf.dbCon ExecNonQuery:@"insert into tbl_addCaddy(cadcod,cadnam,cadnum,cadsex,empcod) values(?,?,?,?,?)" forParameter:selectedCaddy];
                            }
                        }
                        //
                        NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"logemp"][@"empcod"],recDic[@"Msg"][@"logemp"][@"empjob"],recDic[@"Msg"][@"logemp"][@"empnam"],recDic[@"Msg"][@"logemp"][@"empnum"],recDic[@"Msg"][@"logemp"][@"empsex"],recDic[@"Msg"][@"logemp"][@"cadShowNum"], nil];
                        //将数据加载到创建的数据库中
                        [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
                        //
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //进入建组界面，发送获取参数（球童，球车，球场的球洞），之后发送
                            [weakSelf getCaddyCartInf];
                            //获取客户信息
                            [weakSelf getCustomInf];
                            //关闭activityIndicator
//                            [weakSelf.activityIndicatorView stopAnimating];
//                            weakSelf.activityIndicatorView.hidden = YES;
                            //
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSString *value;
                                NSDictionary *msgDic = recDic[@"Msg"];
                        
                                value = [NSString stringWithFormat:@"%@",[msgDic objectForKey:@"group"]];
                                
                                if([value isEqualToString:@"null"])
                                    [weakSelf performSegueWithIdentifier:@"jumpToCreateGroup" sender:nil];
                                else
                                {
                                    //获取到球洞信息，并将相应的信息保存到内存中
                                    NSArray *allHolesInfo = recDic[@"Msg"][@"holes"];
                                    for (NSDictionary *eachHole in allHolesInfo) {
                                        NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachHole[@"forecasttime"],eachHole[@"gronum"],eachHole[@"holcod"],eachHole[@"holcue"],eachHole[@"holfla"],eachHole[@"holgro"],eachHole[@"holind"],eachHole[@"hollen"],eachHole[@"holnam"],eachHole[@"holnum"],eachHole[@"holspe"],eachHole[@"holsta"],eachHole[@"nowgroups"],eachHole[@"stan1"],eachHole[@"stan2"],eachHole[@"stan3"],eachHole[@"stan4"],eachHole[@"usestatus"],eachHole[@"x"],eachHole[@"y"], nil];
                                        [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleParam];
                                    }
                                    
                                    //保存组信息相关的参数
                                    [self.dbCon ExecDataTable:@"delete from tbl_selectCart"];
                                    //获取到登录小组的所有客户的信息
                                    NSArray *allCustomers = recDic[@"Msg"][@"group"][@"cuss"];
                                    for (NSDictionary *eachCus in allCustomers) {
                                        NSMutableArray *eachCusParam = [[NSMutableArray alloc] initWithObjects:eachCus[@"bansta"],eachCus[@"bantim"],eachCus[@"cadcod"],eachCus[@"carcod"],eachCus[@"cuscod"],eachCus[@"cuslev"],eachCus[@"cusnam"],eachCus[@"cusnum"],eachCus[@"cussex"],eachCus[@"depsta"],eachCus[@"endtim"],eachCus[@"grocod"],eachCus[@"memnum"],eachCus[@"padcod"],eachCus[@"phone"],eachCus[@"statim"], nil];
                                        [weakSelf.dbCon ExecNonQuery:@"insert into tbl_CustomersInfo(bansta,bantim,cadcod,carcod,cuscod,cuslev,cusnam,cusnum,cussex,depsta,endtim,grocod,memnum,padcod,phone,statim) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachCusParam];
                                    }
                                    //将所选择的球车的信息保存下来
                                    //保存添加的球车的信息 tbl_selectCart(carcod text,carnum text,carsea text)
                                    NSArray *allSelectedCartsArray = recDic[@"Msg"][@"group"][@"cars"];
                                    for (NSDictionary *eachCart in allSelectedCartsArray) {
                                        NSMutableArray *selectedCart = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
                                        [weakSelf.dbCon ExecNonQuery:@"insert into tbl_selectCart(carcod,carnum,carsea) values(?,?,?)" forParameter:selectedCart];
                                    }
                                    //此处的数据还没有传递到需要的地方去
                                    self.customerCount = [recDic[@"Msg"][@"group"][@"cuss"] count] - 1;
                                    self.curHoleName = recDic[@"Msg"][@"group"][@"hgcod"];
                                    //
                                    if(recDic[@"Msg"][@"group"][@"grocod"] != nil)
                                    {
                                        NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"logemp"][@"empcod"],recDic[@"Msg"][@"logemp"][@"empjob"],recDic[@"Msg"][@"logemp"][@"empnam"],recDic[@"Msg"][@"logemp"][@"empnum"],recDic[@"Msg"][@"logemp"][@"empsex"],recDic[@"Msg"][@"logemp"][@"cadShowNum"], nil];
                                        //将数据加载到创建的数据库中
                                        [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
                                        //组建获取到的组信息的数组
                                        NSMutableArray *groupInfArray = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"group"][@"grocod"],recDic[@"Msg"][@"group"][@"groind"],recDic[@"Msg"][@"group"][@"grolev"],recDic[@"Msg"][@"group"][@"gronum"],recDic[@"Msg"][@"group"][@"grosta"],recDic[@"Msg"][@"group"][@"hgcod"],recDic[@"Msg"][@"group"][@"onlinestatus"],recDic[@"Msg"][@"group"][@"createdate"],recDic[@"Msg"][@"group"][@"timestamps"], nil];
                                        //将数据加载到创建的数据库中
                                        //grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text
                                        [weakSelf.dbCon ExecNonQuery:@"insert into  tbl_groupInf(grocod,groind,grolev,gronum,grosta,hgcod,onlinestatus,createdate,timestamps)values(?,?,?,?,?,?,?,?,?)" forParameter:groupInfArray];
                                        //
                                        //删除之前保存的数据
                                        [self.dbCon ExecNonQuery:@"delete from tbl_groupHeartInf"];
                                        //
                                        NSMutableArray *cusGrpArray = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"group"][@"grocod"],recDic[@"Msg"][@"group"][@"grosta"],recDic[@"Msg"][@"group"][@"nextgrodistime"],recDic[@"Msg"][@"group"][@"nowblocks"],recDic[@"Msg"][@"group"][@"nowholcod"],recDic[@"Msg"][@"group"][@"nowholnum"],recDic[@"Msg"][@"group"][@"pladur"],recDic[@"Msg"][@"group"][@"stahol"],recDic[@"Msg"][@"group"][@"statim"],recDic[@"Msg"][@"group"][@"stddur"], nil];
                                        [weakSelf.dbCon ExecNonQuery:@"insert into tbl_groupHeartInf(grocod,grosta,nextgrodistime,nowblocks,nowholcod,nowholnum,pladur,stahol,statim,stddur) values(?,?,?,?,?,?,?,?,?,?)" forParameter:cusGrpArray];
                                        
                                        //                    DataTable *table;// = [[DataTable alloc] init];
                                        //
                                        //                    table = [strongSelf.dbCon ExecDataTable:@"select *from tbl_groupInf"];
                                        //                    NSLog(@"table:%@",table);
                                        //
                                        HeartBeatAndDetectState *heartBeat = [[HeartBeatAndDetectState alloc] init];
                                        if(![heartBeat checkState])
                                        {
                                            [heartBeat initHeartBeat];//启动心跳服务
                                            [heartBeat enableHeartBeat];
                                        }
                                        //                    [[NSNotificationCenter defaultCenter] postNotificationName:@"allowDown" object:nil userInfo:@{@"allowDown":@"1"}];
                                        
                                        weakSelf.haveGroupNotDown = YES;
                                        //获取到球洞信息，并将相应的信息保存到内存中
                                        NSArray *allHolesInfo = recDic[@"Msg"][@"holes"];
                                        for (NSDictionary *eachHole in allHolesInfo) {
                                            NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachHole[@"forecasttime"],eachHole[@"gronum"],eachHole[@"holcod"],eachHole[@"holcue"],eachHole[@"holfla"],eachHole[@"holgro"],eachHole[@"holind"],eachHole[@"hollen"],eachHole[@"holnam"],eachHole[@"holnum"],eachHole[@"holspe"],eachHole[@"holsta"],eachHole[@"nowgroups"],eachHole[@"stan1"],eachHole[@"stan2"],eachHole[@"stan3"],eachHole[@"stan4"],eachHole[@"usestatus"],eachHole[@"x"],eachHole[@"y"], nil];
                                            [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleParam];
                                        }
                                        //
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [weakSelf getCaddyCartInf];
                                            [weakSelf getCustomInf];
                                        });
                                        
                                    }
                                    else
                                    {
                                        [self.dbCon ExecNonQuery:@"delete from tbl_taskInfo"];
                                    }
//                                    [weakSelf performSegueWithIdentifier:@"directToWaitingDown" sender:nil];
                                }
                                
                            });
                            
                        });
                    }
                    else if ([recDic[@"Code"] intValue] == -2)
                    {
                        [weakSelf registerDeviceID];
                    }
                    
                }failure:^(NSError *err){
#ifdef DEBUG_MODE
                    NSLog(@"强制登录失败");
#endif
                    
                }];
                
                break;

        }
    }
    
}

- (void)registerDeviceID
{
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //组装数据
    NSMutableDictionary *addDeviceParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"padtag",@"",@"phoneNum", nil];
    //
    NSString *addDeviceURLStr;
    addDeviceURLStr = [GetRequestIPAddress getRequestAddDeviceURL];
    //
    [HttpTools getHttp:addDeviceURLStr forParams:addDeviceParam success:^(NSData *nsData){
#ifdef DEBUG_MODE
        NSLog(@"successfully requested");
        NSDictionary *recDic1 = [[NSDictionary alloc] init];// = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        recDic1 = (NSDictionary *)nsData;

        NSLog(@"recDic:%@",recDic1);
#endif
//        NSLog(@"recDic:%@",recDic1);
    }failure:^(NSError *err){
#ifdef DEBUG_MODE
        NSLog(@"request failled");
#endif
        NSLog(@"request failled");
    }];

}

- (NSString *)getTheSettingIP
{
    //获取到IP地址
    NSString *logInUrl;
    logInUrl = [GetRequestIPAddress getLogInURL];
    return logInUrl;
}
#pragma -mark logInButton
-(void)logIn
{
//    NSLog(@"enter login");
    //    [self performSegueWithIdentifier:@"jumpToCreateGroup" sender:self];
    
    //    [self.activityView showIndicator];
    
    //    DBCon *dbCon = [DBCon instance];
    //update data when first logIn
    [self.dbCon ExecNonQuery:@"delete from tbl_logInBackInf"];
    [self.dbCon ExecNonQuery:@"delete from tbl_logPerson"];
    [self.dbCon ExecNonQuery:@"delete from tbl_holeInf"];
    [self.dbCon ExecNonQuery:@"delete from tbl_EmployeeInf"];
    [self.dbCon ExecNonQuery:@"delete from tbl_taskInfo"];
    
    //start request from the server
//    NSLog(@"username:%@,password:%@",self.account.text,self.password.text);
    
    
    if(self.curNetworkStatus == NotReachable)
    {
        UIAlertView *networkUnreachableAlert = [[UIAlertView alloc] initWithTitle:@"网络连接异常" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [networkUnreachableAlert show];
        return;
    }
    //
    else if(([self.account.text isEqual: @""]) || ([self.password.text isEqual: @""]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入用户名及密码" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert show];
    }
    else{
        __weak typeof(self) weakSelf = self;
//        [self.dbCon ExecNonQuery:@"delete from tbl_NamePassword where user = 036"];
        //获取到mid号码
        NSString *theMid;
        theMid = [GetRequestIPAddress getUniqueID];
        theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
        //构建登录参数
        self.logInParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.account.text,@"username",self.password.text,@"pwd",@"0",@"panmull",@"0",@"forceLogin", nil];
        
        //
        [HttpTools getHttp:[self getTheSettingIP] forParams:self.logInParams success:^(NSData *nsData){
//            NSLog(@"success login");
            
            self.canReceiveNotification = YES;
            //
            self.logInPerson = [self.dbCon ExecDataTable:@"select *from tbl_NamePassword"];
            //store data from server
//            NSDictionary *reDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *recDic;
            recDic = (NSDictionary *)nsData;
            //handle error
#ifdef DEBUG_MODE
            NSLog(@"Code:%@",reDic[@"Code"]);
            NSLog(@"message is:%@",reDic[@"Msg"]);
#endif
            if ([recDic[@"Code"] integerValue] < 0) {
                [self.activityIndicatorView stopAnimating];
                self.activityIndicatorView.hidden = YES;
            }
            
            if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-1]])
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                UIAlertView *createGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [createGrpFailAlert show];
                NSLog(@"fail");
            }
            else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-2]])
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                UIAlertView *createGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [createGrpFailAlert show];
                NSLog(@"parameter is null");
            }
            
            else if ([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-3]])
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                UIAlertView *createGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [createGrpFailAlert show];
                NSLog(@"The Mid id illegal");
            }
            else if ([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-4]])
            {
#ifdef DEBUG_MODE
                NSLog(@"message is:%@",reDic[@"Msg"]);
#endif
                //是否强制登录，显示
                [weakSelf.forceLogInAlert show];
            }
            else if ([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:1]]){
                NSDictionary *recDictionary = [[NSDictionary alloc] initWithDictionary:recDic[@"Msg"]];
                
                //创建登录人信息数组
                //1sex cadShowNum 1empcod 1empnam 1empnum 1empjob
                //code text,job text,name text,number text,sex text,caddyLogIn text
                NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDictionary[@"logemp"][@"empcod"],recDictionary[@"logemp"][@"empjob"],recDictionary[@"logemp"][@"empnam"],recDictionary[@"logemp"][@"empnum"],recDictionary[@"logemp"][@"empsex"],recDictionary[@"logemp"][@"cadShowNum"], nil];
                //将数据加载到创建的数据库中
                [self.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
                
                //执行查询功能
#ifdef DEBUG_MODE
                DataTable *table;// = [[DataTable alloc] init];
                table = [self.dbCon ExecDataTable:@"select *from tbl_logPerson"];
                NSLog(@"Table.Rows[0]:%@",table.Rows[0][@"code"]);
#endif
                
                //获取到球洞信息，并将相应的信息保存到内存中
                NSArray *allHolesInfo = recDictionary[@"holes"];
                for (NSDictionary *eachHole in allHolesInfo) {
                    NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachHole[@"forecasttime"],eachHole[@"gronum"],eachHole[@"holcod"],eachHole[@"holcue"],eachHole[@"holfla"],eachHole[@"holgro"],eachHole[@"holind"],eachHole[@"hollen"],eachHole[@"holnam"],eachHole[@"holnum"],eachHole[@"holspe"],eachHole[@"holsta"],eachHole[@"nowgroups"],eachHole[@"stan1"],eachHole[@"stan2"],eachHole[@"stan3"],eachHole[@"stan4"],eachHole[@"usestatus"],eachHole[@"x"],eachHole[@"y"], nil];
                    [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleParam];
                }
                
//                DataTable *table11 = [[DataTable alloc] init];
//                table11 = [weakSelf.dbCon ExecDataTable:@"select *from tbl_holeInf"];
                //获取到所有职员的信息
                dispatch_async(dispatch_get_main_queue(), ^{
                    //获取到所有球员的数组
                    NSArray *allEmployee = recDictionary[@"emps"];
                    for (NSDictionary *eachEmployee in allEmployee) {
                        NSMutableArray *eachEmpParam = [[NSMutableArray alloc] initWithObjects:eachEmployee[@"empcod"],eachEmployee[@"empjob"],eachEmployee[@"empnam"],eachEmployee[@"empnum"],eachEmployee[@"empsex"],eachEmployee[@"loctime"],eachEmployee[@"online"],eachEmployee[@"x"],eachEmployee[@"y"], nil];
                        [weakSelf.dbCon ExecNonQuery:@"insert into tbl_EmployeeInf(empcod,empjob,empnam,empnum,empsex,loctime,online,x,y) values(?,?,?,?,?,?,?,?,?)" forParameter:eachEmpParam];
                    }
//                    DataTable *table11 = [[DataTable alloc] init];
//                    table11 = [weakSelf.dbCon ExecDataTable:@"select *from tbl_EmployeeInf"];
//                    NSLog(@"table11:%@",table11.Rows);
                });
                
                //
                dispatch_async(dispatch_get_main_queue(), ^{
                    //进入建组界面，发送获取参数（球童，球车，球场的球洞），之后发送
                    [weakSelf getCaddyCartInf];
                    //获取客户信息
                    [weakSelf getCustomInf];
                    //关闭activityIndicator
                    [self.activityIndicatorView stopAnimating];
                    self.activityIndicatorView.hidden = YES;
                    //
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //执行跳转
                        [weakSelf performSegueWithIdentifier:@"jumpToCreateGroup" sender:nil];
                    });
                });
                
            }
            
            
        }failure:^(NSError *err){
            NSLog(@"fail login");
            //            [self.activityView hideIndicator];
            //            [self.activityView removeFromSuperview];
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求超时" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            
            [alert show];
            
            
            
        }];
    }
}

-(void)checkCurStateOnServer
{
    __weak typeof(self) weakSelf = self;
    //
    [self.activityIndicatorView startAnimating];
    self.activityIndicatorView.hidden = NO;
    //
    self.haveGroupNotDown = NO;
    //
    if(![self.logInPerson.Rows count])
    {
        //构建登录人参数，并且将数据给存储到内存中
        NSMutableArray *logInPersonInf = [[NSMutableArray alloc] initWithObjects:self.account.text,self.password.text,@"1", nil];
        [self.dbCon ExecNonQuery:@"insert into tbl_NamePassword(user,password,logOutOrNot) values(?,?,?)" forParameter:logInPersonInf];
    }
    else
    {
        BOOL whetherAdd;
        whetherAdd = NO;
        for(unsigned char i = 0;i < [self.logInPerson.Rows count];i++)
        {
            if(self.logInPerson.Rows[i][@"user"] != self.account.text)
            {
                whetherAdd = YES;
            }
            else if (![self.logInPerson.Rows[i][@"logOutOrNot"] boolValue])
            {
                whetherAdd = YES;
            }
            else //有相同的出现时，立马推出查询循环
            {
                whetherAdd = NO;
                break;
            }
        }
        //通过查询比较发现没有相同的账号在，故此添加帐号
        if(whetherAdd)
        {
            //构建登录人参数，并且将数据给存储到内存中
            NSMutableArray *logInPersonInf = [[NSMutableArray alloc] initWithObjects:self.account.text,self.password.text,@"1", nil];
            [self.dbCon ExecNonQuery:@"insert into tbl_NamePassword(user,password,logOutOrNot) values(?,?,?)" forParameter:logInPersonInf];
        }
    }
    //查询数据
    self.logInPerson = [self.dbCon ExecDataTable:@"select *from tbl_NamePassword"];
    //判断当前所登录的账号与保存的账号是否一致不一致则更新
    NSString *oldAccountName;
    oldAccountName = [NSString stringWithFormat:@"%@",self.logInPerson.Rows[[self.logInPerson.Rows count] - 1][@"user"]];
    if (![self.account.text isEqualToString:oldAccountName]) {
        //
        [self.dbCon ExecNonQuery:[NSString stringWithFormat:@"delete from tbl_NamePassword where user = '%@'",self.logInPerson.Rows[[self.logInPerson.Rows count] - 1][@"user"]]];
        //
        //构建登录人参数，并且将数据给存储到内存中
        NSMutableArray *logInPersonInf = [[NSMutableArray alloc] initWithObjects:self.account.text,self.password.text,@"1", nil];
        [self.dbCon ExecNonQuery:@"insert into tbl_NamePassword(user,password,logOutOrNot) values(?,?,?)" forParameter:logInPersonInf];
    }
    
    //
    if(([self.account.text isEqual: @""]) || ([self.password.text isEqual: @""]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入用户名及密码" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert show];
        return;
    }
    NSString *logCaddyStr;
    NSString *password;
    logCaddyStr = [NSString stringWithFormat:@"%@",self.account.text];
    password    = [NSString stringWithFormat:@"%@",self.password.text];
    //
    [self.dbCon ExecNonQuery:@"delete from tbl_logPerson"];
    //构建判断是否可以建组参数
    if (![self.logInPerson.Rows count]) {
        [self logIn];
        return;
    }
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //
    self.checkCreatGroupState = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",logCaddyStr,@"username",password,@"pwd",@"0",@"panmull",@"0",@"forceLogin", nil];
    //
    NSString *downFieldURLStr;
    downFieldURLStr = [GetRequestIPAddress getDecideCreateGrpAndDownFieldURL];
    //request
    [HttpTools getHttp:downFieldURLStr forParams:self.checkCreatGroupState success:^(NSData *nsData){
        //
        self.canReceiveNotification = YES;
//        NSLog(@"request successfully");
        NSDictionary *recDic;// = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        recDic = (NSDictionary *)nsData;
        
#ifdef DEBUG_MODE
        NSLog(@"code:%@\n msg:%@",recDic[@"Code"],recDic[@"Msg"]);
        NSLog(@"124");
#endif
        //
        if ([recDic[@"Code"] integerValue] < 0) {
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
        }
        //
        if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-1]])
        {
            NSString *errStr;
            errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
            UIAlertView *createGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [createGrpFailAlert show];
        }
        else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-2]])
        {
            //
            NSString *errStr;
            errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
            UIAlertView *createGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [createGrpFailAlert show];
            [weakSelf registerDeviceID];
        }
        else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-3]])
        {
            NSString *errStr;
            errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
            UIAlertView *createGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [createGrpFailAlert show];
        }
        else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-4]])
        {
            //现实需要强制登录
            [weakSelf.forceLogInAlert show];
        }
        else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            [self.dbCon ExecDataTable:@"delete from tbl_groupInf"];
            [self.dbCon ExecDataTable:@"delete from tbl_holeInf"];
            [self.dbCon ExecDataTable:@"delete from tbl_CustomersInfo"];
            //
            //获取到球洞信息，并将相应的信息保存到内存中
            NSArray *allHolesInfo = recDic[@"Msg"][@"holes"];
            for (NSDictionary *eachHole in allHolesInfo) {
                NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachHole[@"forecasttime"],eachHole[@"gronum"],eachHole[@"holcod"],eachHole[@"holcue"],eachHole[@"holfla"],eachHole[@"holgro"],eachHole[@"holind"],eachHole[@"hollen"],eachHole[@"holnam"],eachHole[@"holnum"],eachHole[@"holspe"],eachHole[@"holsta"],eachHole[@"nowgroups"],eachHole[@"stan1"],eachHole[@"stan2"],eachHole[@"stan3"],eachHole[@"stan4"],eachHole[@"usestatus"],eachHole[@"x"],eachHole[@"y"], nil];
                [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleParam];
            }
            //
            NSString *groupValue = [recDic[@"Msg"] objectForKey:@"group"];
            if([(NSNull *)groupValue isEqual: @"null"])//
            {
                [self logIn];
            }
            else//
            {
                [self.dbCon ExecDataTable:@"delete from tbl_selectCart"];
                //获取到登录小组的所有客户的信息
                NSArray *allCustomers = recDic[@"Msg"][@"group"][@"cuss"];
                for (NSDictionary *eachCus in allCustomers) {
                    NSMutableArray *eachCusParam = [[NSMutableArray alloc] initWithObjects:eachCus[@"bansta"],eachCus[@"bantim"],eachCus[@"cadcod"],eachCus[@"carcod"],eachCus[@"cuscod"],eachCus[@"cuslev"],eachCus[@"cusnam"],eachCus[@"cusnum"],eachCus[@"cussex"],eachCus[@"depsta"],eachCus[@"endtim"],eachCus[@"grocod"],eachCus[@"memnum"],eachCus[@"padcod"],eachCus[@"phone"],eachCus[@"statim"], nil];
                    [weakSelf.dbCon ExecNonQuery:@"insert into tbl_CustomersInfo(bansta,bantim,cadcod,carcod,cuscod,cuslev,cusnam,cusnum,cussex,depsta,endtim,grocod,memnum,padcod,phone,statim) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachCusParam];
                }
                //将所选择的球车的信息保存下来
                //保存添加的球车的信息 tbl_selectCart(carcod text,carnum text,carsea text)
                NSArray *allSelectedCartsArray = recDic[@"Msg"][@"group"][@"cars"];
                for (NSDictionary *eachCart in allSelectedCartsArray) {
                    NSMutableArray *selectedCart = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
                    [weakSelf.dbCon ExecNonQuery:@"insert into tbl_selectCart(carcod,carnum,carsea) values(?,?,?)" forParameter:selectedCart];
                }
                //此处的数据还没有传递到需要的地方去
                self.customerCount = [recDic[@"Msg"][@"group"][@"cuss"] count] - 1;
                self.curHoleName = recDic[@"Msg"][@"group"][@"hgcod"];
                //
                //                if ([curHoleName isEqualToString:@"上九洞"]) {
                //                    ucHolePosition = 0;
                //                }
                //                else if([curHoleName isEqualToString:@"下九洞"])
                //                {
                //                    ucHolePosition = 1;
                //                }
                //                else if([curHoleName isEqualToString:@"十八洞"])
                //                {
                //                    ucHolePosition = 2;
                //                }
                
                
                if(recDic[@"Msg"][@"group"][@"grocod"] != nil)
                {
                    NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"logemp"][@"empcod"],recDic[@"Msg"][@"logemp"][@"empjob"],recDic[@"Msg"][@"logemp"][@"empnam"],recDic[@"Msg"][@"logemp"][@"empnum"],recDic[@"Msg"][@"logemp"][@"empsex"],recDic[@"Msg"][@"logemp"][@"cadShowNum"], nil];
                    //将数据加载到创建的数据库中
                    [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
                    //组建获取到的组信息的数组
                    NSMutableArray *groupInfArray = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"group"][@"grocod"],recDic[@"Msg"][@"group"][@"groind"],recDic[@"Msg"][@"group"][@"grolev"],recDic[@"Msg"][@"group"][@"gronum"],recDic[@"Msg"][@"group"][@"grosta"],recDic[@"Msg"][@"group"][@"hgcod"],recDic[@"Msg"][@"group"][@"onlinestatus"],recDic[@"Msg"][@"group"][@"createdate"],recDic[@"Msg"][@"group"][@"timestamps"], nil];
                    //将数据加载到创建的数据库中
                    //grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text
                    [weakSelf.dbCon ExecNonQuery:@"insert into  tbl_groupInf(grocod,groind,grolev,gronum,grosta,hgcod,onlinestatus,createdate,timestamps)values(?,?,?,?,?,?,?,?,?)" forParameter:groupInfArray];
                    //
//                    DataTable *table;// = [[DataTable alloc] init];
//                    
//                    table = [strongSelf.dbCon ExecDataTable:@"select *from tbl_groupInf"];
//                    NSLog(@"table:%@",table);
                    //
                    HeartBeatAndDetectState *heartBeat = [[HeartBeatAndDetectState alloc] init];
                    if(![heartBeat checkState])
                    {
                        [heartBeat initHeartBeat];//启动心跳服务
                        [heartBeat enableHeartBeat];
                    }
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"allowDown" object:nil userInfo:@{@"allowDown":@"1"}];
                    
                    weakSelf.haveGroupNotDown = YES;
                    //获取到球洞信息，并将相应的信息保存到内存中
                    NSArray *allHolesInfo = recDic[@"Msg"][@"holes"];
                    for (NSDictionary *eachHole in allHolesInfo) {
                        NSMutableArray *eachHoleParam = [[NSMutableArray alloc] initWithObjects:eachHole[@"forecasttime"],eachHole[@"gronum"],eachHole[@"holcod"],eachHole[@"holcue"],eachHole[@"holfla"],eachHole[@"holgro"],eachHole[@"holind"],eachHole[@"hollen"],eachHole[@"holnam"],eachHole[@"holnum"],eachHole[@"holspe"],eachHole[@"holsta"],eachHole[@"nowgroups"],eachHole[@"stan1"],eachHole[@"stan2"],eachHole[@"stan3"],eachHole[@"stan4"],eachHole[@"usestatus"],eachHole[@"x"],eachHole[@"y"], nil];
                        [weakSelf.dbCon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleParam];
                    }
                    //
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf getCaddyCartInf];
                        [weakSelf getCustomInf];
                    });
                    
                }
                else
                {
                    [weakSelf.dbCon ExecNonQuery:@"delete from tbl_taskInfo"];
                }
                
            }
        }
        
    }failure:^(NSError *err){
#ifdef DEBUG_MODE
        NSLog(@"request failled");
#endif
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        //
        UIAlertView *netAlert = [[UIAlertView alloc] initWithTitle:@"网络连接异常，请检查网络设置" message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [netAlert show];
    }];
}


#pragma -mark logInButton
- (IBAction)logInButton:(UIButton *)sender {
    //登录时判断当前的状态
#ifdef testChangeInterface
    [self performSegueWithIdentifier:@"jumpToCreateGroup" sender:nil];
#else
    [self checkCurStateOnServer];
#endif
}

#pragma -mark logTextField keyReturn action
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.account) {
        [self.self.account resignFirstResponder];
        [self.self.password becomeFirstResponder];
    }
    else if (textField == self.password)
    {
        [self checkCurStateOnServer];
    }
    
    return YES;
}

/**
 *  键盘发生改变执行
 */
- (void)keyboardWillChange:(NSNotification *)note
{
//    NSLog(@"%@", note.userInfo);
    NSDictionary *userInfo = note.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height;
    
    
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, moveY/2);
    }];
}


@end
