//
//  PersonalScoreViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/11/25.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "PersonalScoreViewController.h"
#import "DataTable.h"
#import "DBCon.h"


@interface PersonalScoreViewController ()

@property (strong, nonatomic) IBOutlet UILabel *theFirstGrpCode;
@property (strong, nonatomic) IBOutlet UILabel *theFirstCusCard;
@property (strong, nonatomic) IBOutlet UILabel *theFirstCusName;
@property (strong, nonatomic) IBOutlet UILabel *theFirstCusLevel;
@property (strong, nonatomic) IBOutlet UIView *theFirstCusView;


@property (strong, nonatomic) IBOutlet UILabel *theSecondGrpCode;
@property (strong, nonatomic) IBOutlet UILabel *theSecondCusCard;
@property (strong, nonatomic) IBOutlet UILabel *theSecondCusName;
@property (strong, nonatomic) IBOutlet UILabel *theSecondCusLevel;
@property (strong, nonatomic) IBOutlet UIView *theSecondCusView;


@property (strong, nonatomic) IBOutlet UILabel *theThirdGrpCode;
@property (strong, nonatomic) IBOutlet UILabel *theThirdCusCard;
@property (strong, nonatomic) IBOutlet UILabel *theThirdCusName;
@property (strong, nonatomic) IBOutlet UILabel *theThirdCusLevel;
@property (strong, nonatomic) IBOutlet UIView *theThirdCusView;


@property (strong, nonatomic) IBOutlet UILabel *theFourthGrpNum;
@property (strong, nonatomic) IBOutlet UILabel *theFourthCusCard;
@property (strong, nonatomic) IBOutlet UILabel *theFourthCusName;
@property (strong, nonatomic) IBOutlet UILabel *theFourthCusLevel;
@property (strong, nonatomic) IBOutlet UIView *theFourthCusView;

- (IBAction)scoreManageEnter:(UIButton *)sender;


@property (strong, nonatomic) DBCon             *scoreDBCon;
@property (strong, nonatomic) DataTable         *cusInfoTable;
@property (strong, nonatomic) DataTable         *cusGrpTable;



@end

@implementation PersonalScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //alloc and init
    self.scoreDBCon     =   [[DBCon alloc] init];
    self.cusInfoTable   =   [[DataTable alloc] init];
    self.cusGrpTable    =   [[DataTable alloc] init];
    //读取数据库中的信息
    self.cusInfoTable   =   [self.scoreDBCon ExecDataTable:@"select *from tbl_CustomersInfo"];
    self.cusGrpTable    =   [self.scoreDBCon ExecDataTable:@"select *from tbl_groupInf"];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏所有的顾客视图，在以下的相应位置再给打开
    self.theFirstCusView.hidden =   YES;
    self.theSecondCusView.hidden    =   YES;
    self.theThirdCusView.hidden     =   YES;
    self.theFourthCusView.hidden    =   YES;
    //根据本地所存储的数据，将相应的信息给显示出来
    NSString *grpNumStr;
    NSString *firstCusCardNumStr;
    NSString *secondCusCardNumStr;
    NSString *thirdCusCardNumStr;
    NSString *fourthCusCardNumStr;
    //读取到组编号tbl_groupInf(grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text)
    if ([self.cusGrpTable.Rows count]) {
        
        NSString *gropNumStr;// = [[NSString alloc] init];
        gropNumStr = self.cusGrpTable.Rows[0][@"gronum"];
        //将组编号显示出来
        if ([gropNumStr hasPrefix:@"_"]) {
            grpNumStr = gropNumStr;
        }
        else
            grpNumStr = [gropNumStr substringToIndex:3];
    }
    
    //读取到相应的顾客消费卡号
    if ([self.cusInfoTable.Rows count] == 1) {
        firstCusCardNumStr = [NSString stringWithFormat:@"%@",self.cusInfoTable.Rows[0][@"cusnum"]];
    }
    else if ([self.cusInfoTable.Rows count] == 2)
    {
        firstCusCardNumStr = [NSString stringWithFormat:@"%@",self.cusInfoTable.Rows[0][@"cusnum"]];
        secondCusCardNumStr = [NSString stringWithFormat:@"%@",self.cusInfoTable.Rows[1][@"cusnum"]];
    }
    else if ([self.cusInfoTable.Rows count] == 3)
    {
        firstCusCardNumStr = [NSString stringWithFormat:@"%@",self.cusInfoTable.Rows[0][@"cusnum"]];
        secondCusCardNumStr = [NSString stringWithFormat:@"%@",self.cusInfoTable.Rows[1][@"cusnum"]];
        thirdCusCardNumStr  = [NSString stringWithFormat:@"%@",self.cusInfoTable.Rows[2][@"cusnum"]];
    }
    else if([self.cusInfoTable.Rows count] == 4)
    {
        firstCusCardNumStr = [NSString stringWithFormat:@"%@",self.cusInfoTable.Rows[0][@"cusnum"]];
        secondCusCardNumStr = [NSString stringWithFormat:@"%@",self.cusInfoTable.Rows[1][@"cusnum"]];
        thirdCusCardNumStr  = [NSString stringWithFormat:@"%@",self.cusInfoTable.Rows[2][@"cusnum"]];
        fourthCusCardNumStr = [NSString stringWithFormat:@"%@",self.cusInfoTable.Rows[3][@"cusnum"]];
    }
    //将相应的数据显示出来
    switch ([self.cusInfoTable.Rows count]) {
        case 4:
            self.theFourthCusView.hidden = NO;
            self.theFourthGrpNum.text    = grpNumStr;
            self.theFourthCusCard.text   = fourthCusCardNumStr;
            
        case 3:
            self.theThirdCusView.hidden  = NO;
            self.theThirdGrpCode.text    = grpNumStr;
            self.theThirdCusCard.text    = thirdCusCardNumStr;
            
        case 2:
            self.theSecondCusView.hidden = NO;
            self.theSecondGrpCode.text   = grpNumStr;
            self.theSecondCusCard.text   = secondCusCardNumStr;
            
        case 1:
            self.theFirstCusView.hidden  = NO;
            self.theFirstGrpCode.text    = grpNumStr;
            self.theFirstCusCard.text    = firstCusCardNumStr;
            
            break;
            
        default:
            break;
    }
    
    
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

- (IBAction)scoreManageEnter:(UIButton *)sender {
    NSLog(@"enter scoreManage");
    
    //进入记分界面
    [self performSegueWithIdentifier:@"toPersonalScore" sender:nil];
    
}
@end
