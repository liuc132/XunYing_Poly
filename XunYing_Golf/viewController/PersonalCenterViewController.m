//
//  PersonalCenterViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/30.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "XunYingPre.h"
#import "UIColor+UICon.h"
#import "LogInViewController.h"
#import "HttpTools.h"
#import "DataTable.h"
#import "DBCon.h"
#import "GetRequestIPAddress.h"
#import "HeartBeatAndDetectState.h"


@interface PersonalCenterViewController ()<UIAlertViewDelegate>

@property (strong, nonatomic) DBCon *_dbCon;
@property (strong, nonatomic) DataTable *userInf;
@property (strong, nonatomic) DataTable *logCaddy;
@property (strong, nonatomic) NSMutableDictionary *logOutDicParam;
@property (strong, nonatomic) UIActivityIndicatorView   *stateIndicator;

- (IBAction)logOutHandle:(UIBarButtonItem *)sender;

@end

@implementation PersonalCenterViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    //
    NSLog(@"enter personalCenter");
    
    self.tableView.tableHeaderView.backgroundColor = [UIColor HexString:@"eeeeee"];
    //alloc and init dbCon and Userinf
    self._dbCon = [[DBCon alloc] init];
    self.userInf = [[DataTable alloc] init];
    self.logCaddy = [[DataTable alloc] init];
    //查询登录人参数
    self.userInf = [self._dbCon ExecDataTable:@"select *from tbl_logPerson"];
    self.logCaddy = [self._dbCon ExecDataTable:@"select *from tbl_NamePassword"];
    /*
     self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 100, ScreenHeight/2 - 100, 200, 200)];
     self.activityIndicatorView.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.2];
     self.activityIndicatorView.layer.cornerRadius = 20;
     
     [self.view addSubview:self.activityIndicatorView];
     
     self.activityIndicatorView.hidden = YES;
     */
    self.stateIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 100, ScreenHeight/2 - 100, 200, 200)];
    self.stateIndicator.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.2];
    self.stateIndicator.layer.cornerRadius = 20;
    [self.view addSubview:self.stateIndicator];
    self.stateIndicator.hidden = YES;
    //
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ForceBackField:) name:@"forceBackField" object:nil];
    
}

//- (void)ForceBackField:(NSNotification *)sender
//{
//    __weak typeof(self) weakSelf = self;
//    if ([sender.userInfo[@"forceBack"] isEqualToString:@"1"]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        //
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *serverForceBackAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的小组已回场" delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//            [serverForceBackAlert show];
//            
//            [weakSelf performSegueWithIdentifier:@"serVerBackField" sender:nil];
//        });
//        
//        
//    }
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.stateIndicator stopAnimating];
    self.stateIndicator.hidden = YES;
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma -mark numberOfSectionsInTableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma -mark numberOfRowsInSection
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

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
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"编号";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.userInf.Rows[0][@"number"]];//@"095";
            
            
            
            break;
        case 1:
            cell.textLabel.text = @"姓名";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.userInf.Rows[0][@"name"]];//@"高超";
            
            break;
        case 2:
            cell.textLabel.text = @"性别";
            cell.detailTextLabel.text = self.userInf.Rows[0][@"sex"]?@"男":@"女";
            
            break;
        case 3:
            cell.textLabel.text = @"岗位";
            cell.detailTextLabel.text = [self.userInf.Rows[0][@"job"] isEqualToString:@"4"]?@"球童":@"巡场";
            
            
            break;
        case 4:
            cell.textLabel.text = @"当前平板";
            cell.detailTextLabel.text = theMid;
            
            break;
        case 5:
            cell.textLabel.text = @"心跳间隔时间";
            cell.detailTextLabel.text = @"10秒";
            
            break;
        default:
            break;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

#pragma --mark viewDidLayoutSubviews
-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonaCenter" forIndexPath:indexPath];
    
    // Configure the cell...
    
    
    return cell;
}

- (void)willLogOutHandle
{
    __weak typeof(self) weakSelf = self;
    //[[NSMutableDictionary alloc] initWithObjectsAndKeys:TESTMIDCODE,@"mid",self.account.text,@"username",self.password.text,@"pwd",@"0",@"panmull",@"0",@"forceLogin", nil]
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //
    self.logOutDicParam = [[NSMutableDictionary alloc]initWithObjectsAndKeys:theMid,@"mid",self.logCaddy.Rows[0][@"user"],@"username",self.logCaddy.Rows[0][@"password"],@"pwd",@"0",@"panmull", nil];
    //
    NSString *logoutURLStr;
    logoutURLStr = [GetRequestIPAddress getLogOutURL];
    //
    [self.stateIndicator startAnimating];
    self.stateIndicator.hidden = NO;
    //删除本地的登录人信息以及组信息
    [self._dbCon ExecNonQuery:@"delete from tbl_logPerson"];
    [self._dbCon ExecNonQuery:@"delete from tbl_groupInf"];
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"disableHeart", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HeartBeat" object:nil userInfo:dic];
    //执行跳转
    [weakSelf performSegueWithIdentifier:@"backToLogInterface" sender:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //request
        [HttpTools getHttp:logoutURLStr forParams:self.logOutDicParam success:^(NSData *nsData){
            NSLog(@"request success");
//            NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *recDic;
            recDic = (NSDictionary *)nsData;
            
            NSLog(@"code:%@ msg:%@",recDic[@"Code"],recDic[@"Msg"]);
            if ([recDic[@"Code"] integerValue] > 0) {
                //删除本地的登录人信息以及组信息
                
            }
            
        }failure:^(NSError *err){
            NSLog(@"request failled");
            UIAlertView *errAlert = [[UIAlertView alloc] initWithTitle:@"退出登录失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [errAlert show];
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
                [self willLogOutHandle];
                break;
            default:
                break;
        }
    }
}

- (IBAction)logOutHandle:(UIBarButtonItem *)sender {
    NSLog(@"enter logOutHandle");
    UIAlertView *logOutAlert = [[UIAlertView alloc] initWithTitle:@"您确定退出登录吗?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
    logOutAlert.tag = 1;
    [logOutAlert show];
}
@end
