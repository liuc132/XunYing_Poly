//
//  JumpHoleViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/10/13.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "JumpHoleViewController.h"
#import "HttpTools.h"
#import "XunYingPre.h"
#import "UIColor+UICon.h"
#import "DataTable.h"
#import "DBCon.h"
#import "TaskDetailViewController.h"
#import "GetRequestIPAddress.h"

#define CurrentHole     @"5ccd73"
#define SelectedHole    @"f74c30"
#define NoSelectedHole  @"cacaca"
#define canSelect       @"0197d6"
#define EitghteenHoles  18

@interface JumpHoleViewController ()

@property (strong, nonatomic) DBCon *locDBCon;
@property (strong, nonatomic) DataTable *logPerson;
@property (strong, nonatomic) DataTable *holesInf;
@property (strong, nonatomic) DataTable *grpInf;
@property (strong, nonatomic) DataTable *curLocInfo;
@property (strong, nonatomic) DataTable *jumpHoleResult;
@property (strong, nonatomic) DataTable *holePlanInfo;
@property (strong, nonatomic) DataTable *cusGroInfEmp;

@property (nonatomic) NSInteger selectedJumpNum;
@property (nonatomic) BOOL      whetherSelectHole;

@property (strong, nonatomic) UIButton *theOldSelectedBtn;
@property (strong, nonatomic) NSDictionary *eventInfoDic;
@property (nonatomic)           BOOL        toTaskDetailEnable;



@property (strong, nonatomic) IBOutlet UIScrollView *jumpHoleScrollView;

@property (strong, nonatomic) IBOutlet UILabel *requestPerson;
@property (strong, nonatomic) IBOutlet UILabel *curHoleNum;
@property (strong, nonatomic) IBOutlet UILabel *jumpHoleNum;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *jumpHoleBack;
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


- (IBAction)whichHole:(UIButton *)sender;

- (IBAction)jumpHoleNavBack:(UIBarButtonItem *)sender;

- (IBAction)requestToJumpHole:(UIButton *)sender;

@end

@implementation JumpHoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //alloc and init locDBCon,userInf,grpInf
    self.locDBCon = [[DBCon alloc] init];
    self.logPerson = [[DataTable alloc] init];
    self.holesInf = [[DataTable alloc] init];
    self.curLocInfo = [[DataTable alloc] init];
    self.jumpHoleResult = [[DataTable alloc] init];
    self.grpInf         = [[DataTable alloc] init];
    self.holePlanInfo   = [[DataTable alloc] init];
    self.cusGroInfEmp   = [[DataTable alloc] init];
    //
    self.toTaskDetailEnable =   NO;
    //
    self.whetherSelectHole = NO;
    self.jumpHoleNum.text  = nil;
    //查询申请跳洞的登录人的信息，以及所创建的组信息
    self.logPerson = [self.locDBCon ExecDataTable:@"select *from tbl_logPerson"];
    self.holesInf = [self.locDBCon ExecDataTable:@"select *from tbl_holeInf"];
    self.curLocInfo = [self.locDBCon ExecDataTable:@"select *from tbl_locHole"];
    self.grpInf     = [self.locDBCon ExecDataTable:@"select *from tbl_groupInf"];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventFromHeart:) name:@"refreshSuccessJumpHole" object:nil];
    //
    self.jumpHoleScrollView.scrollEnabled = YES;
    self.jumpHoleScrollView.alwaysBounceVertical = YES;
    self.jumpHoleScrollView.directionalLockEnabled = YES;
    
    NSLog(@"finish check out all the data");
    
    //
    [self GetPlayProcess];
    //init all holebutton's color
    [self initAllHolesColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ForceBackField:) name:@"forceBackField" object:nil];
    
}

- (void)ForceBackField:(NSNotification *)sender
{
    __weak typeof(self) weakSelf = self;
    if ([sender.userInfo[@"forceBack"] isEqualToString:@"1"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //
        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *serverForceBackAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的小组已回场" delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//            [serverForceBackAlert show];
            
            [weakSelf performSegueWithIdentifier:@"serVerBackField" sender:nil];
        });
        
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initAllHolesColor
{
    self.hole1.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole2.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole3.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole4.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole5.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole6.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole7.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole8.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole9.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole10.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole11.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole12.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole13.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole14.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole15.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole16.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole17.backgroundColor = [UIColor HexString:NoSelectedHole];
    self.hole18.backgroundColor = [UIColor HexString:NoSelectedHole];
}

- (void)disTheRightHoleState
{
    //首先查询数据库
    self.holePlanInfo = [self.locDBCon ExecDataTable:@"select *from tbl_holePlanInfo"];
    self.cusGroInfEmp = [self.locDBCon ExecDataTable:@"select *from tbl_CusGroInf"];
//    NSLog(@"%@",self.holePlanInfo.Rows);
    //
    for (NSDictionary *eachHole in self.holePlanInfo.Rows) {
        if ([eachHole[@"holcod"] isEqualToString:[NSString stringWithFormat:@"%@",self.cusGroInfEmp.Rows[0][@"nowholcod"]]]) {
            //查询到当前所在的球洞
            [self settingAllHolesRightState:[eachHole[@"holnum"] integerValue] andState:1];
        }
        else if([eachHole[@"ghsta"] intValue] == 0)
        {
            [self settingAllHolesRightState:[eachHole[@"holnum"] integerValue] andState:3];
        }
        else
        {
            [self settingAllHolesRightState:[eachHole[@"holnum"] integerValue] andState:0];
        }
    }
}

- (void)getEventFromHeart:(NSNotification *)sender
{
    if ([sender.userInfo[@"hasRefreshedJumpHole"] isEqualToString:@"1"]) {
        [self disTheRightHoleState];
    }
}

- (void)holeState:(UIButton *)hole andState:(NSInteger)state
{
    switch (state) {
        case 0://不能选择
            hole.backgroundColor = [UIColor HexString:NoSelectedHole];
            break;
            
        case 1://当前所在球洞
            hole.backgroundColor = [UIColor HexString:CurrentHole];
            break;
            
        case 2://选择的球洞
            hole.backgroundColor = [UIColor HexString:SelectedHole];
            break;
            
        case 3://可以选择的球洞
            hole.backgroundColor = [UIColor HexString:canSelect];
            break;
        default:
            break;
    }
}

- (void)settingAllHolesRightState:(NSInteger)holeNum andState:(NSInteger)holeState
{
    switch (holeNum) {
        case 1:
            [self holeState:self.hole1 andState:holeState];
            break;
            
        case 2:
            [self holeState:self.hole2 andState:holeState];
            break;
            
        case 3:
            [self holeState:self.hole3 andState:holeState];
            break;
            
        case 4:
            [self holeState:self.hole4 andState:holeState];
            break;
            
        case 5:
            [self holeState:self.hole5 andState:holeState];
            break;
            
        case 6:
            [self holeState:self.hole6 andState:holeState];
            break;
            
        case 7:
            [self holeState:self.hole7 andState:holeState];
            break;
            
        case 8:
            [self holeState:self.hole8 andState:holeState];
            break;
            
        case 9:
            [self holeState:self.hole9 andState:holeState];
            break;
            
        case 10:
            [self holeState:self.hole10 andState:holeState];
            break;
            
        case 11:
            [self holeState:self.hole11 andState:holeState];
            break;
            
        case 12:
            [self holeState:self.hole12 andState:holeState];
            break;
            
        case 13:
            [self holeState:self.hole13 andState:holeState];
            break;
            
        case 14:
            [self holeState:self.hole14 andState:holeState];
            break;
            
        case 15:
            [self holeState:self.hole15 andState:holeState];
            break;
            
        case 16:
            [self holeState:self.hole16 andState:holeState];
            break;
            
        case 17:
            [self holeState:self.hole17 andState:holeState];
            break;
            
        case 18:
            [self holeState:self.hole18 andState:holeState];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    //将申请人等信息给显示到相应位置
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.logPerson.Rows count]) {
            weakSelf.requestPerson.text = [NSString stringWithFormat:@"%@ %@",weakSelf.logPerson.Rows[0][@"number"],self.logPerson.Rows[0][@"name"]];
        }
        //将当前所在的球洞位置的球洞号显示出来 tbl_locHole(holcod text,holnum text)
        if ([weakSelf.curLocInfo.Rows count]) {
            weakSelf.curHoleNum.text = weakSelf.curLocInfo.Rows[[weakSelf.curLocInfo.Rows count] - 1][@"holnum"];
        }
        
    });
    
}

-(void)settingBackGoundColor:(UIButton *)theOldBtn
{
    [theOldBtn setBackgroundColor:[UIColor HexString:NoSelectedHole]];
}

- (IBAction)whichHole:(UIButton *)sender {
    static unsigned char ucOldSelectedHole = 20;
    
    if(ucOldSelectedHole != sender.tag)
    {
        //记录下之前所选择的球洞按键
        self.theOldSelectedBtn = sender;
        //查询当前所选择的球洞是否可操作
        for (NSDictionary *eachHoleState in self.holePlanInfo.Rows) {
            if ([eachHoleState[@"holnum"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)sender.tag]]) {
                if ([eachHoleState[@"ghsta"] intValue] == 0) {//该条件说明该球洞的状态可以被选择
                    self.jumpHoleNum.text = [NSString stringWithFormat:@"%ld",(long)sender.tag];
                    //
                    self.selectedJumpNum = sender.tag - 1;
                    
                    //确认已经选过了
                    self.whetherSelectHole = YES;
                    
                    [self disTheRightHoleState];
                    //设置被选择上的球洞好的背景色为已选状态
                    [sender setBackgroundColor:[UIColor HexString:SelectedHole]];
                    break;
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该球洞不可选" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alert show];
                }
            }
        }
        
    }
    
}

- (IBAction)jumpHoleNavBack:(UIBarButtonItem *)sender {
    //
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)requestToJumpHole:(UIButton *)sender {
    
    __weak JumpHoleViewController *weakSelf = self;
    //判断是否已经选好了要跳过的球洞
    if (!self.whetherSelectHole) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择跳过的球洞" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
//    self.whetherSelectHole = NO;
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //组建跳动请求参数
    NSMutableDictionary *jumpHoleParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.logPerson.Rows[0][@"code"],@"code",self.holesInf.Rows[self.selectedJumpNum][@"holcod"],@"aplcod", nil];
    //
    NSString *jumpHoleURLStr;
    jumpHoleURLStr = [GetRequestIPAddress getJumpHoleURL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //start request
        [HttpTools getHttp:jumpHoleURLStr forParams:jumpHoleParam success:^(NSData *nsData){
            JumpHoleViewController *strongSelf = weakSelf;
            NSLog(@"JumpHole request success");
            
//            NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *recDic;
            recDic = (NSDictionary *)nsData;
            NSLog(@"code:%@  msg:%@",recDic[@"Code"],recDic[@"Msg"]);
            //
            if ([recDic[@"Code"] intValue] > 0) {
                NSDictionary *allMsg = recDic[@"Msg"];
                
                //
                NSMutableArray *changeCaddyBackInfo = [[NSMutableArray alloc] initWithObjects:allMsg[@"evecod"],@"3",allMsg[@"evesta"],allMsg[@"subtim"],allMsg[@"everes"][@"result"],allMsg[@"everes"][@"everea"],allMsg[@"hantim"],@"",@"",@"",@"",weakSelf.holesInf.Rows[weakSelf.selectedJumpNum][@"holcod"],@"",@"",@"",@"",@"",@"",@"",@"", nil];
                [weakSelf.locDBCon ExecNonQuery:@"insert into tbl_taskInfo(evecod,evetyp,evesta,subtim,result,everea,hantim,oldCaddyCode,newCaddyCode,oldCartCode,newCartCode,jumpHoleCode,toHoleCode,destintime,reqBackTime,reHoleCode,mendHoleCode,ratifyHoleCode,ratifyinTime,selectedHoleCode) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:changeCaddyBackInfo];
                //
                self.toTaskDetailEnable =   YES;
                //执行跳转
                [strongSelf performSegueWithIdentifier:@"toTaskDetail" sender:nil];
            }
            else if ([recDic[@"Code"] intValue] == -6)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"申请跳过的球洞已经不是待打球洞了" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
            
            
        }failure:^(NSError *err){
            NSLog(@"JumpHole request fail");
            
            
        }];
    });
    
    
}

#pragma -mark GetPlayProcess
- (void)GetPlayProcess
{
    __weak typeof(self) weakSelf = self;
    //construct request parameter
    if (![self.grpInf.Rows count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取数据异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //
    NSMutableDictionary *refreshParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.grpInf.Rows[0][@"grocod"],@"grocod", nil];
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
                [weakSelf.locDBCon ExecNonQuery:@"delete from tbl_CusGroInf"];
                [weakSelf.locDBCon ExecNonQuery:@"delete from tbl_holePlanInfo"];
                //
                dispatch_async(dispatch_get_main_queue(), ^{
                    //客户组对象
                    NSMutableArray *cusGroInfPart = [[NSMutableArray alloc] initWithObjects:latestDataDic[@"Msg"][@"appGroupE"][@"grocod"],latestDataDic[@"Msg"][@"appGroupE"][@"grosta"],latestDataDic[@"Msg"][@"appGroupE"][@"nextgrodistime"],latestDataDic[@"Msg"][@"appGroupE"][@"nowblocks"],latestDataDic[@"Msg"][@"appGroupE"][@"nowholcod"],latestDataDic[@"Msg"][@"appGroupE"][@"nowholnum"],latestDataDic[@"Msg"][@"appGroupE"][@"pladur"],latestDataDic[@"Msg"][@"appGroupE"][@"stahol"],latestDataDic[@"Msg"][@"appGroupE"][@"statim"],latestDataDic[@"Msg"][@"appGroupE"][@"stddur"], nil];
                    //tbl_CusGroInf(grocod text,grosta text,nextgrodistime text,nowblocks text,nowholcod text,nowholnum text,pladur text,stahol text,statim text,stddur text)
                    [self.locDBCon ExecNonQuery:@"insert into tbl_CusGroInf(grocod,grosta,nextgrodistime,nowblocks,nowholcod,nowholnum,pladur,stahol,statim,stddur) values(?,?,?,?,?,?,?,?,?,?)" forParameter:cusGroInfPart];
                    //球洞规划组对象
                    NSArray *allGroHoleList = latestDataDic[@"Msg"][@"groholelist"];
                    for (NSDictionary *eachHoleInf in allGroHoleList) {
                        NSMutableArray *eachHoleInfParam = [[NSMutableArray alloc] initWithObjects:eachHoleInf[@"ghcod"],eachHoleInf[@"ghind"],eachHoleInf[@"ghsta"],eachHoleInf[@"grocod"],eachHoleInf[@"gronum"],eachHoleInf[@"holcod"],eachHoleInf[@"holnum"],eachHoleInf[@"pintim"],eachHoleInf[@"pladur"],eachHoleInf[@"poutim"],eachHoleInf[@"rintim"],eachHoleInf[@"routim"],eachHoleInf[@"stadur"], nil];
                        //tbl_holePlanInfo(ghcod text,ghind text,ghsta text,grocod text,gronum text,holcod text,holnum text,pintim text,pladur text,poutim text,rintim text,routim text,stadur text)
                        [weakSelf.locDBCon ExecNonQuery:@"insert into tbl_holePlanInfo(ghcod,ghind,ghsta,grocod,gronum,holcod,holnum,pintim,pladur,poutim,rintim,routim,stadur) values(?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleInfParam];
                    }
                    //通知数据已经更新了
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSuccessJumpHole" object:nil userInfo:@{@"hasRefreshedJumpHole":@"1"}];
                    
                });
            }
            
        }failure:^(NSError *err){
            NSLog(@"refresh failled and err:%@",err);
            
            
        }];
    });
    
    
}

//将相应的信息传到相应的界面中
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (!self.toTaskDetailEnable) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    TaskDetailViewController *taskViewController = segue.destinationViewController;
    taskViewController.taskTypeName = @"跳洞详情";
    //查询数据库
    self.jumpHoleResult = [self.locDBCon ExecDataTable:@"select *from tbl_taskInfo"];
    //
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([weakSelf.jumpHoleResult.Rows count]) {
            NSString *resultStr = [[NSString alloc] init];
            switch ([weakSelf.jumpHoleResult.Rows[0][@"result"] intValue]) {
                case 0:
                    resultStr = @"待处理";
                    break;
                case 1:
                    resultStr = @"同意";
                    break;
                case 2:
                    resultStr = @"不同意";
                    break;
                default:
                    break;
            }
            taskViewController.whichInterfaceFrom = 1;
            
            taskViewController.taskStatus = resultStr;
            taskViewController.taskRequestPerson = [NSString stringWithFormat:@"%@ %@",weakSelf.logPerson.Rows[0][@"number"],weakSelf.logPerson.Rows[0][@"name"]];
            NSString *subtime = weakSelf.jumpHoleResult.Rows[[weakSelf.jumpHoleResult.Rows count] - 1][@"subtim"];
            taskViewController.taskRequstTime = [subtime substringFromIndex:11];
            taskViewController.taskDetailName = @"跳过球洞";
            //
            NSString *willJumpHoleCode = [NSString stringWithFormat:@"%@",weakSelf.jumpHoleResult.Rows[[weakSelf.jumpHoleResult.Rows count] - 1][@"jumpHoleCode"]];
            NSArray *allHoleArray = self.holesInf.Rows;
            for (NSDictionary *eachHole in allHoleArray) {
                if ([eachHole[@"holcod"] isEqualToString:willJumpHoleCode]) {
                    taskViewController.taskJumpHoleNum = [NSString stringWithFormat:@"%@",eachHole[@"holenum"]];
                }
                
            }
            taskViewController.selectRowNum = [weakSelf.jumpHoleResult.Rows count] - 1;
            
        }
        
        
    });
    
}


@end
