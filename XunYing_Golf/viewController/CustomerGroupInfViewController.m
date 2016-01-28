//
//  CustomerGroupInfViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/10/9.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "CustomerGroupInfViewController.h"
#import "DBCon.h"
#import "DataTable.h"
#import "HttpTools.h"
#import "XunYingPre.h"
#import "GetRequestIPAddress.h"
#import "UIColor+UICon.h"

@interface CustomerGroupInfViewController ()<UIAlertViewDelegate>


@property (strong, nonatomic) DBCon *cusGroupDBCon;
@property (strong, nonatomic) DataTable *cusGroupInf;
@property (strong, nonatomic) DataTable *padInfTable;
@property (strong, nonatomic) DataTable *locInfTable;
@property (strong, nonatomic) DataTable *curGrpCaddies;
@property (strong, nonatomic) DataTable *groupInfo;
@property (strong, nonatomic) DataTable *allHoleInfo;
@property (strong, nonatomic) DataTable *curSelectedCustomers;
@property (strong, nonatomic) DataTable *selectedCartInfo;

@property (strong, nonatomic) NSArray   *playStateArray;

@property (strong, nonatomic) UIActivityIndicatorView *stateIndicator;


@property (strong, nonatomic) IBOutlet UIScrollView *cusInfScrollView;

@property (strong, nonatomic) IBOutlet UILabel *firstCusName;
@property (strong, nonatomic) IBOutlet UILabel *firstCusNumber;
@property (strong, nonatomic) IBOutlet UILabel *secondCusName;
@property (strong, nonatomic) IBOutlet UILabel *secondCusNumber;
@property (strong, nonatomic) IBOutlet UILabel *thirdCusName;
@property (strong, nonatomic) IBOutlet UILabel *thirdCusNumber;
@property (strong, nonatomic) IBOutlet UILabel *fourthCusName;
@property (strong, nonatomic) IBOutlet UILabel *fourthCusNumber;

@property (strong, nonatomic) IBOutlet UILabel *firstCaddyName;
@property (strong, nonatomic) IBOutlet UILabel *firstCaddyNumber;
@property (strong, nonatomic) IBOutlet UILabel *secondCaddyName;
@property (strong, nonatomic) IBOutlet UILabel *secondCaddyNumber;

@property (strong, nonatomic) IBOutlet UILabel *firstCartNumber;
@property (strong, nonatomic) IBOutlet UILabel *firstCartSeats;
@property (strong, nonatomic) IBOutlet UILabel *secondCartNumber;
@property (strong, nonatomic) IBOutlet UILabel *seconCartSeats;

@property (strong, nonatomic) IBOutlet UILabel *panelNumber;

@property (strong, nonatomic) IBOutlet UILabel *groupCode;
@property (strong, nonatomic) IBOutlet UILabel *downCourtTime;
@property (strong, nonatomic) IBOutlet UILabel *totalPlayTime;
@property (strong, nonatomic) IBOutlet UILabel *standardFinishTime;
@property (strong, nonatomic) IBOutlet UILabel *playState;
@property (strong, nonatomic) IBOutlet UILabel *startHoleNumber;
@property (strong, nonatomic) IBOutlet UILabel *currentHoleNumber;
@property (strong, nonatomic) IBOutlet UILabel *holeType;//显示上九洞，下九洞，十八洞





- (IBAction)backToField:(UIBarButtonItem *)sender;


@end

@implementation CustomerGroupInfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    //alloc and init cusGroupDBCon and cusGroupInf
    self.cusGroupDBCon = [[DBCon alloc] init];
    self.cusGroupInf   = [[DataTable alloc] init];
    self.padInfTable   = [[DataTable alloc] init];
    self.locInfTable   = [[DataTable alloc] init];
    self.groupInfo     = [[DataTable alloc] init];
    self.allHoleInfo   = [[DataTable alloc] init];
    self.curSelectedCustomers = [[DataTable alloc] init];
    self.selectedCartInfo     = [[DataTable alloc] init];
    //初始化球洞状态 0正常 1较慢 2慢 3前方有慢组 4球洞较慢 5球洞慢
    self.playStateArray = [[NSArray alloc] initWithObjects:@"正常",@"较慢",@"慢",@"前方有慢组",@"球洞较慢",@"球洞慢", nil];
    //setting uiscrollView
    self.cusInfScrollView.directionalLockEnabled = YES;
    self.cusInfScrollView.alwaysBounceVertical = YES;
    self.cusInfScrollView.scrollEnabled = YES;
    self.cusInfScrollView.showsHorizontalScrollIndicator = NO;
    self.cusInfScrollView.showsVerticalScrollIndicator = YES;
    self.cusInfScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    self.cusInfScrollView.contentInset = UIEdgeInsetsMake(0, 0, 85, 0);
    //查询相应的信息
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        weakSelf.cusGroupInf = [weakSelf.cusGroupDBCon ExecDataTable:@"select *from tbl_groupHeartInf"];
        weakSelf.padInfTable = [weakSelf.cusGroupDBCon ExecDataTable:@"select *from tbl_padInfo"];
        weakSelf.locInfTable = [weakSelf.cusGroupDBCon ExecDataTable:@"select *from tbl_locHole"];
        weakSelf.curGrpCaddies   = [weakSelf.cusGroupDBCon ExecDataTable:@"select *from tbl_addCaddy"];
        weakSelf.groupInfo   = [weakSelf.cusGroupDBCon ExecDataTable:@"select *from tbl_groupInf"];
        weakSelf.allHoleInfo = [weakSelf.cusGroupDBCon ExecDataTable:@"select *from tbl_holeInf"];
        weakSelf.curSelectedCustomers = [weakSelf.cusGroupDBCon ExecDataTable:@"select *from tbl_CustomersInfo"];
        weakSelf.selectedCartInfo     = [weakSelf.cusGroupDBCon ExecDataTable:@"select *from tbl_selectCart"];
        //将相应的信息显示出来
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf constructDisInf];
        });
    });
    
    self.stateIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 100, ScreenHeight/2 - 100, 200, 200)];
    self.stateIndicator.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.2];
    self.stateIndicator.layer.cornerRadius = 20;
    [self.view addSubview:self.stateIndicator];
    
    self.stateIndicator.hidden = YES;
    
#ifdef DEBUG_MODE
    NSLog(@"finish search");
#endif
    
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
    //
    [self.stateIndicator stopAnimating];
    self.stateIndicator.hidden = YES;
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


-(void)constructDisInf
{
    NSLog(@"construct DisInf");
    //
    if ([self.cusGroupInf.Rows count]) {
        //下场时间
        NSString *downTime = self.cusGroupInf.Rows[0][@"statim"];
        self.downCourtTime.text = [downTime substringWithRange:NSMakeRange(11, 5)];
        //打球时长
        NSInteger totalPlayTimeInt = [self.cusGroupInf.Rows[0][@"pladur"] integerValue];
        NSInteger hour = totalPlayTimeInt/3600;
        NSInteger min  = (totalPlayTimeInt%3600)/60;
        if (hour > 0) {
            self.totalPlayTime.text = [NSString stringWithFormat:@"%ld时%ld分",hour,min];
        }
        else
        {
            self.totalPlayTime.text = [NSString stringWithFormat:@"%ld分",min];
        }
        //标准时长
        NSInteger stdPlayTimeInt = [self.cusGroupInf.Rows[0][@"stddur"] integerValue];
        NSInteger stdhour = stdPlayTimeInt/3600;
        NSInteger stdmin  = (stdPlayTimeInt%3600)/60;
        if (stdhour > 0) {
            self.standardFinishTime.text = [NSString stringWithFormat:@"%ld时%ld分",stdhour,stdmin];
        }
        else
        {
            self.standardFinishTime.text = [NSString stringWithFormat:@"%ld分",stdmin];
        }
        //开始球洞
        NSString *startHoleNum = [[NSString alloc] init];//在下边的查询中赋值
        NSString *startHoleCode = [NSString stringWithFormat:@"%@",self.cusGroupInf.Rows[0][@"stahol"]];
        NSArray *allHolesArray = self.allHoleInfo.Rows;
        //查询出开始球洞的code所对应的球洞号码
        for (NSDictionary *eachHole in allHolesArray) {
            if ([eachHole[@"holcod"] isEqualToString:startHoleCode]) {
                startHoleNum = eachHole[@"holenum"];
            }
        }
        
        self.startHoleNumber.text    = startHoleNum;
        //当前所在球洞
        self.currentHoleNumber.text  = self.cusGroupInf.Rows[0][@"nowholnum"];
        //当球的打球状态
        self.playState.text     = self.playStateArray[[self.cusGroupInf.Rows[0][@"grosta"] intValue]];
        
    }
    //
    if ([self.padInfTable.Rows count]) {
        self.panelNumber.text = self.padInfTable.Rows[0][@"padnum"];
    }
    //
    if ([self.locInfTable.Rows count]) {
        self.currentHoleNumber.text  = self.locInfTable.Rows[0][@"holnum"];
    }
    //获取球洞组，组编号
    if ([self.groupInfo.Rows count]) {
        //组编号
        NSString *gropNumStr;// = [[NSString alloc] init];
        gropNumStr = self.groupInfo.Rows[0][@"gronum"];
        //将组编号显示出来
        if ([gropNumStr hasPrefix:@"_"]) {
            self.groupCode.text = gropNumStr;
        }
        else
            self.groupCode.text = [gropNumStr substringToIndex:3];
        //显示当前所选择的球洞的类型
        self.holeType.text  = self.groupInfo.Rows[0][@"hgcod"];
        
    }
    //显示当前的球童的信息
    switch ([self.curGrpCaddies.Rows count]) {
        case 0:
            self.firstCaddyName.hidden = YES;
            self.firstCaddyNumber.hidden = YES;
            self.secondCaddyName.hidden = YES;
            self.secondCaddyNumber.hidden = YES;
            break;
            //
        case 1:
            self.firstCaddyName.text = self.curGrpCaddies.Rows[0][@"cadnam"];
            self.firstCaddyNumber.text = self.curGrpCaddies.Rows[0][@"cadnum"];
            //hide
            self.secondCaddyName.hidden = YES;
            self.secondCaddyNumber.hidden = YES;
            
            break;
            //
        case 2:
            self.firstCaddyName.text = self.curGrpCaddies.Rows[0][@"cadnam"];
            self.firstCaddyNumber.text = self.curGrpCaddies.Rows[0][@"cadnum"];
            self.secondCaddyName.text = self.curGrpCaddies.Rows[1][@"cadnam"];
            self.secondCaddyNumber.text = self.curGrpCaddies.Rows[1][@"cadnum"];
            break;
            
            
        default:
            break;
    }
    //显示当前的所有客户的名称
    switch ([self.curSelectedCustomers.Rows count]) {
        case 0:
            self.firstCusName.hidden = YES;
            self.firstCusNumber.hidden = YES;
            self.secondCusName.hidden = YES;
            self.secondCusNumber.hidden = YES;
            self.thirdCusName.hidden = YES;
            self.thirdCusNumber.hidden = YES;
            self.fourthCusName.hidden = YES;
            self.fourthCusNumber.hidden = YES;
            
            break;
        case 1:
            self.firstCusName.hidden = NO;
            self.firstCusNumber.hidden = NO;
            self.secondCusName.hidden = YES;
            self.secondCusNumber.hidden = YES;
            self.thirdCusName.hidden = YES;
            self.thirdCusNumber.hidden = YES;
            self.fourthCusName.hidden = YES;
            self.fourthCusNumber.hidden = YES;
            //将信息显示出来
            //1
            self.firstCusName.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[0][@"cusnam"] isEmpty]?@"客户1":self.curSelectedCustomers.Rows[0][@"cusnam"]];
            self.firstCusNumber.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[0][@"cusnum"] isEmpty]?@"057":self.curSelectedCustomers.Rows[0][@"cusnum"]];
            
            break;
        case 2:
            self.firstCusName.hidden = NO;
            self.firstCusNumber.hidden = NO;
            self.secondCusName.hidden = NO;
            self.secondCusNumber.hidden = NO;
            self.thirdCusName.hidden = YES;
            self.thirdCusNumber.hidden = YES;
            self.fourthCusName.hidden = YES;
            self.fourthCusNumber.hidden = YES;
            //
            //将信息显示出来
            //1
            self.firstCusName.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[0][@"cusnam"] isEmpty]?@"客户1":self.curSelectedCustomers.Rows[0][@"cusnam"]];
            self.firstCusNumber.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[0][@"cusnum"] isEmpty]?@"057":self.curSelectedCustomers.Rows[0][@"cusnum"]];
            //2
            self.secondCusName.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[1][@"cusnam"] isEmpty]?@"客户2":self.curSelectedCustomers.Rows[1][@"cusnam"]];
            self.secondCusNumber.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[1][@"cusnum"] isEmpty]?@"057":self.curSelectedCustomers.Rows[1][@"cusnum"]];
            
            break;
        case 3:
            self.firstCusName.hidden = NO;
            self.firstCusNumber.hidden = NO;
            self.secondCusName.hidden = NO;
            self.secondCusNumber.hidden = NO;
            self.thirdCusName.hidden = NO;
            self.thirdCusNumber.hidden = NO;
            self.fourthCusName.hidden = YES;
            self.fourthCusNumber.hidden = YES;
            //
            //将信息显示出来
            //1
            self.firstCusName.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[0][@"cusnam"] isEmpty]?@"客户1":self.curSelectedCustomers.Rows[0][@"cusnam"]];
            self.firstCusNumber.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[0][@"cusnum"] isEmpty]?@"057":self.curSelectedCustomers.Rows[0][@"cusnum"]];
            //2
            self.secondCusName.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[1][@"cusnam"] isEmpty]?@"客户2":self.curSelectedCustomers.Rows[1][@"cusnam"]];
            self.secondCusNumber.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[1][@"cusnum"] isEmpty]?@"057":self.curSelectedCustomers.Rows[1][@"cusnum"]];
            //3
            self.thirdCusName.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[2][@"cusnam"] isEmpty]?@"客户3":self.curSelectedCustomers.Rows[2][@"cusnam"]];
            self.thirdCusNumber.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[2][@"cusnum"] isEmpty]?@"057":self.curSelectedCustomers.Rows[2][@"cusnum"]];
            
            break;
        case 4:
            self.firstCusName.hidden = NO;
            self.firstCusNumber.hidden = NO;
            self.secondCusName.hidden = NO;
            self.secondCusNumber.hidden = NO;
            self.thirdCusName.hidden = NO;
            self.thirdCusNumber.hidden = NO;
            self.fourthCusName.hidden = NO;
            self.fourthCusNumber.hidden = NO;
            //
            //将信息显示出来
            //1
            self.firstCusName.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[0][@"cusnam"] isEmpty]?@"客户1":self.curSelectedCustomers.Rows[0][@"cusnam"]];
            self.firstCusNumber.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[0][@"cusnum"] isEmpty]?@"057":self.curSelectedCustomers.Rows[0][@"cusnum"]];
            //2
            self.secondCusName.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[1][@"cusnam"] isEmpty]?@"客户2":self.curSelectedCustomers.Rows[1][@"cusnam"]];
            self.secondCusNumber.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[1][@"cusnum"] isEmpty]?@"057":self.curSelectedCustomers.Rows[1][@"cusnum"]];
            //3
            self.thirdCusName.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[2][@"cusnam"] isEmpty]?@"客户3":self.curSelectedCustomers.Rows[2][@"cusnam"]];
            self.thirdCusNumber.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[2][@"cusnum"] isEmpty]?@"057":self.curSelectedCustomers.Rows[2][@"cusnum"]];
            //4
            self.fourthCusName.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[3][@"cusnam"] isEmpty]?@"客户4":self.curSelectedCustomers.Rows[3][@"cusnam"]];
            self.fourthCusNumber.text = [NSString stringWithFormat:@"%@",[self.curSelectedCustomers.Rows[3][@"cusnum"] isEmpty]?@"057":self.curSelectedCustomers.Rows[3][@"cusnum"]];
            
            break;
            
        default:
            break;
    }
    //显示球车的信息
    switch ([self.selectedCartInfo.Rows count]) {
            //没有选球车
        case 0:
            self.firstCartNumber.hidden = YES;
            self.firstCartSeats.hidden  = YES;
            self.secondCartNumber.hidden = YES;
            self.seconCartSeats.hidden = YES;
            break;
            //只选了一个球车
        case 1:
            self.firstCartNumber.hidden = NO;
            self.firstCartSeats.hidden  = NO;
            self.secondCartNumber.hidden = YES;
            self.seconCartSeats.hidden  = YES;
            //
            self.firstCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[0][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[0][@"carnum"]];
            self.firstCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[0][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[0][@"carsea"]];
            
            break;
            //选了两个球车
        case 2:
            self.firstCartNumber.hidden = NO;
            self.firstCartSeats.hidden  = NO;
            self.secondCartNumber.hidden = NO;
            self.seconCartSeats.hidden  = NO;
            //将相应的信息显示出来
            //1
            self.firstCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[0][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[0][@"carnum"]];
            self.firstCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[0][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[0][@"carsea"]];
            //2
            self.secondCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[1][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[1][@"carnum"]];
            self.seconCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[1][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[1][@"carsea"]];
            
            break;
        default:
            break;
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //初始化显示信息
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)BackField
{
    NSLog(@"执行回场");
    //调用回场接口所需要的参数是：mid:移动端AMEI码   grocod:小组code
    self.cusGroupInf = [self.cusGroupDBCon ExecDataTable:@"select *from tbl_groupInf"];
    //先判断数据是否为空，不为空则进行下一步操作
    if(![self.cusGroupInf.Rows count])
    {
        //进行提示
        UIAlertView *errAlertView = [[UIAlertView alloc] initWithTitle:@"回场失败" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [errAlertView show];
        
        //为空，则直接退出
        return;
    }
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //数据不为空，则进行数据组装
    NSMutableDictionary *backToFieldParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.cusGroupInf.Rows[0][@"grocod"],@"grocod", nil];
    __weak CustomerGroupInfViewController *weakSelf = self;
    //
    NSString *backFieldURLStr;
    backFieldURLStr = [GetRequestIPAddress getBackToFieldURL];
    //
    [self.stateIndicator startAnimating];
    self.stateIndicator.hidden = NO;
    
    dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC ) ;
    dispatch_after(time,dispatch_get_main_queue(), ^{
        //进行网络请求
        [HttpTools getHttp:backFieldURLStr forParams:backToFieldParam success:^(NSData *nsData){
            
            CustomerGroupInfViewController *strongSelf = weakSelf;
            
//            NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *recDic;// = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            recDic = (NSDictionary *)nsData;
            NSLog(@"back to the field msg:%@",recDic[@"Msg"]);
            
            if ([recDic[@"Code"] intValue] > 0) {
                //删除掉本地保存的事务信息数据
                [strongSelf.cusGroupDBCon ExecNonQuery:@"delete from tbl_taskChangeCartInfo"];
                [strongSelf.cusGroupDBCon ExecNonQuery:@"delete from tbl_taskChangeCaddyInfo"];
                [strongSelf.cusGroupDBCon ExecNonQuery:@"delete from tbl_taskJumpHoleInfo"];
                [strongSelf.cusGroupDBCon ExecNonQuery:@"delete from tbl_taskLeaveRest"];
                [strongSelf.cusGroupDBCon ExecNonQuery:@"delete from tbl_taskMendHoleInfo"];
                [strongSelf.cusGroupDBCon ExecNonQuery:@"delete from tbl_taskInfo"];
                [strongSelf.cusGroupDBCon ExecNonQuery:@"delete from tbl_groupInf"];
                //
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HeartBeat" object:nil userInfo:@{@"disableHeart":@"1"}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //执行跳转程序，跳转到建组方式选择界面
                    [strongSelf performSegueWithIdentifier:@"backToField" sender:nil];
                });
            }
            else
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
                
            }
            
        }failure:^(NSError *err){
            //NSLog(@"回场失败");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"回场失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            //
            [self.stateIndicator stopAnimating];
            self.stateIndicator.hidden = YES;
        }];
    });
    

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        switch (buttonIndex) {
            case 0:
                
                break;
                
            case 1:
                [self BackField];
                break;
            default:
                break;
        }
    }
}

- (IBAction)backToField:(UIBarButtonItem *)sender {
    UIAlertView *backFieldAlert = [[UIAlertView alloc] initWithTitle:@"确定回场吗?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    backFieldAlert.tag = 1;
    [backFieldAlert show];
    
}
@end
