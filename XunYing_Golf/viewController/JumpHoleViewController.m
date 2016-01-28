//
//  JumpHoleViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/10/13.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "JumpHoleViewController.h"
#import "HttpTools.h"
#import "XunYingPre.h"
#import "UIColor+UICon.h"
#import "DataTable.h"
#import "DBCon.h"

#define CurrentHole     @"5ccd73"
#define SelectedHole    @"f74c30"
#define NoSelectedHole  @"cacaca"
#define EitghteenHoles  18

@interface JumpHoleViewController ()

@property (strong, nonatomic) DBCon *locDBCon;
@property (strong, nonatomic) DataTable *logPerson;
@property (strong, nonatomic) DataTable *grpInf;

@property (nonatomic) NSInteger selectedJumpNum;

@property (strong, nonatomic) UIButton *theOldSelectedBtn;




@property (strong, nonatomic) IBOutlet UILabel *requestPerson;
@property (strong, nonatomic) IBOutlet UILabel *curHoleNum;
@property (strong, nonatomic) IBOutlet UILabel *jumpHoleNum;


- (IBAction)whichHole:(UIButton *)sender;

- (IBAction)requestToJumpHole:(UIButton *)sender;

@end

@implementation JumpHoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //alloc and init locDBCon,userInf,grpInf
    self.locDBCon = [[DBCon alloc] init];
    self.logPerson = [[DataTable alloc] init];
    self.grpInf = [[DataTable alloc] init];
    //查询申请跳洞的登录人的信息，以及所创建的组信息
    self.logPerson = [self.locDBCon ExecDataTable:@"select *from tbl_logPerson"];
    self.grpInf = [self.locDBCon ExecDataTable:@"select *from tbl_holeInf"];
    
    NSLog(@"finish check out all the data");
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

-(void)settingBackGoundColor:(UIButton *)theOldBtn
{
    [theOldBtn setBackgroundColor:[UIColor HexString:NoSelectedHole]];
}

- (IBAction)whichHole:(UIButton *)sender {
    static unsigned char ucOldSelectedHole = 20;
    
    if(ucOldSelectedHole != sender.tag)
    {
        //将之前选择的按键颜色给改变一下;初始的时候选择跳过的球洞在当前所在的球洞
        [self settingBackGoundColor:self.theOldSelectedBtn];
        
        //记录下之前所选择的球洞按键
        self.theOldSelectedBtn = sender;
        //
        NSLog(@"oldSelectedBtn.tag:%ld",(long)self.theOldSelectedBtn.tag);
        //
        self.jumpHoleNum.text = [NSString stringWithFormat:@"%ld",(long)sender.tag];
        //
        self.selectedJumpNum = sender.tag - 1;
        //设置被选择上的球洞好的背景色为已选状态
        [sender setBackgroundColor:[UIColor HexString:SelectedHole]];
        
    }
    
}

- (IBAction)requestToJumpHole:(UIButton *)sender {
    
    
    __weak JumpHoleViewController *weakSelf = self;
    //组建跳动请求参数
    NSMutableDictionary *jumpHoleParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:TESTMIDCODE,@"mid",self.logPerson.Rows[0][@"code"],@"code",self.grpInf.Rows[self.selectedJumpNum][@"holcod"],@"aplcod", nil];
    //start request
    [HttpTools getHttp:JumpHoleURL forParams:jumpHoleParam success:^(NSData *nsData){
        JumpHoleViewController *strongSelf = weakSelf;
        NSLog(@"JumpHole request success");
        
        NSDictionary *recDic = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"code:%@  msg:%@",recDic[@"Code"],recDic[@"Msg"]);
        
        //[strongSelf performSegueWithIdentifier:@"backToCurTask" sender:nil];
        [strongSelf.navigationController popViewControllerAnimated:YES];
        
    }failure:^(NSError *err){
        NSLog(@"JumpHole request fail");
        
        
    }];
    
}



@end
