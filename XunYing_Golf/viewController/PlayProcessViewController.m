//
//  PlayProcessViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/23.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "PlayProcessViewController.h"
#import "XunYingPre.h"
#import "DBCon.h"
#import "DataTable.h"
#import "HttpTools.h"
#import "UIColor+UICon.h"
#import "GetRequestIPAddress.h"

#define normalHoleState @"01cc00"
#define wasFinished     @"a8a8a8"
#define wasJumped       @"009899"
#define wasPended       @"11acee"
#define illegalJumped   @"ff6600"
#define mendHole        @"3f73bf"
#define finishMendHole  @"847c7a"
#define wasMendedHole   @"6f56aa"
#define wasOrdered      @"cc0098"

typedef enum holeState{
    normalState = 0,
    wasFinishedState,
    wasJumpedState,
    wasPendedState,
    illegalJumpedState,
    mendHoleState,
    finishMendHoleState,
    wasMendedHoleState,
    wasOrderedState
}holeState;

@interface PlayProcessViewController ()<UIAlertViewDelegate>


@property (strong, nonatomic) DBCon *lcDbcon;
@property (strong, nonatomic) DataTable *groupInfo;
@property (strong, nonatomic) DataTable *cusGroInfEmp;
@property (strong, nonatomic) DataTable *holePlanInfo;
@property (strong, nonatomic) DataTable *holesInfo;

@property (strong, nonatomic) NSArray   *holePositionArray;
@property (nonatomic)         NSInteger theSelectNum;
@property (strong, nonatomic) NSArray   *holeStateArray;
@property (strong, nonatomic) UIActivityIndicatorView *stateIndicator;


@property (strong, nonatomic) IBOutlet UIScrollView *playProcessScrollView;

@property (strong, nonatomic) IBOutlet UILabel *displayHoleNumber;
@property (strong, nonatomic) IBOutlet UILabel *displayHoleSubName;
@property (strong, nonatomic) IBOutlet UILabel *holeGroup;
@property (strong, nonatomic) IBOutlet UILabel *golfCourse;
@property (strong, nonatomic) IBOutlet UILabel *currentHoleTime;
@property (strong, nonatomic) IBOutlet UILabel *holePosition;
@property (strong, nonatomic) IBOutlet UILabel *standardTime;

//
@property (strong, nonatomic) IBOutlet UIButton *hole1;
@property (strong, nonatomic) IBOutlet UIButton *hole2;
@property (strong, nonatomic) IBOutlet UIButton *hole3;
@property (strong, nonatomic) IBOutlet UIButton *hole4;
@property (strong, nonatomic) IBOutlet UIButton *hole5;
@property (strong, nonatomic) IBOutlet UIButton *hole6;
@property (strong, nonatomic) IBOutlet UIButton *hole7;
@property (strong, nonatomic) IBOutlet UIButton *hole8;
@property (strong, nonatomic) IBOutlet UIButton *hole9;
@property (strong, nonatomic) IBOutlet UIButton *hole10;
@property (strong, nonatomic) IBOutlet UIButton *hole11;
@property (strong, nonatomic) IBOutlet UIButton *hole12;
@property (strong, nonatomic) IBOutlet UIButton *hole13;
@property (strong, nonatomic) IBOutlet UIButton *hole14;
@property (strong, nonatomic) IBOutlet UIButton *hole15;
@property (strong, nonatomic) IBOutlet UIButton *hole16;
@property (strong, nonatomic) IBOutlet UIButton *hole17;
@property (strong, nonatomic) IBOutlet UIButton *hole18;


- (IBAction)eachHoleState:(UIButton *)sender;
- (IBAction)refreshCurrentState:(UIBarButtonItem *)sender;


@end


@implementation PlayProcessViewController

-(void)viewDidLoad
{
    //
    __weak typeof(self) weakSelf = self;
    //
    [super viewDidLoad];
    //setting scroll View
    self.playProcessScrollView.directionalLockEnabled = YES;
    self.playProcessScrollView.alwaysBounceVertical = YES;
    self.playProcessScrollView.scrollEnabled = YES;
    self.playProcessScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    self.playProcessScrollView.showsVerticalScrollIndicator = YES;
    self.playProcessScrollView.showsHorizontalScrollIndicator = NO;
    self.playProcessScrollView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    //alloc and init
    self.lcDbcon = [[DBCon alloc] init];
    self.groupInfo = [[DataTable alloc] init];
    self.cusGroInfEmp = [[DataTable alloc] init];
    self.holePlanInfo = [[DataTable alloc] init];
    self.holesInfo    = [[DataTable alloc] init];
    //
    self.stateIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 100, ScreenHeight/2 - 100, 200, 200)];
    self.stateIndicator.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.2];
    self.stateIndicator.layer.cornerRadius = 20;
    [self.view addSubview:self.stateIndicator];
    
    self.stateIndicator.hidden = YES;
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf GetPlayProcess];
        
    });
    //添加通知：当请求成功之后，进行页面数据的刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hadRefreshSuccess:) name:@"refreshSuccess" object:nil];
    //
    self.holePositionArray = [[NSArray alloc] initWithObjects:@"发球台",@"球道",@"果岭", nil];
    self.holeStateArray    = [[NSArray alloc] initWithObjects:@"正常",@"被完成",@"被跳过",@"被挂起",@"非法跳过",@"补打",@"补打完成",@"被补打",@"被预定", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ForceBackField:) name:@"forceBackField" object:nil];
    
}

- (void)ForceBackField:(NSNotification *)sender
{
    __weak typeof(self) weakSelf = self;
    if ([sender.userInfo[@"forceBack"] isEqualToString:@"1"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *serverForceBackAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的小组已回场" delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [serverForceBackAlert show];
            
            [weakSelf performSegueWithIdentifier:@"serVerBackField" sender:nil];
        });
        
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
normalState = 0,
wasFinishedState,
wasJumpedState,
wasPendedState,
illegalJumpedState,
mendHoleState,
finishMendHoleState,
wasMendedHoleState,
wasOrderedState
 */
- (void)changeHoleColor:(UIButton *)sender andState:(NSInteger)state
{
    switch (state) {
        case normalState:
            sender.backgroundColor = [UIColor HexString:normalHoleState];
            break;
            
        case wasFinishedState:
            sender.backgroundColor = [UIColor HexString:wasFinished];
            break;
            
        case wasJumpedState:
            sender.backgroundColor = [UIColor HexString:wasJumped];
            break;
            
        case wasPendedState:
            sender.backgroundColor = [UIColor HexString:wasPended];
            break;
            
        case illegalJumpedState:
            sender.backgroundColor = [UIColor HexString:illegalJumped];
            break;
            
        case mendHoleState:
            sender.backgroundColor = [UIColor HexString:mendHole];
            break;
            
        case finishMendHoleState:
            sender.backgroundColor = [UIColor HexString:finishMendHole];
            break;
            
        case wasMendedHoleState:
            sender.backgroundColor = [UIColor HexString:wasMendedHole];
            break;
            
        case wasOrderedState:
            sender.backgroundColor = [UIColor HexString:wasOrdered];
            break;
        default:
            break;
    }
}

- (void)disTheRightStateHoleNum:(NSInteger)HoleNum andState:(NSInteger)state
{
    switch (HoleNum) {
        case 1:
            [self changeHoleColor:self.hole1 andState:state];
            break;
            
        case 2:
            [self changeHoleColor:self.hole2 andState:state];
            break;
            
        case 3:
            [self changeHoleColor:self.hole3 andState:state];
            break;
            
        case 4:
            [self changeHoleColor:self.hole4 andState:state];
            break;
            
        case 5:
            [self changeHoleColor:self.hole5 andState:state];
            break;
            
        case 6:
            [self changeHoleColor:self.hole6 andState:state];
            break;
            
        case 7:
            [self changeHoleColor:self.hole7 andState:state];
            break;
            
        case 8:
            [self changeHoleColor:self.hole8 andState:state];
            break;
            
        case 9:
            [self changeHoleColor:self.hole9 andState:state];
            break;
            
        case 10:
            [self changeHoleColor:self.hole10 andState:state];
            break;
            
        case 11:
            [self changeHoleColor:self.hole11 andState:state];
            break;
            
        case 12:
            [self changeHoleColor:self.hole12 andState:state];
            break;
            
        case 13:
            [self changeHoleColor:self.hole13 andState:state];
            break;
            
        case 14:
            [self changeHoleColor:self.hole14 andState:state];
            break;
            
        case 15:
            [self changeHoleColor:self.hole15 andState:state];
            break;
            
        case 16:
            [self changeHoleColor:self.hole16 andState:state];
            break;
            
        case 17:
            [self changeHoleColor:self.hole17 andState:state];
            break;
            
        case 18:
            [self changeHoleColor:self.hole18 andState:state];
            break;
        default:
            break;
    }
}

#pragma -mark observer
- (void)hadRefreshSuccess:(NSNotification *)sender
{
    __weak typeof(self) weakSelf = self;
    NSLog(@"info:%@",sender.userInfo);
    //
    self.groupInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_groupInf"];
//    self.holesInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_holeInf"];
#ifdef DEBUG_MODE
    NSLog(@"groupInfo:%@",self.groupInfo.Rows);
#endif
    //将相应的数据显示出来
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        if ([weakSelf.groupInfo.Rows count]) {
            //显示球洞组
            weakSelf.holeGroup.text = self.groupInfo.Rows[0][@"hgcod"];
            
        }
        
    });
    //
    if ([sender.userInfo[@"hasRefreshed"] intValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                self.stateIndicator.hidden = YES;
                [self.stateIndicator stopAnimating];
                //
                weakSelf.cusGroInfEmp = [weakSelf.lcDbcon ExecDataTable:@"select *from tbl_CusGroInf"];
                weakSelf.holePlanInfo = [weakSelf.lcDbcon ExecDataTable:@"select *from tbl_holePlanInfo"];
                //将相应的有用信息显示到当前界面中
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakSelf.cusGroInfEmp.Rows count] && [weakSelf.holePlanInfo.Rows count]) {
                        NSString *curHoleCode = weakSelf.cusGroInfEmp.Rows[0][@"nowholcod"];
                        NSArray *allgHolePlanArray = weakSelf.holePlanInfo.Rows;
                        for (NSDictionary *eachHolePlan in allgHolePlanArray) {
                            if ([eachHolePlan[@"holcod"] isEqualToString:curHoleCode]) {
                                //球洞号显示
                                weakSelf.displayHoleNumber.text = eachHolePlan[@"holnum"];
                                 //当前球洞的标准耗时,计算出结果来
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSInteger totalSeconds = [eachHolePlan[@"stadur"] integerValue];
                                    NSInteger hour = totalSeconds/3600;
                                    NSInteger min  = (totalSeconds%3600)/60;
                                    if (hour > 0) {
                                        weakSelf.standardTime.text  = [NSString stringWithFormat:@"%ld时%ld分",hour,min];
                                    }
                                    else
                                        weakSelf.standardTime.text  = [NSString stringWithFormat:@"%ld分",min];
                                });
                                break;
                            }
                                                    }
                        for (NSDictionary *eachHolePlan in allgHolePlanArray)
                        {
                            //切换各个球洞的现实状态 根据各个球洞的状态
//                            NSLog(@"we are here liuc");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self disTheRightStateHoleNum:[eachHolePlan[@"holnum"] integerValue] andState:[eachHolePlan[@"ghsta"] integerValue]];
                                                            });
                        }
                        //显示当前球洞耗时
                        NSInteger curPlayTime = [weakSelf.cusGroInfEmp.Rows[0][@"pladur"] integerValue];
                        NSInteger hour  = curPlayTime/3600;
                        NSInteger min = (curPlayTime%3600)/60;
                        NSInteger second = curPlayTime%60;
                        if (hour > 0) {
                            weakSelf.currentHoleTime.text = [NSString stringWithFormat:@"%ld小时%ld分%ld秒",hour,min
                                                             ,second];
                        }
                        else if (min > 0) {
                            weakSelf.currentHoleTime.text = [NSString stringWithFormat:@"%ld分%ld秒",min,second];
                        }
                        else{
                            weakSelf.currentHoleTime.text = [NSString stringWithFormat:@"%ld秒",second];
                        }
                        //查询球洞别名并显示
                        NSString *_curHoleCode = weakSelf.cusGroInfEmp.Rows[0][@"nowholcod"];
                        NSArray *allHolesInfoArray = weakSelf.holesInfo.Rows;
                        for (NSDictionary *eachHole in allHolesInfoArray) {
                            if ([eachHole[@"holcod"] isEqualToString:_curHoleCode]) {
                                weakSelf.displayHoleSubName.text = eachHole[@"holnam"];
                                break;
                            }
                        }
                        //显示球洞位置@"发球台",@"球道",@"果岭"
                        NSString *curHolePosStr = [[NSString alloc] init];//当前所在球洞的位置
                        switch ([weakSelf.cusGroInfEmp.Rows[0][@"nowblocks"] intValue]) {
                                //发球台
                            case 1:
                                curHolePosStr = weakSelf.holePositionArray[0];
                                break;
                                //球道
                            case 2:
                                curHolePosStr = weakSelf.holePositionArray[1];
                                break;
                                //果岭
                            case 3:
                                curHolePosStr = weakSelf.holePositionArray[2];
                                break;
                            default:
                                break;
                        }
                        //
                        weakSelf.holePosition.text = curHolePosStr;
                        
                    }
                    
                });
            });
    }
    
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma -mark viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
//    __weak typeof(self) weakSelf = self;
    //read some data for request(check the database)
    self.groupInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_groupInf"];
    self.holesInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_holeInf"];
//    NSLog(@"groupInfo:%@",self.groupInfo.Rows);
//    //将相应的数据显示出来
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self.holesInfo.Rows count]) {
//            //显示球洞别名
//            weakSelf.displayHoleSubName.text = self.holesInfo.Rows[0][@"holnam"];
//            
//        }
//        //
//        if ([self.groupInfo.Rows count]) {
//            //显示球洞组
//            weakSelf.holeGroup.text = self.groupInfo.Rows[0][@"hgcod"];
//            
//        }
//        
//        
//    });
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"enter viewDidAppear");
    
    
}
#pragma -mark GetPlayProcess
- (void)GetPlayProcess
{
    __weak typeof(self) weakSelf = self;
    //construct request parameter
    if (![self.groupInfo.Rows count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取数据异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    //
    self.stateIndicator.hidden = NO;
    [self.stateIndicator startAnimating];
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //
    NSMutableDictionary *refreshParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.groupInfo.Rows[0][@"grocod"],@"grocod", nil];
    //
    NSString *playProcessURLStr;
    playProcessURLStr = [GetRequestIPAddress getPlayProcessURL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //start request
        [HttpTools getHttp:playProcessURLStr forParams:refreshParam success:^(NSData *nsData){
            NSLog(@"success refresh");
//            NSDictionary *latestDataDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *latestDataDic;
            latestDataDic = (NSDictionary *)nsData;
            
            if ([latestDataDic[@"Code"] intValue] > 0) {
                //delete the old data
                [weakSelf.lcDbcon ExecNonQuery:@"delete from tbl_CusGroInf"];
                [weakSelf.lcDbcon ExecNonQuery:@"delete from tbl_holePlanInfo"];
                //
                dispatch_async(dispatch_get_main_queue(), ^{
                    //客户组对象
                    NSMutableArray *cusGroInfPart = [[NSMutableArray alloc] initWithObjects:latestDataDic[@"Msg"][@"appGroupE"][@"grocod"],latestDataDic[@"Msg"][@"appGroupE"][@"grosta"],latestDataDic[@"Msg"][@"appGroupE"][@"nextgrodistime"],latestDataDic[@"Msg"][@"appGroupE"][@"nowblocks"],latestDataDic[@"Msg"][@"appGroupE"][@"nowholcod"],latestDataDic[@"Msg"][@"appGroupE"][@"nowholnum"],latestDataDic[@"Msg"][@"appGroupE"][@"pladur"],latestDataDic[@"Msg"][@"appGroupE"][@"stahol"],latestDataDic[@"Msg"][@"appGroupE"][@"statim"],latestDataDic[@"Msg"][@"appGroupE"][@"stddur"], nil];
                    //tbl_CusGroInf(grocod text,grosta text,nextgrodistime text,nowblocks text,nowholcod text,nowholnum text,pladur text,stahol text,statim text,stddur text)
                    [self.lcDbcon ExecNonQuery:@"insert into tbl_CusGroInf(grocod,grosta,nextgrodistime,nowblocks,nowholcod,nowholnum,pladur,stahol,statim,stddur) values(?,?,?,?,?,?,?,?,?,?)" forParameter:cusGroInfPart];
                    //球洞规划组对象
                    NSArray *allGroHoleList = latestDataDic[@"Msg"][@"groholelist"];
                    //
                    if ((NSNull *)allGroHoleList != [NSNull null]) {
                        for (NSDictionary *eachHoleInf in allGroHoleList) {
                            NSMutableArray *eachHoleInfParam = [[NSMutableArray alloc] initWithObjects:eachHoleInf[@"ghcod"],eachHoleInf[@"ghind"],eachHoleInf[@"ghsta"],eachHoleInf[@"grocod"],eachHoleInf[@"gronum"],eachHoleInf[@"holcod"],eachHoleInf[@"holnum"],eachHoleInf[@"pintim"],eachHoleInf[@"pladur"],eachHoleInf[@"poutim"],eachHoleInf[@"rintim"],eachHoleInf[@"routim"],eachHoleInf[@"stadur"], nil];
                            //tbl_holePlanInfo(ghcod text,ghind text,ghsta text,grocod text,gronum text,holcod text,holnum text,pintim text,pladur text,poutim text,rintim text,routim text,stadur text)
                            [weakSelf.lcDbcon ExecNonQuery:@"insert into tbl_holePlanInfo(ghcod,ghind,ghsta,grocod,gronum,holcod,holnum,pintim,pladur,poutim,rintim,routim,stadur) values(?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleInfParam];
                        }
                    }
                    //通知数据已经更新了
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSuccess" object:nil userInfo:@{@"hasRefreshed":@"1"}];
                    
                });
            }
            
        }failure:^(NSError *err){
            NSLog(@"refresh failled and err:%@",err);
            self.stateIndicator.hidden = YES;
            [self.stateIndicator stopAnimating];
            //
            UIAlertView *errAlert = [[UIAlertView alloc] initWithTitle:@"网络请求异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [errAlert show];
        }];
    });
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __weak typeof(self) weakSelf = self;
    
    if (alertView.tag == 1) {
        //
        switch (buttonIndex) {
            case 0:
                
                break;
                //
            case 1:
                if (![self.holePlanInfo.Rows count]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"参数异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alert show];
                    return;
                }
                //
                //获取到mid号码
                NSString *theMid;
                theMid = [GetRequestIPAddress getUniqueID];
                theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
                //组建参数
                NSMutableDictionary *makeHoleCompleteParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.groupInfo.Rows[0][@"grocod"],@"grocod",self.holePlanInfo.Rows[self.theSelectNum - 1][@"holcod"],@"holecode", nil];
                //
                NSString *completeStateURLStr;
                completeStateURLStr = [GetRequestIPAddress getMakeHoleCompleteStateURL];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //发送更改请求
                    [HttpTools getHttp:completeStateURLStr forParams:makeHoleCompleteParam success:^(NSData *nsData){
//                        NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
                        NSDictionary *recDic;
                        recDic = (NSDictionary *)nsData;
                        
                        NSLog(@"recDic Msg:%@",recDic[@"Msg"]);
                        //
                        if ([recDic[@"Code"] intValue] > 0) {
                            NSLog(@"正常");
                            [weakSelf GetPlayProcess];
                            
                        }
                        
                        else if ([recDic[@"Code"] intValue] == -3) {
                            NSLog(@"发生错误");
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该球洞已经被完成了，不能进行此操作" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                            [alert show];
                        }
                        
                        
                        
                    }failure:^(NSError *err){
                        NSLog(@"request failed");
                    }];
                });
                
                
                
                break;
        }
        
    }
    
}


- (IBAction)eachHoleState:(UIButton *)sender {
    NSLog(@"enter eachHoleState,button.Tag:%ld;button.title:%@",(long)sender.tag,sender.titleLabel.text);
    //
    self.theSelectNum = sender.tag + 1;
    //查询数据库
    self.holePlanInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_holePlanInfo"];
    self.groupInfo = [self.lcDbcon ExecDataTable:@"select *from tbl_groupInf"];
    //
    if (![self.holePlanInfo.Rows count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"参数异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    if ((sender.tag + 1) > [self.holePlanInfo.Rows count]) {
        UIAlertView *errAlert = [[UIAlertView alloc] initWithTitle:@"当前球洞不可操作" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [errAlert show];
        return;
    }
    
    //
    NSString *curSelectHoleName = [NSString stringWithFormat:@"%ld号球洞",sender.tag + 1];//当前所在球洞提示
    //
    NSInteger holeNum = [self.holePlanInfo.Rows[sender.tag][@"ghsta"] integerValue];
    NSString  *planInTime = self.holePlanInfo.Rows[sender.tag][@"pintim"];
    planInTime = [planInTime substringFromIndex:11];
    NSInteger totalSeconds = [self.holePlanInfo.Rows[sender.tag][@"stadur"] integerValue];
    NSInteger hour = totalSeconds/3600;
    NSInteger min  = (totalSeconds%3600)/60;
    NSInteger second = totalSeconds%60;
    NSString  *standardTime;// = [[NSString alloc] init];
    if (hour > 0) {
        standardTime = [NSString stringWithFormat:@"%ld时%ld分%ld秒",(long)hour,(long)min,(long)second];
    }
    else if(min > 0)
    {
        standardTime = [NSString stringWithFormat:@"%ld分%ld秒",(long)min,(long)second];
    }
    else
    {
        standardTime = [NSString stringWithFormat:@"%ld秒",(long)second];
    }
    NSString *planOutTime = self.holePlanInfo.Rows[sender.tag][@"poutim"];
    planOutTime = [NSString stringWithFormat:@"%@",[planOutTime substringFromIndex:11]];
    
    NSString *subMsg = [NSString stringWithFormat:@" 打球状态   %@ \n计划进入时间   %@\n   标准耗时   %@\n计划离开时间   %@",self.holeStateArray[holeNum],planInTime,standardTime,planOutTime];
    //
    UIAlertView *changeHoleStateAlert = [[UIAlertView alloc] initWithTitle:curSelectHoleName message:subMsg delegate:self cancelButtonTitle:@" 取 消 " otherButtonTitles:@"改为被完成", nil];
    changeHoleStateAlert.tag = 1;//到时候改成1
    [changeHoleStateAlert show];
}

- (IBAction)refreshCurrentState:(UIBarButtonItem *)sender {
    NSLog(@"refresh Current");
    [self GetPlayProcess];
    
}
@end
