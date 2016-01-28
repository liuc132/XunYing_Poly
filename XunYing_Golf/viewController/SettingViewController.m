//
//  SettingViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 16/1/4.
//  Copyright © 2016年 LiuC. All rights reserved.
//

#import "SettingViewController.h"
#import "DataTable.h"
#import "DBCon.h"

@interface SettingViewController ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *inputHeartIntervalTime;
@property (strong, nonatomic) IBOutlet UITextField *inputIPAddress;
@property (strong, nonatomic) IBOutlet UITextField *inputPortNum;
@property (strong, nonatomic) IBOutlet UILabel *deviceIDNum;

- (IBAction)confirmSetting:(UIButton *)sender;
- (IBAction)backToLogInView:(UIBarButtonItem *)sender;


@property (strong, nonatomic) UITapGestureRecognizer *tapDismiss;
@property (strong, nonatomic) DBCon                  *lcDbCon;
@property (strong, nonatomic) DataTable              *storedIPAddr;
@property (strong, nonatomic) DataTable              *storedUniqueID;



@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tapDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInput:)];
    self.tapDismiss.delegate = self;
    [self.view addGestureRecognizer:self.tapDismiss];
    //
    self.lcDbCon = [[DBCon alloc] init];
    self.storedIPAddr = [[DataTable alloc] init];
    self.storedUniqueID = [[DataTable alloc] init];
    //查询数据库
    self.storedIPAddr = [self.lcDbCon ExecDataTable:@"select *from tbl_SettingInfo"];
    self.storedUniqueID = [self.lcDbCon ExecDataTable:@"select *from tbl_uniqueID"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    __weak typeof(self) weakSelf = self;
    //将已有的数据显示出来
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.storedIPAddr.Rows count]) {
            weakSelf.inputHeartIntervalTime.text = [NSString stringWithFormat:@"%@",weakSelf.storedIPAddr.Rows[0][@"interval"]];
            weakSelf.inputIPAddress.text = [NSString stringWithFormat:@"%@",weakSelf.storedIPAddr.Rows[0][@"ipAddr"]];
            weakSelf.inputPortNum.text = [NSString stringWithFormat:@"%@",weakSelf.storedIPAddr.Rows[0][@"portNum"]];
        }
        //
        if ([weakSelf.storedUniqueID.Rows count]) {
            weakSelf.deviceIDNum.text = weakSelf.storedUniqueID.Rows[0][@"uiniqueID"];
        }
        
    });
    
}

- (void)dismissInput:(id)sender
{
    [self.inputHeartIntervalTime resignFirstResponder];
    [self.inputIPAddress resignFirstResponder];
    [self.inputPortNum resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//tbl_SettingInfo(interval text,ipAddr text,portNum text)
- (IBAction)confirmSetting:(UIButton *)sender {
    NSLog(@"enter confirm setting and store");
    __weak typeof(self) weakSelf = self;
    [self.inputHeartIntervalTime resignFirstResponder];
    [self.inputIPAddress resignFirstResponder];
    [self.inputPortNum resignFirstResponder];
    //
    [self.lcDbCon ExecDataTable:@"delete from tbl_SettingInfo"];
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *settingData = [[NSMutableArray alloc] initWithObjects:self.inputHeartIntervalTime.text,self.inputIPAddress.text,self.inputPortNum.text, nil];
        [self.lcDbCon ExecNonQuery:@"insert into tbl_SettingInfo(interval,ipAddr,portNum) values(?,?,?)" forParameter:settingData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            DataTable *table = [[DataTable alloc] init];
//            table = [weakSelf.lcDbCon ExecDataTable:@"select *from tbl_SettingInfo"];
//            NSLog(@"table:%@",table.Rows);
            
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
    
    NSLog(@"intervalTime:%@ IP:%@ PortNum:%@",self.inputHeartIntervalTime.text,self.inputIPAddress.text,self.inputPortNum.text);
}
- (IBAction)backToLogInView:(UIBarButtonItem *)sender {
    [self.inputHeartIntervalTime resignFirstResponder];
    [self.inputIPAddress resignFirstResponder];
    [self.inputPortNum resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
