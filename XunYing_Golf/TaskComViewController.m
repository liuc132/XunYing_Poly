//
//  TaskComViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/11.
//  Copyright (c) 2015年 LiuC. All rights reserved.
//

#import "TaskComViewController.h"
#import "DBCon.h"
#import "DataTable.h"
#import "HttpTools.h"
#import "CellFrameModel.h"
#import "Friend.h"
#import "FriendGroup.h"
#import "HeadView.h"

//职员在系统中的状态
typedef enum empStatus{
    empOffline,
    empOnline
}empStatus;
//职位类别
typedef enum jobType{
    allJob,         //全部岗位
    manager,        //管理员
    dispatch,       //调度
    tourField,      //巡场
    caddy,          //球童
    reception,      //前台
    restaurant      //餐厅
}jobType;



@interface TaskComViewController ()<HeadViewDelegate>
{
    NSArray *_employeesData;
}


@property (strong, nonatomic) DBCon *comDbCon;
@property (strong, nonatomic) DataTable *empInfo;
//从数据库中读取数据，相应的数据组装在一个dictionary中
@property (strong, nonatomic) NSMutableArray *employeesArray;


//
@property (strong, nonatomic) IBOutlet UISegmentedControl *msgDisWay;

//
- (IBAction)msgDisWays:(UISegmentedControl *)sender;



@end




@implementation TaskComViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    //
    __weak typeof(self) weakSelf = self;
    //
    self.allEmpCommunicate.dataSource = self;
    self.allEmpCommunicate.delegate   = self;
    //初始化
    self.comDbCon = [[DBCon alloc] init];
    self.empInfo  = [[DataTable alloc] init];
    self.employeesArray = [[NSMutableArray alloc] init];
    //
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        weakSelf.empInfo = [weakSelf.comDbCon ExecDataTable:@"select *from tbl_EmployeeInf"];
#ifdef  DEBUG_MODE
        NSLog(@"empInfo:%@",weakSelf.empInfo.Rows);
#endif
        //这里还要分各个职位进行参数的添加 所有职位，管理员，调度，巡场，球童，前台，餐厅
        NSMutableArray *partInfoEmpAll          = [[NSMutableArray alloc] init];
        NSMutableArray *partInfoEmpManager      = [[NSMutableArray alloc] init];
        NSMutableArray *partInfoEmpDispatch     = [[NSMutableArray alloc] init];
        NSMutableArray *partInfoEmpTourField    = [[NSMutableArray alloc] init];
        NSMutableArray *partInfoEmpreception    = [[NSMutableArray alloc] init];
        NSMutableArray *partInfoEmprestaurant   = [[NSMutableArray alloc] init];
        
        if ([weakSelf.empInfo.Rows count]) {
            NSArray *allempsInfo = weakSelf.empInfo.Rows;
            static NSInteger onlineall,onlinemanager,onlinedispatch,onlinetourfield,onlinereception,onlinerestaurant;
            onlineall = 0;
            onlinemanager = 0;
            onlinedispatch = 0;
            onlinetourfield = 0;
            onlinereception = 0;
            onlinerestaurant = 0;
            for (NSDictionary *eachEmp in allempsInfo) {
                //
                NSString *iconStr;// = [[NSString alloc] init];
                NSDictionary *eachEmpPartInfo;// = [[NSDictionary alloc] init];
                
                switch ([eachEmp[@"empjob"] intValue]) {
                    case allJob:
                        //确定是否离线
                        iconStr = [NSString stringWithFormat:@"%@",([eachEmp[@"online"] boolValue]?@"online.png":@"offline.png")];
                        if ([eachEmp[@"online"] boolValue]) {
                            onlineall++;
                        }
                        //
                        eachEmpPartInfo = [[NSDictionary alloc] initWithObjectsAndKeys:iconStr,@"icon",eachEmp[@"empnum"],@"intro",eachEmp[@"empnam"],@"name",@"0",@"vip", nil];
                        [partInfoEmpAll addObject:eachEmpPartInfo];
                        
                        break;
                    case manager:
                        //确定是否离线
                        iconStr = [NSString stringWithFormat:@"%@",([eachEmp[@"online"] boolValue]?@"online.png":@"offline.png")];
                        if ([eachEmp[@"online"] boolValue]) {
                            onlinemanager++;
                        }
                        //
                        eachEmpPartInfo = [[NSDictionary alloc] initWithObjectsAndKeys:iconStr,@"icon",eachEmp[@"empnum"],@"intro",eachEmp[@"empnam"],@"name",@"0",@"vip", nil];
                        [partInfoEmpManager addObject:eachEmpPartInfo];
                        
                        break;
                    case dispatch:
                        //确定是否离线
                        iconStr = [NSString stringWithFormat:@"%@",([eachEmp[@"online"] boolValue]?@"online.png":@"offline.png")];
                        if ([eachEmp[@"online"] boolValue]) {
                            onlinedispatch++;
                        }
                        //
                        eachEmpPartInfo = [[NSDictionary alloc] initWithObjectsAndKeys:iconStr,@"icon",eachEmp[@"empnum"],@"intro",eachEmp[@"empnam"],@"name",@"0",@"vip", nil];
                        [partInfoEmpDispatch addObject:eachEmpPartInfo];
                        
                        break;
                    case tourField:
                        //确定是否离线
                        iconStr = [NSString stringWithFormat:@"%@",([eachEmp[@"online"] boolValue]?@"online.png":@"offline.png")];
                        if ([eachEmp[@"online"] boolValue]) {
                            onlinetourfield++;
                        }
                        //
                        eachEmpPartInfo = [[NSDictionary alloc] initWithObjectsAndKeys:iconStr,@"icon",eachEmp[@"empnum"],@"intro",eachEmp[@"empnam"],@"name",@"0",@"vip", nil];
                        [partInfoEmpTourField addObject:eachEmpPartInfo];
                        
                        break;
                    case reception:
                        //确定是否离线
                        iconStr = [NSString stringWithFormat:@"%@",([eachEmp[@"online"] boolValue]?@"online.png":@"offline.png")];
                        if ([eachEmp[@"online"] boolValue]) {
                            onlinereception++;
                        }
                        //
                        eachEmpPartInfo = [[NSDictionary alloc] initWithObjectsAndKeys:iconStr,@"icon",eachEmp[@"empnum"],@"intro",eachEmp[@"empnam"],@"name",@"0",@"vip", nil];
                        [partInfoEmpreception addObject:eachEmpPartInfo];
                        
                        break;
                    case restaurant:
                        //确定是否离线
                        iconStr = [NSString stringWithFormat:@"%@",([eachEmp[@"online"] boolValue]?@"online.png":@"offline.png")];
                        if ([eachEmp[@"online"] boolValue]) {
                            onlinerestaurant++;
                        }
                        //
                        eachEmpPartInfo = [[NSDictionary alloc] initWithObjectsAndKeys:iconStr,@"icon",eachEmp[@"empnum"],@"intro",eachEmp[@"empnam"],@"name",@"0",@"vip", nil];
                        [partInfoEmprestaurant addObject:eachEmpPartInfo];
                        
                        break;
                        
                    default:
                        break;
                }
            }
            //
            NSString *managerOnlineCount = [NSString stringWithFormat:@"%ld",(long)onlinemanager];
            NSString *dispatchOnlineCount = [NSString stringWithFormat:@"%ld",(long)onlinedispatch];
            NSString *tourfieldOnlineCount = [NSString stringWithFormat:@"%ld",(long)onlinetourfield];
            NSString *receptionOnlineCount = [NSString stringWithFormat:@"%ld",(long)onlinereception];
            NSString *restaurantOnlineCount = [NSString stringWithFormat:@"%ld",(long)onlinerestaurant];
            //将数据组装到数组中onlinemanager
            [self.employeesArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:partInfoEmpManager,@"friends",@"管理员",@"name",managerOnlineCount,@"online", nil]];
            //
            [self.employeesArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:partInfoEmpDispatch,@"friends",@"调度",@"name",dispatchOnlineCount,@"online", nil]];
            //
            [self.employeesArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:partInfoEmpTourField,@"friends",@"巡场",@"name",tourfieldOnlineCount,@"online", nil]];
            //
            [self.employeesArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:partInfoEmpreception,@"friends",@"前台",@"name",receptionOnlineCount,@"online", nil]];
            //
            [self.employeesArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:partInfoEmprestaurant,@"friends",@"餐厅",@"name",restaurantOnlineCount,@"online", nil]];
            //
#ifdef  DEBUG_MODE
            NSLog(@"all emps:%@",weakSelf.employeesArray);
#endif
        }
        
    });
    //load data
    [self loadData];
    
    [self.allEmpCommunicate reloadData];
    
    [self clickHeadView];
    
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

#pragma -mark loadData
- (void)loadData
{
    NSArray *tempArray = [[NSArray alloc] initWithArray:self.employeesArray];
    NSMutableArray *fgArray = [NSMutableArray array];
    for (NSDictionary *dict in tempArray) {
        FriendGroup *friendGroup = [FriendGroup friendGroupWithDict:dict];
        [fgArray addObject:friendGroup];
    }
    _employeesData = fgArray;
}

#pragma -mark numberOfRowsInSection
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FriendGroup *friendGroup = _employeesData[section];
    NSInteger count = friendGroup.isOpened ? friendGroup.friends.count : 0;
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _employeesData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    FriendGroup *friendGroup = _employeesData[indexPath.section];
    Friend *friend = friendGroup.friends[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:friend.icon];
    cell.textLabel.textColor = friend.isVip ? [UIColor redColor] : [UIColor blackColor];
    cell.textLabel.text = friend.name;
    cell.detailTextLabel.text = friend.intro;
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HeadView *headView = [HeadView headViewWithTableView:tableView];
    
    headView.delegate = self;
    headView.friendGroup = _employeesData[section];
    
    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //跳转到聊天界面
    [self performSegueWithIdentifier:@"toChatView" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
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
    if ([self.allEmpCommunicate respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.allEmpCommunicate setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.allEmpCommunicate respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.allEmpCommunicate setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)clickHeadView
{
    [self.allEmpCommunicate reloadData];
}

- (IBAction)msgDisWays:(UISegmentedControl *)sender {
#ifdef  DEBUG_MODE
    NSLog(@"sender:%ld",(long)sender.selectedSegmentIndex);
#endif
    NSDictionary *dict = [[NSDictionary alloc] init];
    NSMutableArray *fgArray = [NSMutableArray array];
    FriendGroup *friendGroup;
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self loadData];
            [self.allEmpCommunicate reloadData];
            break;
        case 1:
            
            friendGroup  = [FriendGroup friendGroupWithDict:dict];
            [fgArray addObject:friendGroup];
            _employeesData = [[NSArray alloc] initWithArray:fgArray];
            [self.allEmpCommunicate reloadData];
            break;
            
        default:
            break;
    }
    
}
@end
