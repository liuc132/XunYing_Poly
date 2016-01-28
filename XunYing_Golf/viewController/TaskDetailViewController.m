//
//  TaskDetailViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/12/21.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "MessageModel.h"
#import "CellFrameModel.h"
#import "MessageCell.h"
#import "DBCon.h"
#import "DataTable.h"
#import "XunYingPre.h"


#define kToolBarH 44
#define kTextFieldH 30

@interface TaskDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *_cellFrameDatas;
    UITableView *_chatView;
    UIImageView *_toolBar;
}

@property (strong, nonatomic) UITableView *lcChatView;


@property (strong, nonatomic) IBOutlet UINavigationBar *theNav;
@property (strong, nonatomic) IBOutlet UILabel *statusDisLabel;
@property (strong, nonatomic) IBOutlet UIView *jumpHoleDetailView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItemDetail;
//三行事件视图
@property (strong, nonatomic) IBOutlet UILabel *threeLineReqTime;//申请时间

@property (strong, nonatomic) IBOutlet UILabel *threeLineReqPerson;//申请人
@property (strong, nonatomic) IBOutlet UILabel *taskReqName;//请求事件名称
@property (strong, nonatomic) IBOutlet UILabel *taskReqDetail;//请求事件详情
@property (strong, nonatomic) IBOutlet UIView *threeLineDetailView;
@property (strong, nonatomic) IBOutlet UIButton *showOrDismissThreeLine;
@property (strong, nonatomic) IBOutlet UIImageView *threeLineButtonImage;
- (IBAction)showOrDismissThreeLine:(UIButton *)sender;




//四行事件视图
@property (strong, nonatomic) IBOutlet UILabel *fourLineReqTime;//请求时间
@property (strong, nonatomic) IBOutlet UILabel *fourLineReqPerson;//请求人
@property (strong, nonatomic) IBOutlet UILabel *fourLineReqName;//请求事件名称
@property (strong, nonatomic) IBOutlet UILabel *fourLineReqDetail;//请求事件详情
@property (strong, nonatomic) IBOutlet UILabel *fourLineHandleName;//处理结果名称
@property (strong, nonatomic) IBOutlet UILabel *fourLineHandleResult;//处理结果详情
@property (strong, nonatomic) IBOutlet UIImageView *fourLineImage;
@property (strong, nonatomic) IBOutlet UIButton *fourLineButtonView;

- (IBAction)fourLineDismissShow:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIView *fourLineView;

//五行事件视图
@property (strong, nonatomic) IBOutlet UILabel *fiveLineReqTime;//请求时间
@property (strong, nonatomic) IBOutlet UILabel *fiveLineReqPerson;//请求人
@property (strong, nonatomic) IBOutlet UILabel *fiveLineReqName;//事件请求名称
@property (strong, nonatomic) IBOutlet UILabel *fiveLineReqDetail;//事件请求详情 申请恢复时间
@property (strong, nonatomic) IBOutlet UILabel *fiveLineHandleName;//事件处理结果名称
@property (strong, nonatomic) IBOutlet UILabel *fiveLineHandleDetail;//事件处理结果详情 后台推荐恢复时间
@property (strong, nonatomic) IBOutlet UILabel *rebackHandleName;//恢复事件名称
@property (strong, nonatomic) IBOutlet UILabel *rebackHandleDetail;//恢复事件详情 复场起始球洞号
@property (strong, nonatomic) IBOutlet UIImageView *fiveLineImage;
@property (strong, nonatomic) IBOutlet UIButton *fiveLineButtonView;

- (IBAction)fiveLineDismissShow:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIView *fiveLineView;


//
- (IBAction)backToTaskList:(UIBarButtonItem *)sender;

@property (strong, nonatomic) DBCon *lcDbCon;
@property (strong, nonatomic) DataTable *allTaskInfo;
@property (strong, nonatomic) DataTable *allCartsInfo;
@property (strong, nonatomic) DataTable *allCaddiesInfo;
@property (strong, nonatomic) DataTable *allHolesInfo;


@end

@implementation TaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lcDbCon = [[DBCon alloc] init];
    self.allTaskInfo = [[DataTable alloc] init];
    self.allCartsInfo = [[DataTable alloc] init];
    self.allCaddiesInfo = [[DataTable alloc] init];
    self.allHolesInfo   = [[DataTable alloc] init];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //查询数据库
    self.allTaskInfo = [self.lcDbCon ExecDataTable:@"select *from tbl_taskInfo"];
    self.allCaddiesInfo = [self.lcDbCon ExecDataTable:@"select *from tbl_caddyInf"];
    self.allCartsInfo   = [self.lcDbCon ExecDataTable:@"select *from tbl_cartInf"];
    self.allHolesInfo   = [self.lcDbCon ExecDataTable:@"select *from tbl_holeInf"];
    //
    self.jumpHoleDetailView.frame = CGRectMake(0, self.theNav.frame.origin.y + self.theNav.frame.size.height, ScreenWidth, ScreenHeight - (self.theNav.frame.origin.y + self.theNav.frame.size.height));
    
    //0.加载数据
    [self loadData];
    
    //1.tableView
    [self addChatView];
    
    //2.工具栏
    [self addToolBar];
    
    //添加当前事务详情的状态栏
    [self.statusDisLabel setFrame:CGRectMake(0, self.theNav.frame.origin.y + self.theNav.frame.size.height, ScreenWidth, self.statusDisLabel.frame.size.height)];
    
    //
    self.statusDisLabel.text = self.taskStatus;
    
    
    [self switchTheDisView];
    
//    [self.view addSubview:theDetailListView];
    [self.view addSubview:self.statusDisLabel];
    //
    
    //
    [self.view addSubview:self.theNav];
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataByNotification:) name:@"detailRefresh"object:nil];
    
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

- (void)refreshDataByNotification:(NSNotification *)sender
{
    [self.view setNeedsDisplay];
    //
    //查询数据库
    self.allTaskInfo = [self.lcDbCon ExecDataTable:@"select *from tbl_taskInfo"];
    //
    NSLog(@"%@",sender.userInfo);
    if ([sender.userInfo[@"evecod"] isEqualToString:[NSString stringWithFormat:@"%@",self.allTaskInfo.Rows[self.selectRowNum][@"evecod"]]]) {
        [self switchTheDisView];
    }
    
}

- (void)switchTheDisView
{
    NSLog(@"whichRowData:%@",self.allTaskInfo.Rows[self.selectRowNum]);
    NSDictionary *theSelectTaskRow = self.allTaskInfo.Rows[self.selectRowNum];
    NSString *detailStr;
    NSString *detailStrNew;
    NSString *taskTypeNameStr;
    NSString *navTaskTypeName;
    NSString *handleResultName;
    //选择相应的详情视图
    //根据状态来切换相遇的视图
    switch ([self.allTaskInfo.Rows[self.selectRowNum][@"result"] intValue]) {
        case 0://待处理
        case 2://不同意
            [self.threeLineDetailView setFrame:CGRectMake(0, self.statusDisLabel.frame.origin.y + self.statusDisLabel.frame.size.height, ScreenWidth, self.threeLineDetailView.frame.size.height)];
            [self.view addSubview:self.threeLineDetailView];
            break;
            
        case 1://同意
            
            if ([self.allTaskInfo.Rows[self.selectRowNum][@"evetyp"] intValue] == 6) {
                [self.fiveLineView setFrame:CGRectMake(0, self.statusDisLabel.frame.origin.y + self.statusDisLabel.frame.size.height, ScreenWidth, self.fiveLineView.frame.size.height)];
                [self.view addSubview:self.fiveLineView];
            }
            else
            {
                [self.fourLineView setFrame:CGRectMake(0, self.statusDisLabel.frame.origin.y + self.statusDisLabel.frame.size.height, ScreenWidth, self.fourLineView.frame.size.height)];
                [self.view addSubview:self.fourLineView];
            }
            
            break;
        default:
            break;
    }
    //
    switch ([theSelectTaskRow[@"evetyp"] intValue]) {
        case 1://换球车
            for (NSDictionary *eachCart in self.allCartsInfo.Rows) {
                if ([eachCart[@"carcod"] isEqualToString:[NSString stringWithFormat:@"%@",theSelectTaskRow[@"newCartCode"]]]) {
                    detailStr = eachCart[@"carnum"];
                }
                if ([eachCart[@"carcod"] isEqualToString:[NSString stringWithFormat:@"%@",theSelectTaskRow[@"oldCartCode"]]]) {
                    detailStrNew = eachCart[@"carnum"];
                }
            }
            navTaskTypeName = @"更换球车详情";
            taskTypeNameStr = @"待更换球车";
            handleResultName = @"已更换新球车";
            break;
        case 2://换球童
            for (NSDictionary *eachCaddy in self.allCaddiesInfo.Rows) {
                if ([eachCaddy[@"cadcod"] isEqualToString:[NSString stringWithFormat:@"%@",theSelectTaskRow[@"newCaddyCode"]]]) {
                    detailStr = [NSString stringWithFormat:@"%@ %@",eachCaddy[@"cadnum"],eachCaddy[@"cadnam"]];
                }
                if ([eachCaddy[@"cadcod"] isEqualToString:[NSString stringWithFormat:@"%@",theSelectTaskRow[@"oldCaddyCode"]]]) {
                    detailStrNew = [NSString stringWithFormat:@"%@ %@",eachCaddy[@"cadnum"],eachCaddy[@"cadnam"]];
                }
            }
            
            navTaskTypeName = @"更换球童详情";
            taskTypeNameStr = @"待换球童";
            handleResultName = @"替换球童";
            break;
        case 3://跳洞
            for (NSDictionary *eachHole in self.allHolesInfo.Rows) {
                if ([eachHole[@"holcod"] isEqualToString:[NSString stringWithFormat:@"%@",theSelectTaskRow[@"toHoleCode"]]]) {
                    detailStr = [NSString stringWithFormat:@"%@(预计%@开球)",eachHole[@"holenum"],[theSelectTaskRow[@"destintime"] substringWithRange:NSMakeRange(11, 5)]];
                }
                if ([eachHole[@"holcod"] isEqualToString:[NSString stringWithFormat:@"%@",theSelectTaskRow[@"jumpHoleCode"]]]) {
                    detailStrNew = eachHole[@"holenum"];
                }
            }
            
            navTaskTypeName = @"跳洞详情";
            taskTypeNameStr = @"跳过球洞";
            handleResultName = @"跳到球洞";
            break;
        case 4://补洞
            for (NSDictionary *eachHole in self.allHolesInfo.Rows) {
                if ([eachHole[@"holcod"] isEqualToString:[NSString stringWithFormat:@"%@",theSelectTaskRow[@"mendHoleCode"]]]) {
                    detailStr = eachHole[@"holenum"];
                }
                if ([eachHole[@"holcod"] isEqualToString:[NSString stringWithFormat:@"%@",theSelectTaskRow[@"reHoleCode"]]]) {
                    detailStrNew = eachHole[@"holenum"];
                }
            }
            
            navTaskTypeName = @"补洞详情";
            taskTypeNameStr = @"待补打球洞";
            handleResultName = @"补打球洞";
            break;
        case 5://点餐
            
            break;
        case 6://离场休息
            detailStr = self.taskLeaveRebacktime;
            navTaskTypeName = @"离场休息详情";
            taskTypeNameStr = @"申请的恢复时间";
            //
            for (NSDictionary *eachHole in self.allHolesInfo.Rows) {
                if ([eachHole[@"holcod"] isEqualToString:[NSString stringWithFormat:@"%@",theSelectTaskRow[@"reHoleCode"]]]) {
                    detailStr = eachHole[@"holenum"];
                }
            }
            detailStrNew = [theSelectTaskRow objectForKey:@"reqBackTime"];
            
            if (![detailStrNew  isEqual: @""]) {
                detailStrNew = theSelectTaskRow[@"reqBackTime"];
                detailStrNew = [detailStrNew substringWithRange:NSMakeRange(11, 5)];
            }
            
            break;
        default:
            break;
    }
    self.taskReqDetail.text = detailStr; //当前所选择的事务详情的显示
    //显示事件状态,同时根据相应的状态切换显示视图
    switch ([theSelectTaskRow[@"result"] intValue]) {
        case 0://待处理
            self.statusDisLabel.text = @"待处理";
            self.threeLineReqPerson.text    = self.taskRequestPerson;
            self.threeLineReqTime.text      = [self.taskRequstTime substringWithRange:NSMakeRange(0, 5)];
            self.taskReqName.text           = taskTypeNameStr;
            self.navigationItemDetail.title = navTaskTypeName;
            self.taskReqDetail.text         = detailStrNew;
            
            break;
        case 1://同意
            self.statusDisLabel.text = @"同意";
            if ([theSelectTaskRow[@"evetyp"] intValue] == 6) {
                self.fiveLineReqPerson.text = self.taskRequestPerson;
                self.fiveLineReqTime.text   = [self.taskRequstTime substringWithRange:NSMakeRange(0, 5)];
                self.fiveLineReqName.text   = taskTypeNameStr;
                self.navigationItemDetail.title = navTaskTypeName;
                self.fiveLineReqDetail.text = [self.taskRequstTime substringWithRange:NSMakeRange(0, 5)];
                self.fiveLineHandleName.text = @"后台推荐恢复时间";
                self.rebackHandleName.text   = @"复场起始球洞";
                self.fiveLineHandleDetail.text  = detailStrNew;
                self.rebackHandleDetail.text    = detailStr;
            }
            else
            {
                self.fourLineReqPerson.text = self.taskRequestPerson;
                self.fourLineReqTime.text   = [self.taskRequstTime substringWithRange:NSMakeRange(0, 5)];
                self.fourLineReqName.text   = taskTypeNameStr;
                self.navigationItemDetail.title = navTaskTypeName;
                self.fourLineReqDetail.text = detailStrNew;
                self.fourLineHandleName.text    = handleResultName;
                self.fourLineHandleResult.text  = detailStr;
            }
            
            break;
        case 2:
            self.statusDisLabel.text = @"不同意";
            self.threeLineReqPerson.text    = self.taskRequestPerson;
            self.threeLineReqTime.text      = [self.taskRequstTime substringWithRange:NSMakeRange(0, 5)];
            self.taskReqName.text           = taskTypeNameStr;
            self.navigationItemDetail.title = navTaskTypeName;
            self.taskReqDetail.text         = detailStrNew;
            break;
            
        default:
            break;
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationItemDetail.title = self.taskTypeName;
    
}
/**
 *  加载数据
 */
- (void)loadData
{
    _cellFrameDatas =[NSMutableArray array];
    NSURL *dataUrl = [[NSBundle mainBundle] URLForResource:@"messages.plist" withExtension:nil];
    NSArray *dataArray = [NSArray arrayWithContentsOfURL:dataUrl];
    for (NSDictionary *dict in dataArray) {
        MessageModel *message = [MessageModel messageModelWithDict:dict];
        CellFrameModel *lastFrame = [_cellFrameDatas lastObject];
        CellFrameModel *cellFrame = [[CellFrameModel alloc] init];
        message.showTime = ![message.time isEqualToString:lastFrame.message.time];
        cellFrame.message = message;
        [_cellFrameDatas addObject:cellFrame];
    }
}
/**
 *  添加TableView
 */
- (void)addChatView
{
    self.jumpHoleDetailView.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1.0];
    self.lcChatView = [[UITableView alloc] init];
    self.lcChatView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.jumpHoleDetailView.frame.size.height - kToolBarH);
    self.lcChatView.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1.0];
    self.lcChatView.delegate = self;
    self.lcChatView.dataSource = self;
    self.lcChatView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.lcChatView.allowsSelection = NO;
    [self.lcChatView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)]];
    _chatView = self.lcChatView;
    
    [self.jumpHoleDetailView addSubview:self.lcChatView];
}
/**
 *  添加工具栏
 */
- (void)addToolBar
{
    UIImageView *bgView = [[UIImageView alloc] init];
    bgView.frame = CGRectMake(0, self.jumpHoleDetailView.frame.size.height - kToolBarH, self.view.frame.size.width, kToolBarH);
    bgView.image = [UIImage imageNamed:@"chat_bottom_bg"];
    bgView.userInteractionEnabled = YES;
    _toolBar = bgView;
    [self.jumpHoleDetailView addSubview:bgView];
    
    UIButton *sendSoundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendSoundBtn.frame = CGRectMake(0, 0, kToolBarH, kToolBarH);
    [sendSoundBtn setImage:[UIImage imageNamed:@"chat_bottom_voice_nor"] forState:UIControlStateNormal];
    [bgView addSubview:sendSoundBtn];
    
    UIButton *addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMoreBtn.frame = CGRectMake(self.view.frame.size.width - kToolBarH, 0, kToolBarH, kToolBarH);
    [addMoreBtn setImage:[UIImage imageNamed:@"chat_bottom_up_nor"] forState:UIControlStateNormal];
    [bgView addSubview:addMoreBtn];
    
    UIButton *expressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    expressBtn.frame = CGRectMake(self.view.frame.size.width - kToolBarH * 2, 0, kToolBarH, kToolBarH);
    [expressBtn setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
    [bgView addSubview:expressBtn];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.returnKeyType = UIReturnKeySend;
    textField.enablesReturnKeyAutomatically = YES;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 1)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.frame = CGRectMake(kToolBarH, (kToolBarH - kTextFieldH) * 0.5, self.jumpHoleDetailView.frame.size.width - 3 * kToolBarH, kTextFieldH);
    textField.background = [UIImage imageNamed:@"chat_bottom_textfield"];
    textField.delegate = self;
    [bgView addSubview:textField];
}

#pragma mark - tableView的数据源和代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numOfRows;
    if (tableView == self.lcChatView) {
        numOfRows = _cellFrameDatas.count;
    }
    else
    {
        numOfRows = 4;
    }
    
    return numOfRows;
}

- (MessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tableView == self.lcChatView) {
        
        if (cell == nil) {
            cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.cellFrame = _cellFrameDatas[indexPath.row];
        
    }
    else
    {
        if (cell == nil) {
            cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.detailTextLabel.text = self.taskRequestPerson;
        }
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (tableView == self.lcChatView) {
        CellFrameModel *cellFrame = _cellFrameDatas[indexPath.row];
        height = cellFrame.cellHeght;
    }
    else
    {
        height = 40.0f;
    }
    
    return height;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    self.threeLineDetailView.hidden = NO;
}

#pragma mark - UITextField的代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //1.获得时间
    NSDate *senddate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    //2.创建一个MessageModel类
    MessageModel *message = [[MessageModel alloc] init];
    message.text = textField.text;
    message.time = locationString;
    message.type = 0;
    
    //3.创建一个CellFrameModel类
    CellFrameModel *cellFrame = [[CellFrameModel alloc] init];
    CellFrameModel *lastCellFrame = [_cellFrameDatas lastObject];
    message.showTime = ![lastCellFrame.message.time isEqualToString:message.time];
    cellFrame.message = message;
    
    //4.添加进去，并且刷新数据
    [_cellFrameDatas addObject:cellFrame];
    [_chatView reloadData];
    
    //5.自动滚到最后一行
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:_cellFrameDatas.count - 1 inSection:0];
    [_chatView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    textField.text = @"";
    
    return YES;
}

- (void)endEdit
{
//    [self.view endEditing:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        self.threeLineDetailView.hidden = NO;
    });
    
//    [self.jumpHoleDetailView endEditing:YES];
}

/**
 *  键盘发生改变执行
 */
- (void)keyboardWillChange:(NSNotification *)note
{
    NSLog(@"%@", note.userInfo);
    NSDictionary *userInfo = note.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height;
    //
    self.threeLineDetailView.hidden = YES;
    
    [UIView animateWithDuration:duration animations:^{
        self.jumpHoleDetailView.transform = CGAffineTransformMakeTranslation(0, moveY);
    }];
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

- (IBAction)backToTaskList:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"taskDetailtoAllTaskList" sender:nil];
}
- (IBAction)showOrDismissThreeLine:(UIButton *)sender {
    NSLog(@"enter show or dismiss view");
    __weak typeof(self) weakSelf = self;
    static BOOL showEnable = NO;
    
    
    //对事务详情的子视图进行平移
    if (!showEnable) {
        showEnable = !showEnable;
        //
        
        CGFloat moveYN = self.statusDisLabel.frame.size.height - self.threeLineDetailView.frame.size.height;
        //
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.threeLineDetailView.transform = CGAffineTransformMakeTranslation(0, moveYN);
        }];
    }
    else
    {
        showEnable = !showEnable;
        CGFloat moveYP = self.threeLineDetailView.frame.size.height - self.statusDisLabel.frame.size.height;
        //
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.threeLineDetailView.transform = CGAffineTransformMakeTranslation(0, moveYP/8);
        }];
    }
    
}
- (IBAction)fiveLineDismissShow:(UIButton *)sender {
    NSLog(@"enter show or dismiss view");
    __weak typeof(self) weakSelf = self;
    static BOOL showEnable = NO;
    
    
    //对事务详情的子视图进行平移
    if (!showEnable) {
        showEnable = !showEnable;
        //
        
        CGFloat moveYN = self.statusDisLabel.frame.size.height - self.fiveLineView.frame.size.height;
        //
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.fiveLineView.transform = CGAffineTransformMakeTranslation(0, moveYN);
        }];
    }
    else
    {
        showEnable = !showEnable;
        CGFloat moveYP = self.fiveLineView.frame.size.height - self.statusDisLabel.frame.size.height;
        //
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.fiveLineView.transform = CGAffineTransformMakeTranslation(0, moveYP/8);
        }];
    }
    
}
- (IBAction)fourLineDismissShow:(UIButton *)sender {
    NSLog(@"enter show or dismiss view");
    __weak typeof(self) weakSelf = self;
    static BOOL showEnable = NO;
    
    
    //对事务详情的子视图进行平移
    if (!showEnable) {
        showEnable = !showEnable;
        //
        
        CGFloat moveYN = self.statusDisLabel.frame.size.height - self.fourLineView.frame.size.height;
        //
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.fourLineView.transform = CGAffineTransformMakeTranslation(0, moveYN);
        }];
    }
    else
    {
        showEnable = !showEnable;
        CGFloat moveYP = self.fourLineView.frame.size.height - self.statusDisLabel.frame.size.height;
        //
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.fourLineView.transform = CGAffineTransformMakeTranslation(0, moveYP/8);
        }];
    }
    
}
@end
