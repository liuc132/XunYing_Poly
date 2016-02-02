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
@property (strong, nonatomic) DataTable *heartGroInfo;

@property (assign, nonatomic) NSInteger         theCourseIndex;
@property (strong, nonatomic) NSString          *curCourseTag;
@property (strong, nonatomic) NSString          *startTime;

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
@property (weak, nonatomic) IBOutlet UILabel *thirdCaddyName;
@property (weak, nonatomic) IBOutlet UILabel *thirdCaddyNumber;
@property (weak, nonatomic) IBOutlet UILabel *fourthCaddyName;
@property (weak, nonatomic) IBOutlet UILabel *fourthCaddyNumber;



@property (strong, nonatomic) IBOutlet UILabel *firstCartNumber;
@property (strong, nonatomic) IBOutlet UILabel *firstCartSeats;
@property (strong, nonatomic) IBOutlet UILabel *secondCartNumber;
@property (strong, nonatomic) IBOutlet UILabel *seconCartSeats;
@property (weak, nonatomic) IBOutlet UILabel *thirdCartNumber;
@property (weak, nonatomic) IBOutlet UILabel *thirdCartSeats;
@property (weak, nonatomic) IBOutlet UILabel *fourthCartNumber;
@property (weak, nonatomic) IBOutlet UILabel *fourthCartSeats;



@property (strong, nonatomic) IBOutlet UILabel *panelNumber;

@property (strong, nonatomic) IBOutlet UILabel *groupCode;
@property (strong, nonatomic) IBOutlet UILabel *downCourtTime;
@property (strong, nonatomic) IBOutlet UILabel *totalPlayTime;
@property (strong, nonatomic) IBOutlet UILabel *standardFinishTime;
@property (strong, nonatomic) IBOutlet UILabel *playState;
@property (strong, nonatomic) IBOutlet UILabel *startHoleNumber;
@property (strong, nonatomic) IBOutlet UILabel *currentHoleNumber;
@property (strong, nonatomic) IBOutlet UILabel *holeType;//显示上九洞，下九洞，十八洞
@property (weak, nonatomic) IBOutlet UILabel *fieldPosition;//南场，北场





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
    self.heartGroInfo         = [[DataTable alloc] init];
    //
    self.startTime = [[NSString alloc] init];
    //
    self.heartGroInfo = [self.cusGroupDBCon ExecDataTable:@"select *from tbl_groupHeartInf"];
    
    if ([self.heartGroInfo.Rows count]) {
        self.curCourseTag = self.heartGroInfo.Rows[0][@"coursegrouptag"];
        self.startTime    = self.heartGroInfo.Rows[0][@"statim"];
    }
    else
        self.curCourseTag = @"north";
    //判断
    if ([self.curCourseTag isEqualToString:@"north"]) {
        self.theCourseIndex = 0;
    }
    else if ([self.curCourseTag isEqualToString:@"south"])
    {
        self.theCourseIndex = 1;
    }
    
    //初始化球洞状态 0正常 1较慢 2慢 3前方有慢组 4球洞较慢 5球洞慢
    self.playStateArray = [[NSArray alloc] initWithObjects:@"正常",@"较慢",@"慢",@"前方有慢组",@"球洞较慢",@"球洞慢", nil];
    //setting uiscrollView
    self.cusInfScrollView.directionalLockEnabled = YES;
    self.cusInfScrollView.alwaysBounceVertical = YES;
    self.cusInfScrollView.scrollEnabled = YES;
    self.cusInfScrollView.showsHorizontalScrollIndicator = NO;
    self.cusInfScrollView.showsVerticalScrollIndicator = YES;
    self.cusInfScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    self.cusInfScrollView.contentInset = UIEdgeInsetsMake(0, 0, 160, 0);
    
    
    self.stateIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 100, ScreenHeight/2 - 100, 200, 200)];
    self.stateIndicator.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.2];
    self.stateIndicator.layer.cornerRadius = 20;
    [self.view addSubview:self.stateIndicator];
    
    self.stateIndicator.hidden = YES;
    
#ifdef DEBUG_MODE
    NSLog(@"finish search");
#endif
    //开启进度条显示
    [self.stateIndicator startAnimating];
    self.stateIndicator.hidden = NO;
    //查询相应的信息
    dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC ) ;
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [weakSelf refreshAllData];
    });
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ForceBackField:) name:@"forceBackField" object:nil];
    //添加通知，接受心跳里边的相应的参数，进而来确定是否切换球场whetherCanSwitchCourse
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWhetherSwitchCourse:) name:@"whetherCanSwitchCourse1" object:nil];
    
    
}

- (void)ForceBackField:(NSNotification *)sender
{
    __weak typeof(self) weakSelf = self;
    if ([sender.userInfo[@"forceBack"] isEqualToString:@"1"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf performSegueWithIdentifier:@"backToField" sender:nil];
        });
    }
}

- (void)getWhetherSwitchCourse:(NSNotification *)sender
{
    __weak typeof(self) weakSelf = self;
    //
    if (![sender.name isEqualToString:@"whetherCanSwitchCourse1"]) {
        return;
    }
    //
    self.curCourseTag = sender.userInfo[@"curCourseTag1"];
    NSString *curStartTime;
    curStartTime = sender.userInfo[@"startTime1"];
    //判断
    if ([self.curCourseTag isEqualToString:@"north"]) {
        if (self.theCourseIndex == 0) {
            if ([curStartTime isEqualToString:self.startTime]) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.startTime = curStartTime;
            });
        }
        self.theCourseIndex = 0;
    }
    else if ([self.curCourseTag isEqualToString:@"south"])
    {
        if (self.theCourseIndex ==1) {
            if ([curStartTime isEqualToString:self.startTime]) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.startTime = curStartTime;
            });
        }
        self.theCourseIndex = 1;
    }
    
    NSLog(@"startTime:%@  curStartTime:%@",self.startTime,curStartTime);
    //开启进度条显示
    [self.stateIndicator startAnimating];
    self.stateIndicator.hidden = NO;
    //更新数据
    dispatch_time_t time = dispatch_time ( DISPATCH_TIME_NOW , 1ull * NSEC_PER_SEC ) ;
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [weakSelf refreshAllData];
    });
    
}

- (void)refreshAllData{
    
    //
    self.cusGroupInf = [self.cusGroupDBCon ExecDataTable:@"select *from tbl_groupHeartInf"];
    self.padInfTable = [self.cusGroupDBCon ExecDataTable:@"select *from tbl_padInfo"];
    self.locInfTable = [self.cusGroupDBCon ExecDataTable:@"select *from tbl_locHole"];
    self.curGrpCaddies   = [self.cusGroupDBCon ExecDataTable:@"select *from tbl_addCaddy"];
    self.groupInfo   = [self.cusGroupDBCon ExecDataTable:@"select *from tbl_groupInf"];
    self.allHoleInfo = [self.cusGroupDBCon ExecDataTable:@"select *from tbl_holeInf"];
    self.curSelectedCustomers = [self.cusGroupDBCon ExecDataTable:@"select *from tbl_CustomersInfo"];
    self.selectedCartInfo     = [self.cusGroupDBCon ExecDataTable:@"select *from tbl_selectCart"];
    //将相应的信息显示出来
    dispatch_async(dispatch_get_main_queue(), ^{
        [self constructDisInf];
    });
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
        //但前所在的球场的位置
        NSString *fieldName;
        NSString *fieldNameStr;
        fieldNameStr = [NSString stringWithFormat:@"%@",self.cusGroupInf.Rows[0][@"coursegrouptag"]];
        if ([fieldNameStr isEqualToString:@"north"]) {
            fieldName = @"北场";
        }
        else if ([fieldNameStr isEqualToString:@"south"])
        {
            fieldName = @"南场";
        }
        
        self.fieldPosition.text = fieldName;
        
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
            self.thirdCaddyName.hidden = YES;
            self.thirdCaddyNumber.hidden = YES;
            self.fourthCaddyName.hidden = YES;
            self.fourthCaddyNumber.hidden = YES;
            
            break;
            //
        case 1:
            self.firstCaddyName.text = self.curGrpCaddies.Rows[0][@"cadnam"];
            self.firstCaddyNumber.text = self.curGrpCaddies.Rows[0][@"cadnum"];
            //hide
            self.secondCaddyName.hidden = YES;
            self.secondCaddyNumber.hidden = YES;
            self.thirdCaddyName.hidden = YES;
            self.thirdCaddyNumber.hidden = YES;
            self.fourthCaddyName.hidden = YES;
            self.fourthCaddyNumber.hidden = YES;
            
            break;
            //
        case 2:
            self.firstCaddyName.text = self.curGrpCaddies.Rows[0][@"cadnam"];
            self.firstCaddyNumber.text = self.curGrpCaddies.Rows[0][@"cadnum"];
            self.secondCaddyName.text = self.curGrpCaddies.Rows[1][@"cadnam"];
            self.secondCaddyNumber.text = self.curGrpCaddies.Rows[1][@"cadnum"];
            self.thirdCaddyName.hidden = YES;
            self.thirdCaddyNumber.hidden = YES;
            self.fourthCaddyName.hidden = YES;
            self.fourthCaddyNumber.hidden = YES;
            break;
            //
        case 3:
            self.firstCaddyName.text = self.curGrpCaddies.Rows[0][@"cadnam"];
            self.firstCaddyNumber.text = self.curGrpCaddies.Rows[0][@"cadnum"];
            self.secondCaddyName.text = self.curGrpCaddies.Rows[1][@"cadnam"];
            self.secondCaddyNumber.text = self.curGrpCaddies.Rows[1][@"cadnum"];
            self.thirdCaddyName.text = self.curGrpCaddies.Rows[2][@"cadnam"];
            self.thirdCaddyNumber.text = self.curGrpCaddies.Rows[2][@"cadnum"];
            //
            self.fourthCaddyName.hidden = YES;
            self.fourthCaddyNumber.hidden = YES;
            
            break;
            
        case 4:
            self.firstCaddyName.text = self.curGrpCaddies.Rows[0][@"cadnam"];
            self.firstCaddyNumber.text = self.curGrpCaddies.Rows[0][@"cadnum"];
            self.secondCaddyName.text = self.curGrpCaddies.Rows[1][@"cadnam"];
            self.secondCaddyNumber.text = self.curGrpCaddies.Rows[1][@"cadnum"];
            self.thirdCaddyName.text = self.curGrpCaddies.Rows[2][@"cadnam"];
            self.thirdCaddyNumber.text = self.curGrpCaddies.Rows[2][@"cadnum"];
            self.fourthCaddyName.text = self.curGrpCaddies.Rows[3][@"cadnam"];
            self.fourthCaddyNumber.text = self.curGrpCaddies.Rows[3][@"cadnum"];
            
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
            self.thirdCartNumber.hidden = YES;
            self.thirdCartSeats.hidden = YES;
            self.fourthCartNumber.hidden = YES;
            self.fourthCartSeats.hidden = YES;
            
            break;
            //只选了一个球车
        case 1:
            self.firstCartNumber.hidden = NO;
            self.firstCartSeats.hidden  = NO;
            self.secondCartNumber.hidden = YES;
            self.seconCartSeats.hidden  = YES;
            self.thirdCartNumber.hidden = YES;
            self.thirdCartSeats.hidden = YES;
            self.fourthCartNumber.hidden = YES;
            self.fourthCartSeats.hidden = YES;
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
            self.thirdCartNumber.hidden = YES;
            self.thirdCartSeats.hidden = YES;
            self.fourthCartNumber.hidden = YES;
            self.fourthCartSeats.hidden = YES;
            //将相应的信息显示出来
            //1
            self.firstCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[0][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[0][@"carnum"]];
            self.firstCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[0][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[0][@"carsea"]];
            //2
            self.secondCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[1][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[1][@"carnum"]];
            self.seconCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[1][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[1][@"carsea"]];
            
            break;
            //
        case 3:
            self.firstCartNumber.hidden = NO;
            self.firstCartSeats.hidden  = NO;
            self.secondCartNumber.hidden = NO;
            self.seconCartSeats.hidden  = NO;
            self.thirdCartNumber.hidden = NO;
            self.thirdCartSeats.hidden = NO;
            self.fourthCartNumber.hidden = YES;
            self.fourthCartSeats.hidden = YES;
            //
            //将相应的信息显示出来
            //1
            self.firstCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[0][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[0][@"carnum"]];
            self.firstCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[0][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[0][@"carsea"]];
            //2
            self.secondCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[1][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[1][@"carnum"]];
            self.seconCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[1][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[1][@"carsea"]];
            //3
            self.thirdCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[2][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[2][@"carnum"]];
            self.thirdCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[2][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[2][@"carsea"]];
            
            break;
            //
        case 4:
            self.firstCartNumber.hidden = NO;
            self.firstCartSeats.hidden  = NO;
            self.secondCartNumber.hidden = NO;
            self.seconCartSeats.hidden  = NO;
            self.thirdCartNumber.hidden = NO;
            self.thirdCartSeats.hidden = NO;
            self.fourthCartNumber.hidden = NO;
            self.fourthCartSeats.hidden = NO;
            //
            //将相应的信息显示出来
            //1
            self.firstCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[0][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[0][@"carnum"]];
            self.firstCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[0][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[0][@"carsea"]];
            //2
            self.secondCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[1][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[1][@"carnum"]];
            self.seconCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[1][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[1][@"carsea"]];
            //将相应的信息显示出来
            //3
            self.thirdCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[2][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[2][@"carnum"]];
            self.thirdCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[2][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[2][@"carsea"]];
            //4
            self.fourthCartNumber.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[3][@"carnum"] isEmpty]?@"042":self.selectedCartInfo.Rows[3][@"carnum"]];
            self.fourthCartSeats.text = [NSString stringWithFormat:@"%@",[self.selectedCartInfo.Rows[3][@"carsea"] isEmpty]?@"4":self.selectedCartInfo.Rows[3][@"carsea"]];
            
            break;
            
        default:
            break;
    }
    //关闭显示进度条
    [self.stateIndicator stopAnimating];
    self.stateIndicator.hidden = YES;
    
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errStr message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
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
