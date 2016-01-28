//
//  WaitToPlayTableViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/21.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "WaitToPlayTableViewController.h"
//#import "CreateGroupViewController.h"
#import "UIColor+UICon.h"
#import "NSString+FontAwesome.h"
#include "MainViewController.h"
#import "XunYingPre.h"
#import "DBCon.h"
#import "DataTable.h"
#import "HttpTools.h"
#import "LogInViewController.h"
#import "AppDelegate.h"
#import "HeartBeatAndDetectState.h"
#import "GetRequestIPAddress.h"

//extern unsigned char ucCusCounts;
//extern unsigned char ucHolePosition;
//extern BOOL          allowDownCourt;



@interface WaitToPlayTableViewController ()<UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *customerCount;
@property (strong, nonatomic) NSMutableArray *caddyCount;
@property (strong, nonatomic) NSMutableArray *carCount;
@property (strong, nonatomic) UILabel *cusName;
@property (strong, nonatomic) UILabel *cusNumber;
@property (strong, nonatomic) UILabel *cusSex;
@property (strong, nonatomic) UILabel *cusLevel;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) DBCon *localDBcon;
@property (strong, nonatomic) DataTable *cusCardNumTable;
@property (strong, nonatomic) DataTable *caddyTable;
@property (strong, nonatomic) DataTable *groupTable;
@property (strong, nonatomic) DataTable *addedCaddiesTable;
@property (strong, nonatomic) DataTable *addedCartsTable;
@property (strong, nonatomic) DataTable *allcusTable;

@property (nonatomic) NSInteger cusCounts;  //选取的客户个数
@property (nonatomic) NSInteger holeName;   //选取的球洞类型
//
@property (strong, nonatomic) NSArray   *cusCardNumArray;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;


@property (strong, nonatomic) IBOutlet UITableView *waitInformationTable;

@property (strong, nonatomic) IBOutlet UILabel *firstCaddyLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondCaddyLabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdCaddyLabel;
@property (strong, nonatomic) IBOutlet UILabel *fourthCaddyLabel;
@property (strong, nonatomic) IBOutlet UIView *subCaddyView;

@property (strong, nonatomic) IBOutlet UILabel *firstCartLabel;
@property (strong, nonatomic) IBOutlet UILabel *seconCartLabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdCartLabel;
@property (strong, nonatomic) IBOutlet UILabel *fourthCartLabel;
@property (strong, nonatomic) IBOutlet UIView *subCartView;






- (IBAction)cancleDownGround:(UIBarButtonItem *)sender;
- (IBAction)backToCreateInf:(UIBarButtonItem *)sender;


@end

@implementation WaitToPlayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.waitInformationTable.dataSource = self;
    self.waitInformationTable.delegate   = self;
    
    //init and alloc dbcon and datatable
    self.localDBcon = [[DBCon alloc] init];
    self.cusCardNumTable  = [[DataTable alloc] init];
    self.caddyTable = [[DataTable alloc] init];
    self.groupTable = [[DataTable alloc] init];
    self.addedCaddiesTable = [[DataTable alloc] init];
    self.addedCartsTable = [[DataTable alloc] init];
    self.allcusTable     = [[DataTable alloc] init];
    //查询球童信息
    self.caddyTable = [self.localDBcon ExecDataTable:@"select *from tbl_logPerson"];
    self.addedCaddiesTable = [self.localDBcon ExecDataTable:@"select *from tbl_addCaddy"];
    self.addedCartsTable = [self.localDBcon ExecDataTable:@"select *from tbl_selectCart"];
    //
    if (self.QRCodeEnable) {
        self.cusCardNumArray = self.cusCardArray;
    }
    else
    {
        self.cusCardNumTable = [self.localDBcon ExecDataTable:@"select *from tbl_CustomerNumbers"];
        //
        self.cusCardNumArray = [[NSArray alloc] initWithObjects:self.cusCardNumTable.Rows[0][@"first"],self.cusCardNumTable.Rows[0][@"second"],self.cusCardNumTable.Rows[0][@"third"],self.cusCardNumTable.Rows[0][@"fourth"], nil];
    }
    self.groupTable = [self.localDBcon ExecDataTable:@"select *from tbl_groupInf"];
    self.allcusTable = [self.localDBcon ExecDataTable:@"select *from tbl_CustomersInfo"];
    //
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2-100, ScreenHeight/2 - 130, 200, 200)];
    [self.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.3];
    //self.activityIndicatorView.alpha = 0.2;
    self.activityIndicatorView.hidden = YES;
    self.activityIndicatorView.layer.cornerRadius = 20.0f;
    //from heart beat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectTheThing:) name:@"readyDown" object:nil];
    //from QRCodeReaderView
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(QRCodeResult:) name:@"QRCodeResult" object:nil];
    //
    NSLog(@"count:%ld",[self.allcusTable.Rows count]);
//    if ([self.allcusTable.Rows count]) {
//        self.customerCounts = [self.allcusTable.Rows count];
//    }
    
}

#pragma -mark detectTheThing
-(void)detectTheThing:(NSNotification *)sender
{
    NSLog(@"enter detectTheThing");
    //通过通知来接收信息，并进行相应的跳转
    if ([sender.userInfo[@"readyDown"] isEqualToString:@"1"]) {
        //移除通知
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //实现页面跳转
        [self performSegueWithIdentifier:@"toMainControlInterface" sender:nil];
    }
    
}

#pragma -mark navBack
-(void)navBack
{
    //NSLog(@"enter navBack");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    NSInteger eachSectionRow;
    eachSectionRow = 0;
    switch (section) {
        case 2:
            //eachSectionRow = self.QRCodeEnable?[self.cusCardNumArray count]:self.customerCounts + 1;
            eachSectionRow = self.QRCodeEnable?[self.cusCardNumArray count]:[self.allcusTable.Rows count]?[self.allcusTable.Rows count]:1;
            break;
        
        case 0:
        case 1:
        case 3:
        case 4:
        case 5:
            eachSectionRow = 1;
            break;
        default:
            break;
    }
    
    return eachSectionRow;
}
#pragma -mark tableView:willDisplayCell:forRowAtIndexPath
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setTableFooterView:[[UIView alloc]init]];
    //
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    //
    UILabel *grpNum = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 60, 21)];
    UILabel *createTime = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 60, 21)];
    //
    if ([self.groupTable.Rows count]) {
        grpNum.text = self.groupTable.Rows[0][@"gronum"];
        NSString *createTimeStr;
        createTimeStr = self.groupTable.Rows[0][@"createdate"];
        createTimeStr = [createTimeStr substringWithRange:NSMakeRange(11, 5)];
        createTime.text = createTimeStr;
    }
    
    //
    if(indexPath.section == 0)
    {
        [cell addSubview:grpNum];
    }
    //
    if(indexPath.section == 1)
    {
        [cell addSubview:createTime];
    }
    //
    if(indexPath.section == 2)
    {
        self.cusName = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 45, 21)];
        //NSLog(@"index.row:%ld",indexPath.row);
        //后期如果有客户名称则替换成客户登记的实际名称
        self.cusName.text = [NSString stringWithFormat:@"客户%ld",(long)indexPath.row];
        self.cusNumber = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 42, 21)];
        //实际的消费卡号
        NSString *cusNum = [[NSString alloc] init];
        switch (indexPath.row) {
            case 0:
                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumArray[0]];
                break;
            case 1:
                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumArray[1]];
                break;
            case 2:
                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumArray[2]];
                break;
            case 3:
                cusNum = [NSString stringWithFormat:@"%@",self.cusCardNumArray[3]];
                break;
                
            default:
                break;
        }
        
        self.cusNumber.text = cusNum;
        self.cusSex = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 120, 10, 42, 21)];
        //实际的客户性别
        self.cusSex.text = @"男";
        self.cusLevel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 48, 10, 42, 21)];
        //是否是会员
        self.cusLevel.text = @"会员";
    }
    
    //
    UILabel *holeName = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 60, 21)];
    if (self.holeType == nil) {
        holeName.text = @"十八洞";
    }
    else
        holeName.text = self.holeType;//holeNameString;
    
    if (indexPath.section == 2) {
        switch (indexPath.row) {
                //第一个客户信息显示
            case 0:
                [cell addSubview:self.cusName];
                [cell addSubview:self.cusNumber];
                [cell addSubview:self.cusSex];
                [cell addSubview:self.cusLevel];
                break;
                //第二个客户信息显示
            case 1:
                [cell addSubview:self.cusName];
                [cell addSubview:self.cusNumber];
                [cell addSubview:self.cusSex];
                [cell addSubview:self.cusLevel];
                break;
                //第三个客户信息显示
            case 2:
                [cell addSubview:self.cusName];
                [cell addSubview:self.cusNumber];
                [cell addSubview:self.cusSex];
                [cell addSubview:self.cusLevel];
                break;
                //第四个客户信息显示
            case 3:
                [cell addSubview:self.cusName];
                [cell addSubview:self.cusNumber];
                [cell addSubview:self.cusSex];
                [cell addSubview:self.cusLevel];
                break;
                
            default:
                break;
        }
    }
    //球洞信息
    else if (indexPath.section == 3)
    {
        [cell addSubview:holeName];
    }
    //球童信息
    else if (indexPath.section == 4) {
        //将所有的球车视图隐藏，并在下边相应开启
        self.firstCaddyLabel.hidden = YES;
        self.secondCaddyLabel.hidden = YES;
        self.thirdCaddyLabel.hidden = YES;
        self.fourthCaddyLabel.hidden = YES;
        //tbl_addCaddy(cadcod text,cadnam text,cadnum text,cadsex text,empcod text)
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *firstCaddyStr;
            NSString *secondCaddyStr;
            NSString *thirdCaddyStr;
            NSString *fourthCaddyStr;
            if ([self.addedCaddiesTable.Rows count] == 1) {
                firstCaddyStr = [NSString stringWithFormat:@"%@ %@",self.addedCaddiesTable.Rows[0][@"cadnum"],self.addedCaddiesTable.Rows[0][@"cadnam"]];
            }
            else if ([self.addedCaddiesTable.Rows count] == 2) {
                firstCaddyStr = [NSString stringWithFormat:@"%@ %@",self.addedCaddiesTable.Rows[0][@"cadnum"],self.addedCaddiesTable.Rows[0][@"cadnam"]];
                secondCaddyStr = [NSString stringWithFormat:@"%@ %@",self.addedCaddiesTable.Rows[1][@"cadnum"],self.addedCaddiesTable.Rows[1][@"cadnam"]];
            }
            else if ([self.addedCaddiesTable.Rows count] == 3) {
                firstCaddyStr = [NSString stringWithFormat:@"%@ %@",self.addedCaddiesTable.Rows[0][@"cadnum"],self.addedCaddiesTable.Rows[0][@"cadnam"]];
                secondCaddyStr = [NSString stringWithFormat:@"%@ %@",self.addedCaddiesTable.Rows[1][@"cadnum"],self.addedCaddiesTable.Rows[1][@"cadnam"]];
                thirdCaddyStr = [NSString stringWithFormat:@"%@ %@",self.addedCaddiesTable.Rows[2][@"cadnum"],self.addedCaddiesTable.Rows[2][@"cadnam"]];
            }
            else if ([self.addedCaddiesTable.Rows count] == 4) {
                firstCaddyStr = [NSString stringWithFormat:@"%@ %@",self.addedCaddiesTable.Rows[0][@"cadnum"],self.addedCaddiesTable.Rows[0][@"cadnam"]];
                secondCaddyStr = [NSString stringWithFormat:@"%@ %@",self.addedCaddiesTable.Rows[1][@"cadnum"],self.addedCaddiesTable.Rows[1][@"cadnam"]];
                thirdCaddyStr = [NSString stringWithFormat:@"%@ %@",self.addedCaddiesTable.Rows[2][@"cadnum"],self.addedCaddiesTable.Rows[2][@"cadnam"]];
                fourthCaddyStr = [NSString stringWithFormat:@"%@ %@",self.addedCaddiesTable.Rows[3][@"cadnum"],self.addedCaddiesTable.Rows[3][@"cadnam"]];
            }
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                switch ([self.addedCaddiesTable.Rows count]) {
                    case 4:
                        self.fourthCaddyLabel.text = fourthCaddyStr;
                        self.fourthCaddyLabel.hidden = NO;
                    case 3:
                        self.thirdCaddyLabel.text = thirdCaddyStr;
                        self.thirdCaddyLabel.hidden = NO;
                    case 2:
                        self.secondCaddyLabel.text = secondCaddyStr;
                        self.secondCaddyLabel.hidden = NO;
                    case 1:
                        self.firstCaddyLabel.text = firstCaddyStr;
                        self.firstCaddyLabel.hidden = NO;
                        break;
                        
                    default:
                        break;
                }
                //添加球童视图
                [cell addSubview:self.subCaddyView];
            });
        });
        
    }
    //球车
    else if (indexPath.section == 5)
    {
        //将所有的球车视图隐藏，并在下边相应开启
        self.firstCartLabel.hidden = YES;
        self.seconCartLabel.hidden = YES;
        self.thirdCartLabel.hidden = YES;
        self.fourthCartLabel.hidden = YES;
        //tbl_selectCart(carcod text,carnum text,carsea text)
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *firstCartStr;
            NSString *secondCartStr;
            NSString *thirdCartStr;
            NSString *fourthCartStr;
            if ([self.addedCartsTable.Rows count] == 1) {
                firstCartStr = [NSString stringWithFormat:@"%@  %@座",self.addedCartsTable.Rows[0][@"carnum"],self.addedCartsTable.Rows[0][@"carsea"]];
            }
            else if ([self.addedCartsTable.Rows count] == 2) {
                firstCartStr = [NSString stringWithFormat:@"%@  %@座",self.addedCartsTable.Rows[0][@"carnum"],self.addedCartsTable.Rows[0][@"carsea"]];
                secondCartStr = [NSString stringWithFormat:@"%@  %@座",self.addedCartsTable.Rows[1][@"carnum"],self.addedCartsTable.Rows[1][@"carsea"]];
            }
            else if ([self.addedCartsTable.Rows count] == 3) {
                firstCartStr = [NSString stringWithFormat:@"%@  %@座",self.addedCartsTable.Rows[0][@"carnum"],self.addedCartsTable.Rows[0][@"carsea"]];
                secondCartStr = [NSString stringWithFormat:@"%@  %@座",self.addedCartsTable.Rows[1][@"carnum"],self.addedCartsTable.Rows[1][@"carsea"]];
                thirdCartStr = [NSString stringWithFormat:@"%@  %@座",self.addedCartsTable.Rows[2][@"carnum"],self.addedCartsTable.Rows[2][@"carsea"]];
            }
            else if ([self.addedCartsTable.Rows count] == 4) {
                firstCartStr = [NSString stringWithFormat:@"%@  %@座",self.addedCartsTable.Rows[0][@"carnum"],self.addedCartsTable.Rows[0][@"carsea"]];
                secondCartStr = [NSString stringWithFormat:@"%@  %@座",self.addedCartsTable.Rows[1][@"carnum"],self.addedCartsTable.Rows[1][@"carsea"]];
                thirdCartStr = [NSString stringWithFormat:@"%@  %@座",self.addedCartsTable.Rows[2][@"carnum"],self.addedCartsTable.Rows[2][@"carsea"]];
                fourthCartStr = [NSString stringWithFormat:@"%@  %@座",self.addedCartsTable.Rows[3][@"carnum"],self.addedCartsTable.Rows[3][@"carsea"]];
            }
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                switch ([self.addedCartsTable.Rows count]) {
                    case 4:
                        self.fourthCartLabel.text = fourthCartStr;
                        self.fourthCartLabel.hidden = NO;
                    case 3:
                        self.thirdCartLabel.text = thirdCartStr;
                        self.thirdCartLabel.hidden = NO;
                    case 2:
                        self.seconCartLabel.text = secondCartStr;
                        self.seconCartLabel.hidden = NO;
                    case 1:
                        self.firstCartLabel.text = firstCartStr;
                        self.firstCartLabel.hidden = NO;
                        break;
                        
                    default:
                        break;
                }
                
                
                //添加球车视图
                [cell addSubview:self.subCartView];
            });
        });
        
    }
    
    [self.activityIndicatorView startAnimating];
    self.activityIndicatorView.hidden = NO;
}

#pragma --mark heightForHeaderInSection
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}
#pragma -mark  titleForHeaderInSection
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = [[NSString alloc]init];
    switch (section) {
        case 0:
            headerTitle = @"  小组编号";
            break;
            
        case 1:
            headerTitle = @"  创建时间";
            break;
            
        case 2:
            headerTitle = @"  客户";
            break;
            
        case 3:
            headerTitle = @"  球洞";
            break;
            
        case 4:
            headerTitle = @"  球童";
            break;
            
        case 5:
            headerTitle = @"  球车";
            break;
        default:
            break;
    }
    
    return headerTitle;
}
#pragma -mark viewDidDisappear
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

#pragma --mark viewDidLayoutSubviews
-(void)viewDidLayoutSubviews
{
    if ([self.waitInformationTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.waitInformationTable setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.waitInformationTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.waitInformationTable setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [self.waitInformationTable dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // Configure the cell...
    [self.view bringSubviewToFront:self.activityIndicatorView];
    return cell;
}
#pragma -mark
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"currentIndexPath.row:%ld;and section:%ld",(long)indexPath.row,(long)indexPath.section);
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        switch (buttonIndex) {
            case 0:
                
                break;
                
            case 1:
                [self canCleDownHandle];
                break;
                
            default:
                break;
        }
    }
}

- (void)canCleDownHandle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"组参数异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    if(![self.groupTable.Rows count])
    {
        [alert show];
        return;
    }
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //
    NSMutableDictionary *cancleWaiting = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",self.groupTable.Rows[0][@"grocod"],@"grocod", nil];
    //
    NSString *cancelWait;
    cancelWait = [GetRequestIPAddress getCancleWaitingGroupURL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //向服务器发送取消下场申请
        [HttpTools getHttp:cancelWait forParams:cancleWaiting success:^(NSData *nsData){
            //        NSLog(@"cancle Waiting down group success");
            [self.timer invalidate];
            //
//            NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *recDic;
            recDic = (NSDictionary *)nsData;
            
#ifdef DEBUG_MODE
            NSLog(@"recDic:%@ and Msg:%@ Code:%@",recDic,recDic[@"Msg"],recDic[@"Code"]);
#endif
            if ([recDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-4]]) {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",recDic[@"Msg"]];
                UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [hasGrpFailAlert show];
                NSLog(@"delete wait group fail");
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HeartBeat" object:nil userInfo:@{@"disableHeart":@"1"}];
                //
                [self performSegueWithIdentifier:@"waitDownToCreateGrp" sender:nil];
            }
            
        }failure:^(NSError *err){
            NSLog(@"cancle waiting down group fail");
            
        }];
    });

}

- (IBAction)cancleDownGround:(UIBarButtonItem *)sender {
    UIAlertView *cancelDownAlert = [[UIAlertView alloc] initWithTitle:@"你确定要取消该客户组吗?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    cancelDownAlert.tag = 1;
    [cancelDownAlert show];
    
}

- (IBAction)backToCreateInf:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HeartBeat" object:nil userInfo:@{@"disableHeart":@"1"}];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"waitDownToLogIn" sender:nil];
    });
}
@end
