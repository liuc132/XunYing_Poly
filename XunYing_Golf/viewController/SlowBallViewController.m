//
//  SlowBallViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/12/21.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "SlowBallViewController.h"

@interface SlowBallViewController ()<UITableViewDataSource,UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UITableView *slowBallTableView;

@end

@implementation SlowBallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.slowBallTableView.dataSource = self;
    self.slowBallTableView.delegate   = self;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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
    if ([self.slowBallTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.slowBallTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.slowBallTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.slowBallTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

@end
