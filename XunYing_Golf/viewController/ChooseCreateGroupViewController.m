//
//  ChooseCreateGroupViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/18.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "ChooseCreateGroupViewController.h"
#import "UIColor+UICon.h"
#import "HttpTools.h"
#import "DataTable.h"
#import "DBCon.h"
#import "XunYingPre.h"
#import "HeartBeatAndDetectState.h"
#import "AppDelegate.h"
#import "QRCodeReaderViewController.h"
#import "ActivityIndicatorView.h"
#import "WaitToPlayTableViewController.h"
#import "GetRequestIPAddress.h"

//extern unsigned char ucCusCounts;
//extern unsigned char ucHolePosition;


@interface ChooseCreateGroupViewController ()<QRCodeReaderDelegate>


@property (strong, nonatomic) DBCon *LogDbcon;
@property (strong, nonatomic) DataTable *logPerson;
@property (strong, nonatomic) DataTable *inputlogCaddy;
@property (strong, nonatomic) DataTable *logEmp;
@property (strong, nonatomic) DataTable *cusNumbers;
@property (strong, nonatomic) NSMutableDictionary *checkCreatGroupState;
@property (strong, nonatomic) UIActivityIndicatorView *stateIndicator;

@property (strong, nonatomic) NSDictionary *loggedPersonInf;
@property BOOL backOrNext;  //yes:next   no:back default we go to the next interface

@property (strong, nonatomic) QRCodeReaderViewController *QRCodeReader;
//@property (strong, nonatomic) ActivityIndicatorView *activityIndicatorView;
@property (nonatomic)         NSInteger cusCount;
@property (nonatomic)         BOOL      QRCodeWay;
@property (strong, nonatomic) NSArray   *QRcusCard;

- (IBAction)backToLogInFace:(UIBarButtonItem *)sender;
- (IBAction)MannualCreateGrp:(UIButton *)sender;
- (IBAction)QRCodeCreateGrp:(UIButton *)sender;



@end

@implementation ChooseCreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.LogDbcon   = [[DBCon alloc] init];
    self.logPerson  = [[DataTable alloc] init];
    self.logEmp     = [[DataTable alloc] init];
    self.cusNumbers = [[DataTable alloc] init];
    self.inputlogCaddy = [[DataTable alloc] init];
    //
    self.QRCodeWay  = NO;
    //
    self.backOrNext = YES;
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whereToGo:) name:@"whereToGo" object:nil];
    //
    self.QRCodeReader = [[QRCodeReaderViewController alloc] initWithCancelButtonTitle:@"取消"];
    self.QRCodeReader.modalPresentationStyle = UIModalPresentationFormSheet;
    self.QRCodeReader.delegate = self;
    [QRCodeReaderViewController readerWithCancelButtonTitle:@"取消"];
    //
    self.stateIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 100, ScreenHeight/2 - 100, 200, 200)];
    self.stateIndicator.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.2];
    self.stateIndicator.layer.cornerRadius = 20;
    [self.view addSubview:self.stateIndicator];
    self.stateIndicator.hidden = YES;
    //
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBarBack"] style:UIBarButtonItemStylePlain target:self action:@selector(backToLogInView)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
}

- (void)backToLogInView
{
    self.backOrNext = NO;
    [self performSegueWithIdentifier:@"backToLogInSegue" sender:nil];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    [self.stateIndicator stopAnimating];
    self.stateIndicator.hidden = YES;
    
}

#pragma -mark where interface to go
-(void)whereToGo:(NSNotification *)sender
{
    NSLog(@"enter where to go");
    //when get the notification ,then remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //decide which interface to go according to the sender whoes object is NSNotification
    if ([sender.userInfo[@"allowDown"] isEqualToString:@"1"]) {
//        [self.activityIndicatorView hideIndicator];
//        self.activityIndicatorView.hidden = YES;
        
        [self.stateIndicator stopAnimating];
        self.stateIndicator.hidden = YES;
        //执行跳转程序，此时判断的是已经创建了组
        [self performSegueWithIdentifier:@"ToMainMapView1" sender:nil];
    }
    else if([sender.userInfo[@"waitToAllow"] isEqualToString:@"1"])
    {
//        [self.activityIndicatorView hideIndicator];
//        self.activityIndicatorView.hidden = YES;
        [self.stateIndicator stopAnimating];
        self.stateIndicator.hidden = YES;
        
        [self performSegueWithIdentifier:@"shouldWaitToAllow1" sender:nil];
    }
    else
    {
//        [self performSegueWithIdentifier:@"mannualCreatGrp" sender:nil];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.logPerson = [self.LogDbcon ExecDataTable:@"select *from tbl_NamePassword"];
    self.logEmp    = [self.LogDbcon ExecDataTable:@"select *from tbl_logPerson"];
    self.inputlogCaddy = [self.LogDbcon ExecDataTable:@"select *from tbl_NamePassword"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backToLogInFace:(UIBarButtonItem *)sender {
    
    
    self.backOrNext = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"backToLogInSegue" sender:nil];
    });
}

- (IBAction)MannualCreateGrp:(UIButton *)sender {
    NSLog(@"enter mannualCreateGrp");
    self.backOrNext = YES;
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //check current state
    self.checkCreatGroupState = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.logPerson.Rows[[self.logPerson.Rows count] - 1][@"user"],@"username",self.logPerson.Rows[[self.logPerson.Rows count] - 1][@"password"],@"pwd",@"0",@"panmull",@"0",@"forceLogin", nil];
    //
//    [self.activityIndicatorView showIndicator];
//    self.activityIndicatorView.hidden = NO;
    [self.stateIndicator startAnimating];
    self.stateIndicator.hidden = NO;
    //
    __weak typeof(self) weakSelf = self;
    //
    NSString *downFieldURLStr;
    downFieldURLStr = [GetRequestIPAddress getDecideCreateGrpAndDownFieldURL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //request
        [HttpTools getHttp:downFieldURLStr forParams:self.checkCreatGroupState success:^(NSData *nsData){
            //
            ChooseCreateGroupViewController *strongSelf = weakSelf;
            //        NSLog(@"request successfully");
//            NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *recDic;// = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            recDic = (NSDictionary *)nsData;
#ifdef DEBUD_MODE
            NSLog(@"code:%@\n msg:%@",recDic[@"Code"],recDic[@"Msg"]);
            NSLog(@"124");
#endif
            //
            if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-1]])
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [hasGrpFailAlert show];
            }
            else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-2]])
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [hasGrpFailAlert show];
            }
            else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-3]])
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [hasGrpFailAlert show];
            }
            else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-4]])
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [hasGrpFailAlert show];
            }
            else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:1]])
            {
                [self.LogDbcon ExecDataTable:@"delete from tbl_groupInf"];
                [self.LogDbcon ExecDataTable:@"delete from tbl_holeInf"];
                //
                NSArray *holeInf = [[NSArray alloc]initWithObjects:@"forecasttime",@"gronum",@"holcod",@"holcue",@"holfla",@"holgro",@"holind",@"hollen",@"holnam",@"holnum",@"holspe",@"holsta",@"nowgroups",@"stan1",@"stan2",@"stan3",@"stan4",@"usestatus",@"x",@"y", nil];
                NSMutableArray *holesInf = [[NSMutableArray alloc] init];
#ifdef DEBUD_MODE
                NSLog(@"count:%ld",[recDic[@"Msg"][@"holes"] count]);
#endif
                NSArray *holesArray = recDic[@"Msg"][@"holes"];
                
                //            NSDictionary *holeDic = [[NSDictionary alloc] init];
                
                NSMutableArray *mutableHolesArray = [[NSMutableArray alloc] init];
                for (unsigned char i = 0; i < [holesArray count]; i++) {
                    [mutableHolesArray addObject:holesArray[i]];
                }
                //
                for(unsigned int j = 0; j < [mutableHolesArray count];j++)
                {
                    NSMutableArray *eachHoleInf = [[NSMutableArray alloc] init];//[[NSMutableArray alloc]initWithObjects:@"", nil];
                    for(unsigned int i = 0; i < [holeInf count];i++)
                    {
                        [eachHoleInf addObject:mutableHolesArray[j][holeInf[i]]];
                        //                        NSLog(@"out %@:%@",holeInf[i],eachHoleInf[i]);
                    }
                    //将数据加载到创建的数据库中
                    [strongSelf.LogDbcon ExecNonQuery:@"INSERT INTO tbl_holeInf(forecasttime,gronum,holcod,holcue,holfla,holgro,holind,hollen,holnam,holenum,holspe,holsta,nowgroups,stan1,stan2,stan3,stan4,usestatus,x,y) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleInf];
                    
                    [holesInf addObject:eachHoleInf];
                }
                //
                //            DataTable *table;// = [[DataTable alloc] init];
                //            table = [strongSelf.LogDbcon ExecDataTable:@"select *from tbl_holeInf"];
                //
                //            NSString *groupValue = [recDic[@"Msg"] objectForKey:@"group"];
                //            if([(NSNull *)groupValue isEqual: @"null"])//
                //            {
                //                //[strongSelf performSegueWithIdentifier:@"jumpToCreateGroup" sender:nil];
                //                [str logIn];
                //            }
                //            else//
                {
                    //                ucCusCounts = [recDic[@"Msg"][@"group"][@"cuss"] count] - 1;
                    //                NSString *curHoleName = recDic[@"Msg"][@"group"][@"hgcod"];
                    //此处的数据还没有传递到需要的地方去
                    //                self.customerCount = [recDic[@"Msg"][@"group"][@"cuss"] count] - 1;
                    //                self.curHoleName = recDic[@"Msg"][@"group"][@"hgcod"];
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
                    
                    //                if(recDic[@"Msg"][@"group"])
                    NSDictionary *grpInfDic = [[NSDictionary alloc] initWithDictionary:recDic[@"Msg"]];
                    NSString *createTim;
                    createTim = [grpInfDic objectForKey:@"group"];
                    if(((NSNull *)createTim != [NSNull null]) && (![createTim  isEqual: @"null"]))
                    {
                        NSMutableArray *logPersonInf = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"logemp"][@"empcod"],recDic[@"Msg"][@"logemp"][@"empjob"],recDic[@"Msg"][@"logemp"][@"empnam"],recDic[@"Msg"][@"logemp"][@"empnum"],recDic[@"Msg"][@"logemp"][@"empsex"],recDic[@"Msg"][@"logemp"][@"cadShowNum"], nil];
                        //将数据加载到创建的数据库中
                        [strongSelf.LogDbcon ExecNonQuery:@"INSERT INTO tbl_logPerson(code,job,name,number,sex,caddyLogIn) VALUES(?,?,?,?,?,?)" forParameter:logPersonInf];
                        //组建获取到的组信息的数组
                        NSMutableArray *groupInfArray = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"group"][@"grocod"],recDic[@"Msg"][@"group"][@"groind"],recDic[@"Msg"][@"group"][@"grolev"],recDic[@"Msg"][@"group"][@"gronum"],recDic[@"Msg"][@"group"][@"grosta"],recDic[@"Msg"][@"group"][@"hgcod"],recDic[@"Msg"][@"group"][@"onlinestatus"],recDic[@"Msg"][@"group"][@"createdate"],recDic[@"Msg"][@"group"][@"timestamps"], nil];
                        //将数据加载到创建的数据库中
                        //grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text
                        [strongSelf.LogDbcon ExecNonQuery:@"insert into  tbl_groupInf(grocod,groind,grolev,gronum,grosta,hgcod,onlinestatus,createdate,timestamps)values(?,?,?,?,?,?,?,?,?)" forParameter:groupInfArray];
                        //
                        //                    DataTable *table = [[DataTable alloc] init];
                        //
                        //                    table = [strongSelf.LogDbcon ExecDataTable:@"select *from tbl_groupInf"];
                        //                    NSLog(@"table:%@",table);
                        //
                        HeartBeatAndDetectState *heartBeat = [[HeartBeatAndDetectState alloc] init];
                        [HeartBeatAndDetectState disableHeartBeat];//disable heartBeat
                        if(![heartBeat checkState])
                        {
                            [heartBeat initHeartBeat];//启动心跳服务
                        }
                        //                    strongSelf.haveGroupNotDown = YES;
                        
                    }
                    else
                    {
                        //先隐藏，同时停止动画
//                        [self.activityIndicatorView hideIndicator];
//                        self.activityIndicatorView.hidden = YES;
                        [self.stateIndicator stopAnimating];
                        self.stateIndicator.hidden = YES;
                        //
                        [self performSegueWithIdentifier:@"mannualCreatGrp" sender:nil];
                    }
                    
                }
            }
            
        }failure:^(NSError *err){
            NSLog(@"request failled");
            
            
        }];
    });
    
    
}

- (IBAction)QRCodeCreateGrp:(UIButton *)sender {
    NSLog(@"开始扫描二维码");
    __weak typeof(self) weakSelf = self;
    //tbl_CustomerNumbers
    self.cusNumbers = [self.LogDbcon ExecDataTable:@"select *from tbl_CustomerNumbers"];
    //
    [self.stateIndicator startAnimating];
    self.stateIndicator.hidden = NO;
    //
    [self.QRCodeReader setCompletionWithBlock:^(NSString *resultAsString){
#ifdef DEBUD_MODE
        NSLog(@"result:%@",resultAsString);
#endif
        //定义球车，球童，消费卡号的字符数组
        NSString *cusCards = [[NSString alloc] init];
        NSString *caddies  = [[NSString alloc] init];
        NSString *carts    = [[NSString alloc] init];
        //将获取到的参数给拆分出来 第一个元素为组编号，第二个元素为组类别（151211确认目前都选择为all），第三个元素为消费卡号，球童，球车的信息，具体见相应的说明文档“上邦高尔夫原有系统与巡鹰球场调度系统数据对接”
        NSArray *QRCodeReadResult = [resultAsString componentsSeparatedByString:@";"];//拆分接收到的数据
        //拆分到消费卡号，球童，球车信息出来(可能是多个组合的信息)
        NSString *cusCadCartsStr = [NSString stringWithFormat:@"%@",QRCodeReadResult[2]];
        NSArray *allCadCartsArray = [cusCadCartsStr componentsSeparatedByString:@"&"];
        for (NSString *eachCadCart in allCadCartsArray) {
#ifdef DEBUD_MODE
            NSLog(@"eacgCadCart:%@",eachCadCart);
#endif
            NSArray *separateParam = [eachCadCart componentsSeparatedByString:@"_"];
#ifdef DEBUD_MODE
            NSLog(@"separateParam:%@ intValue:%d cuscardsBool:%d",separateParam,[separateParam[0] intValue],[cusCards isEqualToString:@""]);
#endif
            cusCards = [cusCards stringByAppendingString:([cusCards isEqualToString:@""] && ([separateParam[0] intValue] != -1))?separateParam[0]:[NSString stringWithFormat:@"_%@",separateParam[0]]];
            caddies = [caddies stringByAppendingString:([caddies isEqualToString:@""] && ([separateParam[1] intValue] != -1))?separateParam[1]:[NSString stringWithFormat:@"_%@",separateParam[1]]];
            carts = [carts stringByAppendingString:([carts isEqualToString:@""] && ([separateParam[2] intValue] != -1))?separateParam[2]:[NSString stringWithFormat:@"_%@",separateParam[2]]];
        }
        NSArray *caddiesArray = [caddies componentsSeparatedByString:@"_"];
        BOOL hasTheLogCaddy;
        hasTheLogCaddy = NO;
        NSString *logCaddyNum;
        logCaddyNum = [NSString stringWithFormat:@"%@",self.inputlogCaddy.Rows[0][@"user"]];
        //
        for (NSString *eachCaddy in caddiesArray) {
            if ([eachCaddy isEqualToString:logCaddyNum]) {
                hasTheLogCaddy = YES;
            }
        }
        if (!hasTheLogCaddy) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该组中无此球童" message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            //
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            
            return;
        }
//        NSLog(@"%@",QRCodeReadResult);
//        NSLog(@"%@  %@  %@",QRCodeReadResult[0],QRCodeReadResult[1],QRCodeReadResult[2]);
//        NSLog(@"cusCards:%@ caddies:%@ carts:%@",cusCards,caddies,carts);
        //二维码扫描得到的所有消费卡号
        NSArray *allCusCards = [cusCards componentsSeparatedByString:@"_"];
        weakSelf.QRcusCard = [[NSArray alloc] initWithArray:allCusCards];
        
        
//        NSMutableArray *allCuscards = [[NSMutableArray alloc] initWithObjects:allCusCards, nil];
#ifdef DEBUD_MODE
        NSLog(@"allcuscards:%@",allCuscards);
#endif
        
        weakSelf.cusCount = [allCusCards count];
        weakSelf.QRCodeWay = YES;
        //获取到mid号码
        NSString *theMid;
        theMid = [GetRequestIPAddress getUniqueID];
        theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
        //组装请求的数据
        NSMutableDictionary *createGrpParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",QRCodeReadResult[0],@"gronum",cusCards,@"cus",@"all",@"hole",caddies,@"cad",carts,@"car",weakSelf.logEmp.Rows[[weakSelf.logEmp.Rows count] - 1][@"number"],@"cadShow",weakSelf.logEmp.Rows[[weakSelf.logEmp.Rows count] - 1][@"code"],@"user", nil];
        //
        NSString *createGrpURLStr;
        createGrpURLStr = [GetRequestIPAddress getcreateGroupURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //请求接口（建组下场的接口），并进行相应的跳转
            [HttpTools getHttp:createGrpURLStr forParams:createGrpParam success:^(NSData *nsData){
                
                NSDictionary *recDic;
                recDic = (NSDictionary *)nsData;
#ifdef DEBUD_MODE
                NSLog(@"recDic:%@",recDic);
#endif
                //
                if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-1]])
                {
                    NSString *errStr;
                    errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                    UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [hasGrpFailAlert show];
                    NSLog(@"程序异常");
                }
                else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:0]])
                {
                    NSString *errStr;
                    errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                    UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [hasGrpFailAlert show];
                    NSLog(@"建组失败");
                }
                else if([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-3]])
                {
                    NSString *errStr;
                    errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                    UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [hasGrpFailAlert show];
                    NSLog(@"已有球组，建组失败");
                }
                else
                {
                    [weakSelf.LogDbcon ExecDataTable:@"delete from tbl_taskInfo"];
                    [weakSelf.LogDbcon ExecDataTable:@"delete from tbl_CustomersInfo"];
                    [weakSelf.LogDbcon ExecDataTable:@"delete from tbl_selectCart"];
                    [weakSelf.LogDbcon ExecDataTable:@"delete from tbl_groupInf"];
                    [weakSelf.LogDbcon ExecDataTable:@"delete from tbl_addCaddy"];
                    //
#ifdef DEBUD_MODE
                    NSLog(@"grpcod:%@  ;groind:%@  ;grolev:%@  ;gronum:%@  ;grosta:%@",recDic[@"Msg"][@"grocod"],recDic[@"Msg"][@"groind"],recDic[@"Msg"][@"grolev"],recDic[@"Msg"][@"gronum"],recDic[@"Msg"][@"grosta"]);
#endif
                    //组建获取到的组信息的数组
                    NSMutableArray *groupInfArray = [[NSMutableArray alloc] initWithObjects:recDic[@"Msg"][@"grocod"],recDic[@"Msg"][@"groind"],recDic[@"Msg"][@"grolev"],recDic[@"Msg"][@"gronum"],recDic[@"Msg"][@"grosta"],recDic[@"Msg"][@"hgcod"],recDic[@"Msg"][@"onlinestatus"],recDic[@"Msg"][@"createdate"],recDic[@"Msg"][@"timestamps"], nil];
                    //将数据加载到创建的数据库中
                    //grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text
                    
                    [weakSelf.LogDbcon ExecNonQuery:@"insert into tbl_groupInf(grocod,groind,grolev,gronum,grosta,hgcod,onlinestatus,createdate,timestamps)values(?,?,?,?,?,?,?,?,?)" forParameter:groupInfArray];
#ifdef DEBUD_MODE
                    NSLog(@"successfully create group and the recDic:%@  code:%@",recDic[@"Msg"],recDic[@"code"]);
#endif
                    //获取到登录小组的所有客户的信息
                    NSArray *allCustomers = recDic[@"Msg"][@"cuss"];
                    for (NSDictionary *eachCus in allCustomers) {
                        NSMutableArray *eachCusParam = [[NSMutableArray alloc] initWithObjects:eachCus[@"bansta"],eachCus[@"bantim"],eachCus[@"cadcod"],eachCus[@"carcod"],eachCus[@"cuscod"],eachCus[@"cuslev"],eachCus[@"cusnam"],eachCus[@"cusnum"],eachCus[@"cussex"],eachCus[@"depsta"],eachCus[@"endtim"],eachCus[@"grocod"],eachCus[@"memnum"],eachCus[@"padcod"],eachCus[@"phone"],eachCus[@"statim"], nil];
                        [weakSelf.LogDbcon ExecNonQuery:@"insert into tbl_CustomersInfo(bansta,bantim,cadcod,carcod,cuscod,cuslev,cusnam,cusnum,cussex,depsta,endtim,grocod,memnum,padcod,phone,statim) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachCusParam];
                    }
                    //保存添加的球车的信息 tbl_selectCart(carcod text,carnum text,carsea text)
                    NSArray *allSelectedCartsArray = recDic[@"Msg"][@"cars"];
                    for (NSDictionary *eachCart in allSelectedCartsArray) {
                        NSMutableArray *selectedCart = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
                        [weakSelf.LogDbcon ExecNonQuery:@"insert into tbl_selectCart(carcod,carnum,carsea) values(?,?,?)" forParameter:selectedCart];
                    }
                    //
                    //保存添加的球童的信息 tbl_addCaddy(cadcod text,cadnam text,cadnum text,cadsex text,empcod text)
                    NSArray *allSelectedCaddiesArray = recDic[@"Msg"][@"cads"];
                    for (NSDictionary *eachCaddy in allSelectedCaddiesArray) {
                        NSMutableArray *selectedCaddy = [[NSMutableArray alloc] initWithObjects:eachCaddy[@"cadcod"],eachCaddy[@"cadnam"],eachCaddy[@"cadnum"],eachCaddy[@"cadsex"],eachCaddy[@"empcod"], nil];
                        [weakSelf.LogDbcon ExecNonQuery:@"insert into tbl_addCaddy(cadcod,cadnam,cadnum,cadsex,empcod) values(?,?,?,?,?)" forParameter:selectedCaddy];
                    }
                    //                DataTable *table11;// = [[DataTable alloc] init];
                    //                table11 = [weakSelf.LogDbcon ExecDataTable:@"select *from tbl_selectCart"];
                    //建组成功之后，进入心跳处理类中，开始心跳功能
                    HeartBeatAndDetectState *heartBeat = [[HeartBeatAndDetectState alloc] init];
                    if (![heartBeat checkState]) {
                        [heartBeat initHeartBeat];//1、开启心跳功能
                        [heartBeat enableHeartBeat];//1、使能心跳
                    }
                    //
//                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    [weakSelf.stateIndicator stopAnimating];
                    weakSelf.stateIndicator.hidden = YES;
                    //跳转页面
                    [weakSelf performSegueWithIdentifier:@"QRCodeToWait" sender:nil];
                    //执行通知
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *QRCodeNotice = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)weakSelf.cusCount],@"customerCount",@"十八洞",@"holetype", nil];
#ifdef DEBUG_MODE
                        NSLog(@"%@",QRCodeNotice);
#endif
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"QRCodeResult" object:nil userInfo:QRCodeNotice];
                    });
                    
                }
                
            }failure:^(NSError *err){
                NSLog(@"request failed");
                
            }];
        });
        
    }];
    //
//    [self presentViewController:self.QRCodeReader animated:YES completion:nil];
    [self.navigationController pushViewController:self.QRCodeReader animated:YES];
}
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WaitToPlayTableViewController *waitToPlay = segue.destinationViewController;
    //
    if (self.QRCodeWay) {
        self.QRCodeWay = NO;
        waitToPlay.holeType = @"十八洞";
        waitToPlay.customerCounts = self.cusCount;
        waitToPlay.QRCodeEnable = YES;
        waitToPlay.cusCardArray = self.QRcusCard;
    }
    
}


@end
