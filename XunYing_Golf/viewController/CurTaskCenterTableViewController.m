//
//  CurTaskCenterTableViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/30.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "CurTaskCenterTableViewController.h"
#import "XunYingPre.h"
#import "KxMenu.h"
#import "HttpTools.h"
#import "TaskCenterTableViewCell.h"
#import "DBCon.h"
#import "DataTable.h"
#import "UIColor+UICon.h"
#import "TaskDetailViewController.h"


//定义所有事务的背景颜色
#define MendHoleColor       @"f686c1"
#define LeaveRestColor      @"7e96fa"
#define JumpHoleColor       @"61c1fb"
#define ChangeCartColor     @"5ccd73"
#define ChangeCaddyColor    @"fe9263"

@interface CurTaskCenterTableViewController ()<UIGestureRecognizerDelegate>


@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSArray        *displayArray;
//
@property (strong, nonatomic) DBCon          *lcDbCon;
@property (strong, nonatomic) DataTable      *allTaskInfo;
@property (strong, nonatomic) DataTable      *requestPerson;
@property (nonatomic)   BOOL                 goToDetailView;
@property (nonatomic)           NSInteger    whichRowData;


@property (strong, nonatomic) IBOutlet UIView *displayNoTask;

- (IBAction)selectTask:(UIBarButtonItem *)sender;


@end

@implementation CurTaskCenterTableViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    //
    self.lcDbCon = [[DBCon alloc] init];
    self.allTaskInfo = [[DataTable alloc] init];
    self.requestPerson = [[DataTable alloc] init];
    //
    self.goToDetailView = NO;
    
    //初始化一个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTaskResult:) name:@"displayTaskResult" object:nil];
    //查询数据库
    self.requestPerson = [self.lcDbCon ExecDataTable:@"select *from tbl_logPerson"];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma -mark
- (void)getTaskResult:(NSNotification *)sender
{
    if ([sender.name isEqualToString:@"displayTaskResult"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.allTaskInfo = [self.lcDbCon ExecDataTable:@"select *from tbl_taskInfo"];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.displayArray = self.allTaskInfo.Rows;
                //根据所获得的数据来组装参数
                [self.tableView reloadData];
            });
            
        });
    }
}


#pragma -mark displayNoTaskView
-(void)displayNoTaskView
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.navigationController.navigationBar.frame.size.height
    self.displayNoTask.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [self.view addSubview:self.displayNoTask];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.displayArray count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row:%ld and thedata:%@",indexPath.row,self.displayArray[[self.displayArray count] - indexPath.row - 1]);
    self.whichRowData   = [self.displayArray count] - indexPath.row - 1;
    self.goToDetailView = YES;
    [self performSegueWithIdentifier:@"listToTaskDetail" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TaskDetailViewController *taskDetailVC = segue.destinationViewController;
    if (self.goToDetailView) {
        NSDictionary *curRowDic = self.displayArray[self.whichRowData];
        taskDetailVC.taskStatus = ([curRowDic[@"result"] intValue] == 0)?@"待处理":([curRowDic[@"result"] intValue] == 1)?@"同意":([curRowDic[@"result"] intValue] == 2)?@"不同意":@"";
        taskDetailVC.taskRequestPerson = [NSString stringWithFormat:@"%@ %@",self.requestPerson.Rows[0][@"number"],self.requestPerson.Rows[0][@"name"]];
        NSString *reqTime = curRowDic[@"subtim"];
        taskDetailVC.taskRequstTime = [reqTime substringFromIndex:11];
        NSString *taskNameType = [[NSString alloc] init];
        switch ([curRowDic[@"evetyp"] intValue]) {
            case 1:
                taskNameType = @"待更换球车";
                //查询数据库
                taskDetailVC.taskDetailName = curRowDic[@""];
                break;
            case 2:
                taskNameType = @"待更换球童";
                break;
            case 3:
                taskNameType = @"跳过球洞";
                break;
            case 4:
                taskNameType = @"待补打球洞";
                break;
            case 5:
                taskNameType = @"";
                break;
            case 6:
                taskNameType = @"申请的恢复时间";
                break;
            default:
                break;
        }
        //事务类型
        taskDetailVC.taskDetailName = taskNameType;
        taskDetailVC.whichInterfaceFrom = 2;
        taskDetailVC.selectRowNum       = self.whichRowData;
    }
}

- (TaskCenterTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"listAllTask";
    TaskCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TaskCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // Configure the cell...
    cell.backgroundColor = [UIColor clearColor];
    //根据事务类型来进行相应的视图的切换
    //tbl_taskInfo(evecod text,evetyp text,evesta text,subtim text,result text,everea text,hantim text,oldCaddyCode text,newCaddyCode text,oldCartCode text,newCartCode text,jumpHoleCode text,toHoleCode text,reqBackTime text,reHoleCode text,mendHoleCode text,ratifyHoleCode text,ratifyinTime text,selectedHoleCode text)
    NSDictionary *eachTask = self.displayArray[[self.displayArray count] - indexPath.row - 1];
    
    //
    switch ([eachTask[@"evetyp"] intValue]) {
        case 1://换球车
            
            cell.taskTypeImageDis.image = [UIImage imageNamed:@"groupCar.png"];
            
            cell.taskStatusDis.text     = ([eachTask[@"result"] intValue] == 0)?@"待处理":([eachTask[@"result"] intValue] == 1)?@"同意":([eachTask[@"result"] intValue] == 2)?@"不同意":@"";
            
            cell.taskTypeNameDis.text = @"换球车";
            
            cell.taskColorView.backgroundColor = [UIColor HexString:ChangeCartColor];
            
            break;
        case 2://换球童
            
            cell.taskTypeImageDis.image = [UIImage imageNamed:@"groupCaddy.png"];
            
            cell.taskStatusDis.text     = ([eachTask[@"result"] intValue] == 0)?@"待处理":([eachTask[@"result"] intValue] == 1)?@"同意":([eachTask[@"result"] intValue] == 2)?@"不同意":@"";
            
            cell.taskTypeNameDis.text = @"换球童";
            
            cell.taskColorView.backgroundColor = [UIColor HexString:ChangeCaddyColor];
            
            break;
        case 3://跳洞
            
            cell.taskTypeImageDis.image = [UIImage imageNamed:@"jumpHoleWhite.png"];
            
            cell.taskStatusDis.text     = ([eachTask[@"result"] intValue] == 0)?@"待处理":([eachTask[@"result"] intValue] == 1)?@"同意":([eachTask[@"result"] intValue] == 2)?@"不同意":@"";
            
            cell.taskTypeNameDis.text = @"跳洞";
            
            cell.taskColorView.backgroundColor = [UIColor HexString:JumpHoleColor];
            
//            cell.taskReqTimeDis.text    = [NSString stringWithFormat:@"%@",eachTask[@"subtim"]];
            
            break;
        case 4://补洞
            
            cell.taskTypeImageDis.image = [UIImage imageNamed:@"mendHoleList.png"];
            
            cell.taskStatusDis.text     = ([eachTask[@"result"] intValue] == 0)?@"待处理":([eachTask[@"result"] intValue] == 1)?@"同意":([eachTask[@"result"] intValue] == 2)?@"不同意":@"";
            
            cell.taskTypeNameDis.text = @"补洞";
            
            cell.taskColorView.backgroundColor = [UIColor HexString:MendHoleColor];
            
//            cell.taskReqTimeDis.text    = [NSString stringWithFormat:@"%@",eachTask[@"subtim"]];
            
            break;
        case 5://点餐
            
            break;
        case 6://离场休息
            
            cell.taskTypeImageDis.image = [UIImage imageNamed:@"leaveToRestWhite.png"];
            
            cell.taskStatusDis.text     = ([eachTask[@"result"] intValue] == 0)?@"待处理":([eachTask[@"result"] intValue] == 1)?@"同意":([eachTask[@"result"] intValue] == 2)?@"不同意":@"";
            
            cell.taskTypeNameDis.text = @"离场休息";
            
            cell.taskColorView.backgroundColor = [UIColor HexString:LeaveRestColor];
            
//            cell.taskReqTimeDis.text    = [NSString stringWithFormat:@"%@",eachTask[@"subtim"]];
            
            break;
        
        default:
            break;
    }
    //
    cell.taskReqTimeDis.text    = [NSString stringWithFormat:@"%@",[eachTask[@"subtim"] substringWithRange:NSMakeRange(11, 5)]];
    
    return cell;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"curTime:%@",self.leaveTime);
    //[self.displayNoTask removeFromSuperview];//该语句可以实现将该uiview给移除掉
    //
    [self.view setNeedsLayout];
    //
    self.allTaskInfo = [self.lcDbCon ExecDataTable:@"select *from tbl_taskInfo"];
    //
    if (![self.allTaskInfo.Rows count]) {
        [self displayNoTaskView];
    }
    else
    {
        self.displayArray = self.allTaskInfo.Rows;
        [self.tableView reloadData];
    }
    
    
}


- (IBAction)selectTask:(UIBarButtonItem *)sender {
    //construct Array
    NSArray *menuItems =
    @[[KxMenuItem menuItem:@"换球童" image:[UIImage imageNamed:@"changeCaddy.png"] target:self action:@selector(changeCaddy)],
      [KxMenuItem menuItem:@"换球车" image:[UIImage imageNamed:@"changeCart.png"] target:self action:@selector(changeCart)],
      [KxMenuItem menuItem:@"跳洞" image:[UIImage imageNamed:@"jumpHole.png"] target:self action:@selector(JumpToHoles)],
      [KxMenuItem menuItem:@"补洞" image:[UIImage imageNamed:@"mendHole.png"] target:self action:@selector(MendHoles)],
      [KxMenuItem menuItem:@"离场休息" image:[UIImage imageNamed:@"leaveToRest.png"] target:self action:@selector(leaveToRest)]];
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(ScreenWidth-47, self.navigationController.navigationBar.frame.size.height, 30, 30)
                 menuItems:menuItems];
    
    
}

//将没有内容的地方的分割线去除掉
#pragma -mark tableView:willDisplayCell:forRowAtIndexPath
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setTableFooterView:[[UIView alloc]init]];
    //
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
//将分割线铺满整个窗口
- (void)viewWillLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

#pragma -mark JumpHoles
-(void)JumpToHoles
{
    NSLog(@"跳洞");
    //执行页面跳转代码
    [self performSegueWithIdentifier:@"ToJumpHole" sender:nil];
}

#pragma -mark MendHoles
-(void)MendHoles
{
    NSLog(@"补洞");
    
    //执行跳转程序
    [self performSegueWithIdentifier:@"toMendHole" sender:nil];
}
#pragma -mark changeCaddy
-(void)changeCaddy
{
    NSLog(@"change Caddy");
    //执行跳转程序
    [self performSegueWithIdentifier:@"toChangeCaddy" sender:nil];
}
#pragma -mark changeCart
-(void)changeCart
{
    NSLog(@"change Cart");
    [self performSegueWithIdentifier:@"toChangeCart" sender:nil];
}
#pragma -mark leaveToRest
-(void)leaveToRest
{
    NSLog(@"leave to rest");
    [self performSegueWithIdentifier:@"toLeaveToRest" sender:nil];                                                                                                                                                                                                                                                                                                   
}


@end
