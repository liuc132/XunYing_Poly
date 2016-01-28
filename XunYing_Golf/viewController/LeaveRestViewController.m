//
//  LeaveRestViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/11/24.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "LeaveRestViewController.h"
#import "CurTaskCenterTableViewController.h"
#import "DataTable.h"
#import "DBCon.h"
#import "XunYingPre.h"
#import "HttpTools.h"
#import "TaskDetailViewController.h"
#import "GetRequestIPAddress.h"

@interface LeaveRestViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSArray *hourString;
    NSArray *minString;
    NSString *separateString;
}


@property (strong, nonatomic) DBCon *lcDBCon;
@property (strong, nonatomic) DataTable *logPerson;
@property (strong, nonatomic) DataTable *leaveRestResult;
@property (strong, nonatomic) DataTable *holesPlanInfo;
@property (strong, nonatomic) DataTable *cusGrpInfo;
@property (strong, nonatomic) DataTable *grpInfo;
@property (strong, nonatomic) NSDictionary *eventInfoDic;
@property (nonatomic)         BOOL         toTaskDetailEnable;


@property (strong, nonatomic) IBOutlet UILabel *requestPerson;
@property (strong, nonatomic) IBOutlet UILabel *currentHole;
@property (strong, nonatomic) IBOutlet UIPickerView *selectTime;



- (IBAction)recoverTimeComfirm:(UIButton *)sender;
- (IBAction)backToMain:(UIBarButtonItem *)sender;
- (IBAction)requestToLeave:(UIButton *)sender;


@end

@implementation LeaveRestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectTime.delegate = self;
    //
    //
    self.lcDBCon = [[DBCon alloc] init];
    self.logPerson = [[DataTable alloc] init];
    self.leaveRestResult = [[DataTable alloc] init];
    self.holesPlanInfo       = [[DataTable alloc] init];
    self.cusGrpInfo      = [[DataTable alloc] init];
    self.grpInfo         = [[DataTable alloc] init];
    //
    self.toTaskDetailEnable =   NO;
    //
    hourString = @[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"];
    minString = @[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59"];
    separateString = @":";
    //查询申请人的信息
    self.logPerson = [self.lcDBCon ExecDataTable:@"select *from tbl_logPerson"];
    self.grpInfo   = [self.lcDBCon ExecDataTable:@"select *from tbl_groupInf"];
    
    //init a notificationcenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventFromHeart:) name:@"LocleaveToRest" object:nil];
    //
    self.selectTime.dataSource = self;
    self.selectTime.delegate   = self;
    //
    NSDateFormatter *dateFarmatter = [[NSDateFormatter alloc] init];
    [dateFarmatter setDateFormat:@"HH:mm:ss"];
    NSString *curDateTime = [dateFarmatter stringFromDate:[NSDate date]];
    //
    NSInteger hourRow = [[curDateTime substringToIndex:2] integerValue];
    NSRange range = NSMakeRange(3, 2);
    NSInteger minRow = [[curDateTime substringWithRange:range] integerValue];
    //
    
    [self.selectTime selectRow:hourRow inComponent:0 animated:YES];
    [self.selectTime selectRow:minRow inComponent:2 animated:YES];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTheLatestInfo:) name:@"LocleaveToRest" object:nil];
    //
    [self GetPlayProcess];
    
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

- (void)getTheLatestInfo:(NSNotification *)sender
{
    self.holesPlanInfo = [self.lcDBCon ExecDataTable:@"select *from tbl_holePlanInfo"];
    self.cusGrpInfo    = [self.lcDBCon ExecDataTable:@"select *from tbl_CusGroInf"];
    if ([sender.userInfo[@"hasRefreshedLeaveRest"] isEqualToString:@"1"]) {
        for (NSDictionary *eachHole in self.holesPlanInfo.Rows) {
            if ([eachHole[@"holcod"] isEqualToString:[NSString stringWithFormat:@"%@",self.cusGrpInfo.Rows[0][@"nowholcod"]]]) {
                //查询到当前所在的球洞
                self.currentHole.text = [NSString stringWithFormat:@"%@号",eachHole[@"holnum"]];
                break;
            }
            
        }
    }
}

- (void)getEventFromHeart:(NSNotification *)sender
{
    self.eventInfoDic = sender.userInfo;
    NSLog(@"ChangeCart info:%@ and eventInfoDic:%@",sender.userInfo,self.eventInfoDic);
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    if ([self.logPerson.Rows count]) {
        self.requestPerson.text = [NSString stringWithFormat:@"%@ %@",self.logPerson.Rows[0][@"number"],self.logPerson.Rows[0][@"name"]];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    CurTaskCenterTableViewController *curTaskMainView = segue.destinationViewController;
//    curTaskMainView.leaveTime = @"2015-10-9 15:12:40";
//}


- (IBAction)recoverTimeComfirm:(UIButton *)sender {
    
}

- (IBAction)backToMain:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)requestToLeave:(UIButton *)sender {
    NSLog(@"enter to leave");
    __weak typeof(self) weakSelf = self;
    //判断所取得的数据是否为空
    if (![self.logPerson.Rows count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求异常" message:@"参数为空" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //获取到当前系统的时间，并生成相应的格式
    NSDateFormatter *dateFarmatter = [[NSDateFormatter alloc] init];
    [dateFarmatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *curDateTime = [dateFarmatter stringFromDate:[NSDate date]];
    //组装数据,恢复时间以及已经完成的球洞规划表编码（这个目前设计中为空） 设置为空
    NSMutableDictionary *requestToLeaveParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.logPerson.Rows[0][@"code"],@"empcod",@"",@"finishcods",curDateTime,@"retime", nil];
    //
    NSString *leaveTimeURLStr;
    leaveTimeURLStr = [GetRequestIPAddress getRequestLeaveTimeURL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //开始请求
        [HttpTools getHttp:leaveTimeURLStr forParams:requestToLeaveParam success:^(NSData *nsData){
//            NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *recDic;
            recDic = (NSDictionary *)nsData;
            
            NSLog(@"recDic:%@",recDic);
            //
            if ([recDic[@"Code"] intValue] > 0) {
                //tbl_taskLeaveRest(evecod text,everea text,result text,evesta text,subtim text,hantim text,,reholeCode text)
                NSDictionary *allMsg = recDic[@"Msg"];
                //            NSMutableArray *leaveRestBackInfo = [[NSMutableArray alloc] initWithObjects:allMsg[@"evecod"],allMsg[@"everes"][@"everea"],allMsg[@"everes"][@"result"],allMsg[@"evesta"],allMsg[@"subtim"],allMsg[@"hantim"],@"", nil];
                //            [weakSelf.lcDBCon ExecNonQuery:@"insert into tbl_taskLeaveRest(evecod,everea,result,evesta,subtim,hantim,reholeCode) values(?,?,?,?,?,?,?)" forParameter:leaveRestBackInfo];
                //
                NSMutableArray *changeCaddyBackInfo = [[NSMutableArray alloc] initWithObjects:allMsg[@"evecod"],@"6",allMsg[@"evesta"],allMsg[@"subtim"],allMsg[@"everes"][@"result"],allMsg[@"everes"][@"everea"],allMsg[@"hantim"],@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
                [weakSelf.lcDBCon ExecNonQuery:@"insert into tbl_taskInfo(evecod,evetyp,evesta,subtim,result,everea,hantim,oldCaddyCode,newCaddyCode,oldCartCode,newCartCode,jumpHoleCode,toHoleCode,destintime,reqBackTime,reHoleCode,mendHoleCode,ratifyHoleCode,ratifyinTime,selectedHoleCode) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:changeCaddyBackInfo];
                //
                self.toTaskDetailEnable =   YES;
                //
                [weakSelf performSegueWithIdentifier:@"toTaskDetail" sender:nil];
            }
            else
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
            
            
        }failure:^(NSError *err){
            NSLog(@"request to leave failled");
            
        }];
    });
    
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger _row;
    _row = 0; 
    switch (component) {
        case 0:
            _row = [hourString count];
            break;
            
        case 1:
            _row = 1;
            break;
            
        case 2:
            _row = [minString count];
            break;
        default:
            break;
    }
    
    return _row;
}
//获取到当前选择的参数
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0 || component == 2) {
        [pickerView reloadComponent:2];
        NSInteger rowOne = [pickerView selectedRowInComponent:0];
        NSInteger rowThree = [pickerView selectedRowInComponent:2];
        
        NSString *_hourStr = hourString[rowOne];
        NSString *_minStr  = minString[rowThree];
        
        NSLog(@"hour:%@ min:%@",_hourStr,_minStr);
    }
    
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnSting;
    switch (component) {
        case 0:
            returnSting = [hourString objectAtIndex:row];
            break;
        case 1:
            returnSting = separateString;
            break;
        case 2:
            returnSting = [minString objectAtIndex:row];
            break;
        default:
            break;
    }
    //
    return returnSting;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 40.0;
}

//将相应的信息传到相应的界面中
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (!self.toTaskDetailEnable) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    TaskDetailViewController *taskViewController = segue.destinationViewController;
    taskViewController.taskTypeName = @"离场休息详情";
    //查询数据库
    self.leaveRestResult = [self.lcDBCon ExecDataTable:@"select *from tbl_taskInfo"];
    //
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *resultStr = [[NSString alloc] init];
        switch ([weakSelf.leaveRestResult.Rows[0][@"result"] intValue]) {
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
        NSString *subtime = weakSelf.leaveRestResult.Rows[[weakSelf.leaveRestResult.Rows count] - 1][@"subtim"];
        taskViewController.taskRequstTime = [subtime substringFromIndex:11];
        taskViewController.taskDetailName = @"申请的恢复时间";
        taskViewController.taskLeaveRebacktime   = @"";//[NSString stringWithFormat:@"%@",weakSelf.leaveRestResult.Rows[[weakSelf.leaveRestResult.Rows count] - 1][@"oldCaddy"]];
        taskViewController.selectRowNum = [weakSelf.leaveRestResult.Rows count] - 1;
        
    });
}

#pragma -mark GetPlayProcess
- (void)GetPlayProcess
{
    __weak typeof(self) weakSelf = self;
    //construct request parameter
    if (![self.grpInfo.Rows count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取数据异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //
    NSMutableDictionary *refreshParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.grpInfo.Rows[0][@"grocod"],@"grocod", nil];
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
                [weakSelf.lcDBCon ExecNonQuery:@"delete from tbl_CusGroInf"];
                [weakSelf.lcDBCon ExecNonQuery:@"delete from tbl_holePlanInfo"];
                //
                dispatch_async(dispatch_get_main_queue(), ^{
                    //客户组对象
                    NSMutableArray *cusGroInfPart = [[NSMutableArray alloc] initWithObjects:latestDataDic[@"Msg"][@"appGroupE"][@"grocod"],latestDataDic[@"Msg"][@"appGroupE"][@"grosta"],latestDataDic[@"Msg"][@"appGroupE"][@"nextgrodistime"],latestDataDic[@"Msg"][@"appGroupE"][@"nowblocks"],latestDataDic[@"Msg"][@"appGroupE"][@"nowholcod"],latestDataDic[@"Msg"][@"appGroupE"][@"nowholnum"],latestDataDic[@"Msg"][@"appGroupE"][@"pladur"],latestDataDic[@"Msg"][@"appGroupE"][@"stahol"],latestDataDic[@"Msg"][@"appGroupE"][@"statim"],latestDataDic[@"Msg"][@"appGroupE"][@"stddur"], nil];
                    //tbl_CusGroInf(grocod text,grosta text,nextgrodistime text,nowblocks text,nowholcod text,nowholnum text,pladur text,stahol text,statim text,stddur text)
                    [self.lcDBCon ExecNonQuery:@"insert into tbl_CusGroInf(grocod,grosta,nextgrodistime,nowblocks,nowholcod,nowholnum,pladur,stahol,statim,stddur) values(?,?,?,?,?,?,?,?,?,?)" forParameter:cusGroInfPart];
                    //球洞规划组对象
                    NSArray *allGroHoleList = latestDataDic[@"Msg"][@"groholelist"];
                    for (NSDictionary *eachHoleInf in allGroHoleList) {
                        NSMutableArray *eachHoleInfParam = [[NSMutableArray alloc] initWithObjects:eachHoleInf[@"ghcod"],eachHoleInf[@"ghind"],eachHoleInf[@"ghsta"],eachHoleInf[@"grocod"],eachHoleInf[@"gronum"],eachHoleInf[@"holcod"],eachHoleInf[@"holnum"],eachHoleInf[@"pintim"],eachHoleInf[@"pladur"],eachHoleInf[@"poutim"],eachHoleInf[@"rintim"],eachHoleInf[@"routim"],eachHoleInf[@"stadur"], nil];
                        //tbl_holePlanInfo(ghcod text,ghind text,ghsta text,grocod text,gronum text,holcod text,holnum text,pintim text,pladur text,poutim text,rintim text,routim text,stadur text)
                        [weakSelf.lcDBCon ExecNonQuery:@"insert into tbl_holePlanInfo(ghcod,ghind,ghsta,grocod,gronum,holcod,holnum,pintim,pladur,poutim,rintim,routim,stadur) values(?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachHoleInfParam];
                    }
                    //通知数据已经更新了
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LocleaveToRest" object:nil userInfo:@{@"hasRefreshedLeaveRest":@"1"}];
                    
                });
            }
            
        }failure:^(NSError *err){
            NSLog(@"refresh failled and err:%@",err);
            
            
        }];
    });
    
    
}

@end
