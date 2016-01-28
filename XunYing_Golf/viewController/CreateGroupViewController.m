//
//  CreateGroupViewController.m
//  XunYing_Golf
//
//  Created by LiuC on 15/9/18.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "UIColor+UICon.h"
#import "HttpTools.h"
#import "XunYingPre.h"
#import "DBCon.h"
#import "DataTable.h"
#import "CustomerGroupInfViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"
#import "HeartBeatAndDetectState.h"
#import "WaitToPlayTableViewController.h"
#import "AppDelegate.h"
#import "subCaddyOrCartView.h"
#import "GetRequestIPAddress.h"

//
typedef NS_ENUM(NSInteger,cusNumbers)
{
    OneCustomer,
    TwoCustomer,
    ThreeCustomer,
    FourCustomer,
};
//
typedef NS_ENUM(NSInteger,holePosition) {
    Top9,
    Down9,
    AllHole,
};
//
#define offset  100

@interface CreateGroupViewController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UIButton *oneCustomer;
@property (strong, nonatomic) IBOutlet UIButton *twoCustomer;
@property (strong, nonatomic) IBOutlet UIButton *threeCustomer;
@property (strong, nonatomic) IBOutlet UIButton *fourCustomer;

@property (strong, nonatomic) IBOutlet UIButton *theTop9;
@property (strong, nonatomic) IBOutlet UIButton *theDown9;
@property (strong, nonatomic) IBOutlet UIButton *eighteen;

@property (strong, nonatomic) DBCon *dbCon;
@property (strong, nonatomic) DataTable *userData;
@property (strong, nonatomic) DataTable *theThreeHolesInf;
@property (strong, nonatomic) DataTable *customFourNum;
@property (strong, nonatomic) DataTable *allCartsData;
@property (strong, nonatomic) DataTable *allCaddiesData;
//
@property (strong, nonatomic) NSMutableArray *addCartsArray;
@property (strong, nonatomic) NSMutableArray *addcaddiesArray;
@property (nonatomic)         NSInteger      deleteCartRow;
@property (nonatomic)         NSInteger      deleteCaddyRow;

@property (nonatomic)         NSInteger      caddyIndex;
@property (nonatomic)         NSInteger      cartIndex;

@property (nonatomic)         CGFloat        _caddyOffset;
@property (nonatomic)         CGFloat        _cartOffset;

@property (nonatomic) NSInteger theSelectedCusCounts;
@property (nonatomic) NSInteger theSelectedHolePosition;
@property (strong, nonatomic) NSString  *holePosName;

@property(strong, nonatomic)NSTimer *heartBeatTime;
@property(strong, nonatomic)NSArray *simulationGPSData;
@property(strong, nonatomic)NSMutableDictionary *checkCreatGroupState;
//
//@property (strong, nonatomic) CLLocationManager *locationManager;
//@property (strong, nonatomic) CLLocation *getGPSLocation;
@property (strong, nonatomic) UITapGestureRecognizer *creatGrpTap;
//
@property (strong, nonatomic) NSMutableArray         *allCartsViewArray;
@property (strong, nonatomic) NSMutableArray         *allCaddiesViewArray;

@property (strong, nonatomic) ViewController *mapViewController;
@property (strong, nonatomic) UIActivityIndicatorView   *stateIndicator;

@property (strong, nonatomic) IBOutlet UIView *subDetailView;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;


@property (strong, nonatomic) IBOutlet UIScrollView *createGrpScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *caddyScrollView;
@property (strong, nonatomic) IBOutlet UITextField *inputCaddyNum;
@property (strong, nonatomic) IBOutlet UIButton *addCaddyButton;

- (IBAction)addCaddy:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIScrollView *cartScrollView;
@property (strong, nonatomic) IBOutlet UITextField *inputCartNum;
@property (strong, nonatomic) IBOutlet UIButton *addCartButton;

- (IBAction)addCart:(UIButton *)sender;


- (IBAction)confirmCustomNumbers:(UIButton *)sender;

- (IBAction)handleHoles:(UIButton *)sender;

- (IBAction)createGroupAndDownCourt:(UIButton *)sender;
- (IBAction)backToCreateWay:(UIBarButtonItem *)sender;


@end

@implementation CreateGroupViewController

#define selectedColor       @"4cda64"
#define unselectedColor     @"eeeeee"


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    self.simulationGPSData = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"106.28256131500",@"29.49389984490", nil],[[NSArray alloc] initWithObjects:@"106.28256669700",@"29.49432700910", nil],[[NSArray alloc] initWithObjects:@"106.28281553500",@"29.49458953090", nil],[[NSArray alloc] initWithObjects:@"106.28298506800",@"29.49505329810", nil],[[NSArray alloc] initWithObjects:@"106.28341349200",@"29.49527828640", nil],[[NSArray alloc] initWithObjects:@"106.28296532100",@"29.49592164420", nil],[[NSArray alloc] initWithObjects:@"106.28253196400",@"29.49611735560", nil],[[NSArray alloc] initWithObjects:@"106.28209158900",@"29.49624332170", nil],[[NSArray alloc] initWithObjects:@"106.28165696300",@"29.49617591050", nil],[[NSArray alloc] initWithObjects:@"106.28128793600",@"29.49595571510", nil],[[NSArray alloc] initWithObjects:@"106.28105536100",@"29.49573897710", nil],[[NSArray alloc] initWithObjects:@"106.28060691900",@"29.49565737550", nil],[[NSArray alloc] initWithObjects:@"106.28037981600",@"29.49538747980", nil],[[NSArray alloc] initWithObjects:@"106.27988107400",@"29.49521089300", nil],[[NSArray alloc] initWithObjects:@"106.27950619300",@"29.49490423120", nil],[[NSArray alloc] initWithObjects:@"106.27896363000",@"29.49471374150", nil],[[NSArray alloc] initWithObjects:@"106.27818672000",@"29.49454459560", nil],[[NSArray alloc] initWithObjects:@"106.27752617100",@"29.49495190530", nil],[[NSArray alloc] initWithObjects:@"106.27742754600",@"29.49535381570", nil],[[NSArray alloc] initWithObjects:@"106.27757328600",@"29.49566268470", nil],[[NSArray alloc] initWithObjects:@"106.27758683300",@"29.49598117650", nil],[[NSArray alloc] initWithObjects:@"106.27708125300",@"29.49612923310", nil],[[NSArray alloc] initWithObjects:@"106.27679707600",@"29.49631096300", nil],[[NSArray alloc] initWithObjects:@"106.27649706800",@"29.49653580450", nil],[[NSArray alloc] initWithObjects:@"106.27621136300",@"29.49659582670", nil],[[NSArray alloc] initWithObjects:@"106.27582844200",@"29.49673554190", nil],[[NSArray alloc] initWithObjects:@"106.27543652900",@"29.49681090140", nil],[[NSArray alloc] initWithObjects:@"106.27538489600",@"29.49726248040", nil],[[NSArray alloc] initWithObjects:@"106.27509396400",@"29.49755883220", nil],[[NSArray alloc] initWithObjects:@"106.27518694400",@"29.49779422250", nil],[[NSArray alloc] initWithObjects:@"106.27533291100",@"29.49793095230", nil],[[NSArray alloc] initWithObjects:@"106.27555281500",@"29.49808964580", nil],[[NSArray alloc] initWithObjects:@"106.27586363900",@"29.49829191900", nil],[[NSArray alloc] initWithObjects:@"106.27598903800",@"29.49806636830", nil],[[NSArray alloc] initWithObjects:@"106.27603221000",@"29.49781057860", nil],[[NSArray alloc] initWithObjects:@"106.27643308900",@"29.49779718520", nil],[[NSArray alloc] initWithObjects:@"106.27678636200",@"29.49790358100", nil],[[NSArray alloc] initWithObjects:@"106.27701748600",@"29.49762450680", nil],[[NSArray alloc] initWithObjects:@"106.27744573200",@"29.49761800720", nil],[[NSArray alloc] initWithObjects:@"106.27762187300",@"29.49774042310", nil],[[NSArray alloc] initWithObjects:@"106.27779414900",@"29.49774503270", nil],[[NSArray alloc] initWithObjects:@"106.27799078300",@"29.49724522150", nil],[[NSArray alloc] initWithObjects:@"106.27841002000",@"29.49668449810", nil],[[NSArray alloc] initWithObjects:@"106.27860578000",@"29.49625122350", nil],[[NSArray alloc] initWithObjects:@"106.27894704300",@"29.49599913010", nil],[[NSArray alloc] initWithObjects:@"106.27976262200",@"29.49631348670", nil],[[NSArray alloc] initWithObjects:@"106.28051225100",@"29.49626450440", nil],[[NSArray alloc] initWithObjects:@"106.28123775500",@"29.49646635190", nil],[[NSArray alloc] initWithObjects:@"106.28149653900",@"29.49697699490", nil],[[NSArray alloc] initWithObjects:@"106.28151023800",@"29.49643986010", nil],[[NSArray alloc] initWithObjects:@"106.28205570100",@"29.49648054630", nil],[[NSArray alloc] initWithObjects:@"106.28217423800",@"29.49679444580", nil],[[NSArray alloc] initWithObjects:@"106.28226058300",@"29.49715161490", nil],[[NSArray alloc] initWithObjects:@"106.28195402700",@"29.49750541300", nil],[[NSArray alloc] initWithObjects:@"106.28224297800",@"29.49770310830", nil],[[NSArray alloc] initWithObjects:@"106.28205926400",@"29.49806288180", nil],[[NSArray alloc] initWithObjects:@"106.28229435800",@"29.49853317810", nil],[[NSArray alloc] initWithObjects:@"106.28273618600",@"29.49852175670", nil],[[NSArray alloc] initWithObjects:@"106.28278907800",@"29.49882196860", nil],[[NSArray alloc] initWithObjects:@"106.28319936100",@"29.49922971260", nil],[[NSArray alloc] initWithObjects:@"106.28339751600",@"29.49936622830", nil],[[NSArray alloc] initWithObjects:@"106.28344986900",@"29.49962348490", nil],[[NSArray alloc] initWithObjects:@"106.28362758600",@"29.49986998410", nil],[[NSArray alloc] initWithObjects:@"106.28396807700",@"29.50004331140", nil],[[NSArray alloc] initWithObjects:@"106.28419788500",@"29.50009359890", nil],[[NSArray alloc] initWithObjects:@"106.28435366100",@"29.50033076260", nil],[[NSArray alloc] initWithObjects:@"106.28450343900",@"29.50052502390", nil],[[NSArray alloc] initWithObjects:@"106.28440176500",@"29.50068352650", nil],[[NSArray alloc] initWithObjects:@"106.28455651800",@"29.50083955310", nil],[[NSArray alloc] initWithObjects:@"106.28478843600",@"29.50078659490", nil],[[NSArray alloc] initWithObjects:@"106.28489986500",@"29.50059040760", nil],[[NSArray alloc] initWithObjects:@"106.28486279100",@"29.50024708380", nil],[[NSArray alloc] initWithObjects:@"106.28469345200",@"29.49980002470", nil],[[NSArray alloc] initWithObjects:@"106.28428514100",@"29.49944119270", nil],[[NSArray alloc] initWithObjects:@"106.28412503100",@"29.49886038950", nil],[[NSArray alloc] initWithObjects:@"106.28385592800",@"29.49829018370", nil],[[NSArray alloc] initWithObjects:@"106.28345288100",@"29.49748260270", nil],[[NSArray alloc] initWithObjects:@"106.28333666600",@"29.49692046740", nil],[[NSArray alloc] initWithObjects:@"106.28374515800",@"29.49642964210", nil],[[NSArray alloc] initWithObjects:@"106.28436614000",@"29.49634727270", nil],[[NSArray alloc] initWithObjects:@"106.28464074300",@"29.49643471820", nil],[[NSArray alloc] initWithObjects:@"106.28523031500",@"29.49667365630", nil],[[NSArray alloc] initWithObjects:@"106.28487671700",@"29.49621763690", nil],[[NSArray alloc] initWithObjects:@"106.28519893300",@"29.49580878840", nil],[[NSArray alloc] initWithObjects:@"106.28502076500",@"29.49547219770", nil],[[NSArray alloc] initWithObjects:@"106.28463092200",@"29.49511617180", nil],[[NSArray alloc] initWithObjects:@"106.28442743500",@"29.49466466790", nil],[[NSArray alloc] initWithObjects:@"106.28393904000",@"29.49433524770", nil],[[NSArray alloc] initWithObjects:@"106.28347920300",@"29.49410698470", nil],[[NSArray alloc] initWithObjects:@"106.28303960100",@"29.49386062470", nil],[[NSArray alloc] initWithObjects:@"106.28304341300",@"29.49362191950", nil],[[NSArray alloc] initWithObjects:@"106.28344771300",@"29.49377315350", nil],[[NSArray alloc] initWithObjects:@"106.28390799900",@"29.49403721200", nil],[[NSArray alloc] initWithObjects:@"106.28437224700",@"29.49407449730", nil],[[NSArray alloc] initWithObjects:@"106.28474343200",@"29.49430361350", nil],[[NSArray alloc] initWithObjects:@"106.28528766600",@"29.49473392400", nil],[[NSArray alloc] initWithObjects:@"106.28575176700",@"29.49475927170", nil],[[NSArray alloc] initWithObjects:@"106.28590620200",@"29.49456684430", nil],[[NSArray alloc] initWithObjects:@"106.28637218700",@"29.49474133920", nil],[[NSArray alloc] initWithObjects:@"106.28679169700",@"29.49474623120", nil],[[NSArray alloc] initWithObjects:@"106.28713493300",@"29.49492191100", nil],[[NSArray alloc] initWithObjects:@"106.28754787400",@"29.49521624910", nil],[[NSArray alloc] initWithObjects:@"106.28783806700",@"29.49551177450", nil],[[NSArray alloc] initWithObjects:@"106.28765346100",@"29.49601476450", nil],[[NSArray alloc] initWithObjects:@"106.28753674600",@"29.49649322970", nil],[[NSArray alloc] initWithObjects:@"106.28739290300",@"29.49698389150", nil],[[NSArray alloc] initWithObjects:@"106.28764595600",@"29.49757811170", nil],[[NSArray alloc] initWithObjects:@"106.28764595600",@"29.49757811170", nil],[[NSArray alloc] initWithObjects:@"106.28774747100",@"29.49805446480", nil],[[NSArray alloc] initWithObjects:@"106.28748026800",@"29.49849858730", nil],[[NSArray alloc] initWithObjects:@"106.28706106800",@"29.49878904670", nil],[[NSArray alloc] initWithObjects:@"106.28708669300",@"29.49908951960", nil],[[NSArray alloc] initWithObjects:@"106.28708249300",@"29.49940460210", nil],[[NSArray alloc] initWithObjects:@"106.28715895400",@"29.49962582310", nil],[[NSArray alloc] initWithObjects:@"106.28749331000",@"29.49952950580", nil],[[NSArray alloc] initWithObjects:@"106.28776464100",@"29.49962711890", nil],[[NSArray alloc] initWithObjects:@"106.28811817300",@"29.49975257630", nil],[[NSArray alloc] initWithObjects:@"106.28851208100",@"29.49983468050", nil],[[NSArray alloc] initWithObjects:@"106.28880642400",@"29.49981034770", nil],[[NSArray alloc] initWithObjects:@"106.28898782700",@"29.49991599020", nil],[[NSArray alloc] initWithObjects:@"106.28919341800",@"29.49999275800", nil],[[NSArray alloc] initWithObjects:@"106.28945475500",@"29.49994726420", nil],[[NSArray alloc] initWithObjects:@"106.28935974400",@"29.49955438310", nil],[[NSArray alloc] initWithObjects:@"106.28934330700",@"29.49890297940", nil],[[NSArray alloc] initWithObjects:@"106.28950854300",@"29.49837869560", nil],[[NSArray alloc] initWithObjects:@"106.28970705600",@"29.49789704800", nil],[[NSArray alloc] initWithObjects:@"106.28954503700",@"29.49738309680", nil],[[NSArray alloc] initWithObjects:@"106.28957033300",@"29.49679572900", nil],[[NSArray alloc] initWithObjects:@"106.28937730500",@"29.49641811810", nil],[[NSArray alloc] initWithObjects:@"106.28893177100",@"29.49613603600", nil],[[NSArray alloc] initWithObjects:@"106.28858405200",@"29.49646876650", nil],[[NSArray alloc] initWithObjects:@"106.28876291600",@"29.49583575710", nil],[[NSArray alloc] initWithObjects:@"106.28872224900",@"29.49564044330", nil],[[NSArray alloc] initWithObjects:@"106.28892156800",@"29.49543803110", nil],[[NSArray alloc] initWithObjects:@"106.28907106100",@"29.49517882050", nil],[[NSArray alloc] initWithObjects:@"106.28933596600",@"29.49498531850", nil],[[NSArray alloc] initWithObjects:@"106.28966094300",@"29.49479600710", nil],[[NSArray alloc] initWithObjects:@"106.28991711300",@"29.49477442910", nil],[[NSArray alloc] initWithObjects:@"106.28996330900",@"29.49454486040", nil],[[NSArray alloc] initWithObjects:@"106.29019105100",@"29.49443286370", nil],[[NSArray alloc] initWithObjects:@"106.29021488100",@"29.49416055080", nil],[[NSArray alloc] initWithObjects:@"106.29019607900",@"29.49396860560", nil],[[NSArray alloc] initWithObjects:@"106.29014123300",@"29.49351566890", nil],[[NSArray alloc] initWithObjects:@"106.29010754400",@"29.49301001960", nil],[[NSArray alloc] initWithObjects:@"106.29013344100",@"29.49247037930", nil],[[NSArray alloc] initWithObjects:@"106.29028439000",@"29.49189611230", nil],[[NSArray alloc] initWithObjects:@"106.29024015300",@"29.49141920520", nil],[[NSArray alloc] initWithObjects:@"106.28997727900",@"29.49091100500", nil],[[NSArray alloc] initWithObjects:@"106.28922862700",@"29.49081802320", nil],[[NSArray alloc] initWithObjects:@"106.28848871100",@"29.49055311100", nil],[[NSArray alloc] initWithObjects:@"106.28785230800",@"29.49070724860", nil],[[NSArray alloc] initWithObjects:@"106.28770454000",@"29.49077908700", nil],[[NSArray alloc] initWithObjects:@"106.28765432300",@"29.49101466120", nil],[[NSArray alloc] initWithObjects:@"106.28781599000",@"29.49117897050", nil],[[NSArray alloc] initWithObjects:@"106.28788270300",@"29.49138477240", nil],[[NSArray alloc] initWithObjects:@"106.28809042900",@"29.49141617380", nil],[[NSArray alloc] initWithObjects:@"106.28820666400",@"29.49165490970", nil],[[NSArray alloc] initWithObjects:@"106.28845417000",@"29.49170382630", nil],[[NSArray alloc] initWithObjects:@"106.28860999200",@"29.49183716430", nil],[[NSArray alloc] initWithObjects:@"106.28875287100",@"29.49202552090", nil],[[NSArray alloc] initWithObjects:@"106.28894758400",@"29.49199857340", nil],[[NSArray alloc] initWithObjects:@"106.28912059800",@"29.49214308110", nil],[[NSArray alloc] initWithObjects:@"106.28904754700",@"29.49240632370", nil],[[NSArray alloc] initWithObjects:@"106.28883259200",@"29.49266616860", nil],[[NSArray alloc] initWithObjects:@"106.28863909500",@"29.49289716430", nil],[[NSArray alloc] initWithObjects:@"106.28840946400",@"29.49329080480", nil],[[NSArray alloc] initWithObjects:@"106.28818401800",@"29.49358416320", nil],[[NSArray alloc] initWithObjects:@"106.28786844400",@"29.49365404680", nil],[[NSArray alloc] initWithObjects:@"106.28728579100",@"29.49374560770", nil],[[NSArray alloc] initWithObjects:@"106.28677309300",@"29.49376011540", nil],[[NSArray alloc] initWithObjects:@"106.28635259600",@"29.49373077010", nil],[[NSArray alloc] initWithObjects:@"106.28618725000",@"29.49370730840", nil],[[NSArray alloc] initWithObjects:@"106.28582411100",@"29.49346737860", nil],[[NSArray alloc] initWithObjects:@"106.28539605200",@"29.49327103450", nil],[[NSArray alloc] initWithObjects:@"106.28482096500",@"29.49309758990", nil],[[NSArray alloc] initWithObjects:@"106.28446791200",@"29.49300792000", nil],[[NSArray alloc] initWithObjects:@"106.28400065600",@"29.49294799090", nil],[[NSArray alloc] initWithObjects:@"106.28362242300",@"29.49280844110", nil],[[NSArray alloc] initWithObjects:@"106.28318781100",@"29.49274103450", nil],[[NSArray alloc] initWithObjects:@"106.28274564700",@"29.49272381900", nil],[[NSArray alloc] initWithObjects:@"106.28233303600",@"29.49285996000", nil], nil];
    
//    NSLog(@"simulationGPSData:%@ ,count:%lu",self.simulationGPSData[0][0],(unsigned long)[self.simulationGPSData count]);
    
    //
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBarBack.png"] style:UIBarButtonItemStyleDone target:self action:@selector(navBack)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor HexString:@"454545"];
    //init and alloc dbCon
    self.dbCon            = [[DBCon alloc] init];
    self.userData         = [[DataTable alloc] init];
    self.theThreeHolesInf = [[DataTable alloc] init];
    self.customFourNum    = [[DataTable alloc] init];
    self.allCartsData     = [[DataTable alloc] init];
    self.allCaddiesData   = [[DataTable alloc] init];
    //
    self.addCartsArray    = [[NSMutableArray alloc] init];
    self.addcaddiesArray  = [[NSMutableArray alloc] init];
    
    self.allCaddiesViewArray = [[NSMutableArray alloc] init];
    self.allCartsViewArray   = [[NSMutableArray alloc] init];
    //
    self.inputCaddyNum.delegate = self;
    self.inputCartNum.delegate  = self;
    
    //组建客户组，默认的客户人数(1人)以及球洞位置（十八洞）
    self.theSelectedCusCounts = OneCustomer;
    self.theSelectedHolePosition = AllHole;
    //
    self.oneCustomer.backgroundColor = [UIColor HexString:selectedColor];
    self.eighteen.backgroundColor   = [UIColor HexString:selectedColor];
    //登录人信息
    self.userData = [self.dbCon ExecDataTable:@"select *from tbl_logPerson"];
    self.allCartsData = [self.dbCon ExecDataTable:@"select *from tbl_cartInf"];
    self.allCaddiesData = [self.dbCon ExecDataTable:@"select *from tbl_caddyInf"];

    //code text,job text,name text,number text,sex text,caddyLogIn text
//    if([self.userData.Rows count])//如果有用户数据则对进行赋值，否则不做处理（处理会报错！）
//        self.theCaddy.text = [NSString stringWithFormat:@"%@  %@",self.userData.Rows[0][@"number"],self.userData.Rows[0][@"name"]];
    //
//    allowDownCourt = NO;
    //
//    CustomerGroupInfViewController *cusGroupVC = [[CustomerGroupInfViewController alloc] init];
//    cusGroupVC.delegate = self;
    //先把登录球童的添加上 self.userData tbl_logPerson(code text,job text,name text,number text,sex text,caddyLogIn text)
    NSString *logCaddyResult;
    logCaddyResult = [NSString stringWithFormat:@"%@ %@",self.userData.Rows[0][@"number"],self.userData.Rows[0][@"name"]];
    NSDictionary *logCaddy = [[NSDictionary alloc] initWithObjectsAndKeys:logCaddyResult,@"resultCaddy",self.userData.Rows[0][@"number"],@"cadnum", nil];
    [self.addcaddiesArray addObject:logCaddy];
    
    
    //
    self.holePosName = @"十八洞";
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //
    self.creatGrpTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DissMissKeyBoard:)];
    self.creatGrpTap.delegate = self;
    [self.createGrpScrollView setFrame:CGRectMake(self.createGrpScrollView.frame.origin.x, self.createGrpScrollView.frame.origin.y, ScreenWidth, ScreenHeight)];
    [self.createGrpScrollView addGestureRecognizer:self.creatGrpTap];
    //
    self.caddyIndex = 0;
    self.cartIndex  = 0;
    self._caddyOffset = 0;
    self._cartOffset  = 0;
    //
    [self displayCurrentCaddies];
    //
    self.stateIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 100, ScreenHeight/2 - 100, 200, 200)];
    self.stateIndicator.backgroundColor = [UIColor HexString:@"0a0a0a" andAlpha:0.2];
    self.stateIndicator.layer.cornerRadius = 20;
    [self.view addSubview:self.stateIndicator];
    self.stateIndicator.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //
    [self.stateIndicator stopAnimating];
    self.stateIndicator.hidden = YES;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //删除球童
    if (alertView.tag == 1){
        switch (buttonIndex) {
            case 0:
                
                break;
                
            case 1:
                [self.addcaddiesArray removeObjectAtIndex:self.deleteCaddyRow];
                //
//                [self.theSelectedView removeFromSuperview];
                self.inputCaddyNum.transform = CGAffineTransformMakeTranslation(-(self._caddyOffset), 0);
                self.addCaddyButton.transform = CGAffineTransformMakeTranslation(-(self._caddyOffset), 0);
                
                for (id eachCaddyView in self.allCaddiesViewArray) {
                    if ([eachCaddyView isKindOfClass:[UIView class]]) {
                        [eachCaddyView removeFromSuperview];
                    }
                }
                [self.allCaddiesViewArray removeAllObjects];
                
                self.caddyIndex = 0;
                self._caddyOffset = 0;
                
                [self displayCurrentCaddies];
                
                break;
                
            default:
                break;
        }
    }
    //删除球车
    if (alertView.tag == 2) {
        switch (buttonIndex) {
            case 0:
                
                break;
                
            case 1:
//                [self.theSelectedView removeFromSuperview];
                self.inputCartNum.transform = CGAffineTransformMakeTranslation(-(self._cartOffset), 0);
                self.addCartButton.transform = CGAffineTransformMakeTranslation(-(self._cartOffset), 0);
                
                for (id eachCartView in self.allCartsViewArray) {
                    if ([eachCartView isKindOfClass:[UIView class]]) {
                        [eachCartView removeFromSuperview];
                    }
                }
                [self.allCartsViewArray removeAllObjects];
                
                self.cartIndex = 0;
                self._cartOffset = 0;
                [self.addCartsArray removeObjectAtIndex:self.deleteCartRow];
                //
//                [self.cartScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [self displayCurrentCarts];
                
                break;
                
            default:
                break;
        }
    }
}

#pragma -mark DeleteTheSelectedCart
- (void)deleteCart:(UITapGestureRecognizer *)Tap
{
    NSInteger deleteRow;
    deleteRow = Tap.view.tag;
//    self.theSelectedView = Tap.view;
    self.deleteCartRow = deleteRow - 1;
    if (Tap.state == UIGestureRecognizerStateEnded) {
        if ([self.addCartsArray count] < Tap.view.tag) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"参数异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
        
        NSString *willDeleteDataDisStr = [NSString stringWithFormat:@"%@",self.addCartsArray[deleteRow - 1][@"resultCart"]];
        UIAlertView *cartAlert = [[UIAlertView alloc] initWithTitle:@"删除该球车" message:willDeleteDataDisStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        cartAlert.tag = 2;
        [cartAlert show];
    }
    
}

#pragma -mark DeleteTheSelectedCaddy
- (void)deleteCaddy:(UITapGestureRecognizer *)Tap
{
    NSInteger deleteRow;
    deleteRow = Tap.view.tag;
    
    self.deleteCaddyRow = deleteRow - 1;
    //
    if (Tap.state == UIGestureRecognizerStateEnded) {
        if ([self.addcaddiesArray count] < Tap.view.tag) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"参数异常" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
        //判断是否是登录球童
        if ([self.addcaddiesArray[deleteRow - 1][@"cadnum"] integerValue] == [self.userData.Rows[0][@"number"] integerValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录球童不可删除" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
        //
        NSString *willDeleteDataDisStr = [NSString stringWithFormat:@"%@",self.addcaddiesArray[deleteRow - 1][@"resultCaddy"]];
        UIAlertView *caddyAlert = [[UIAlertView alloc] initWithTitle:@"删除该球童" message:willDeleteDataDisStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        caddyAlert.tag = 1;
        [caddyAlert show];

    }
    
}

- (void)DissMissKeyBoard:(id)sender
{
    [self.inputCaddyNum resignFirstResponder];
    [self.inputCartNum resignFirstResponder];
}

#pragma -mark navBack
-(void)navBack
{
    NSLog(@"enter navBack");
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)settingTheColorOftheSelectedCusNumbers:(NSInteger)numbers
{
    switch (numbers) {
        case 0:
            self.oneCustomer.backgroundColor = [UIColor HexString:selectedColor];
            self.twoCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            self.threeCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            self.fourCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            break;
            
        case 1:
            self.oneCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            self.twoCustomer.backgroundColor = [UIColor HexString:selectedColor];
            self.threeCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            self.fourCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            break;
            
        case 2:
            self.oneCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            self.twoCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            self.threeCustomer.backgroundColor = [UIColor HexString:selectedColor];
            self.fourCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            break;
            
        case 3:
            self.oneCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            self.twoCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            self.threeCustomer.backgroundColor = [UIColor HexString:unselectedColor];
            self.fourCustomer.backgroundColor = [UIColor HexString:selectedColor];
            break;
        default:
            break;
    }
    self.theSelectedCusCounts = (cusNumbers)numbers;
    //
#ifdef DEBUG_MODE
    NSLog(@"cusCounts:%ld",(long)self.theSelectedCusCounts);
#endif
}
#pragma -mark DisableHeartBeat
-(void)DisableHeartBeat
{
    [self.heartBeatTime invalidate];
}

- (IBAction)confirmCustomNumbers:(UIButton *)sender {
    [self settingTheColorOftheSelectedCusNumbers:(NSInteger)sender.tag];
}

- (IBAction)handleHoles:(UIButton *)sender {
    [self changeSelectedHoleColor:(NSInteger)sender.tag];
    //
    self.holePosName = sender.titleLabel.text;
}

//
-(NSString *)constructCustomers:(cusNumbers)cusNum andAllCustomers:(DataTable *)allCusData
{
    NSString *customers = [[NSString alloc] init];
#ifdef DEBUG_MODE
    NSLog(@"%@",customers);
#endif
    //
    switch (cusNum) {
        case 0:
            customers = [NSString stringWithFormat:@"%@",allCusData.Rows[0][@"first"]];
            break;
            
        case 1:
            customers = [NSString stringWithFormat:@"%@_%@",allCusData.Rows[0][@"first"],allCusData.Rows[0][@"second"]];
            break;
        case 2:
            customers = [NSString stringWithFormat:@"%@_%@_%@",allCusData.Rows[0][@"first"],allCusData.Rows[0][@"second"],allCusData.Rows[0][@"third"]];
            break;
        case 3:
            customers = [NSString stringWithFormat:@"%@_%@_%@_%@",allCusData.Rows[0][@"first"],allCusData.Rows[0][@"second"],allCusData.Rows[0][@"third"],allCusData.Rows[0][@"fourth"]];
            break;
        default:
            break;
    }
//    NSLog(@"customers:%@",customers);
    
    return customers;
}
#pragma -mark DownCourt
-(void)DownCourt
{
//    NSLog(@"create group and down Court");
    //删除旧数据，所创建的组信息，以及返回的平板的数据
    //建组数据
    [self.dbCon ExecNonQuery:@"delete from tbl_groupInf"];
    //返回的平板信息删除
    [self.dbCon ExecNonQuery:@"delete from tbl_PadsInf"];
    
    
    //为了方便测试，正式的程序注释掉
    //[self performSegueWithIdentifier:@"toWaitInterface" sender:nil];
    
    
    //从数据库中读取参数
    //登录人信息
    //self.userData = [self.dbCon ExecDataTable:@"select *from tbl_logPerson"];
    //三个类型的球洞信息读取
    self.theThreeHolesInf = [self.dbCon ExecDataTable:@"select *from tbl_threeTypeHoleInf"];
    //获取得到的四个用户卡号
    self.customFourNum = [self.dbCon ExecDataTable:@"select *from tbl_CustomerNumbers"];
    //组建客户卡号
    NSString *selectedCus = [[NSString alloc] init];
#ifdef DEBUG_MODE
    NSLog(@"cusCount:%ld;cusFourNum:%@",(long)self.theSelectedCusCounts,self.customFourNum);
#endif
    if(![self.customFourNum.Rows count])
    {
        UIAlertView *cusNumbers = [[UIAlertView alloc] initWithTitle:@"没有可用的消费卡号" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [cusNumbers show];
        return;
    }
    selectedCus = [self constructCustomers:self.theSelectedCusCounts andAllCustomers:self.customFourNum];
#ifdef DEBUG_MODE
    NSLog(@"selectedCUS:%@",selectedCus);
#endif
    
    if([self.userData.Rows count] == 0)
    {
        UIAlertView *userDataAlert = [[UIAlertView alloc] initWithTitle:@"球员数据为空" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [userDataAlert show];
        return;
    }
    //获取到添加的球车，球童号
    NSString *allAddCaddies;
    NSString *allAddCarts;
    //获取到所有的球童号，并且组装起来，多个球童之间用"_"分开
    for (unsigned char i = 0; i < [self.addcaddiesArray count]; i++) {
        if (i == 0) {
            allAddCaddies = [NSString stringWithFormat:@"%@",self.addcaddiesArray[i][@"cadnum"]];
        }
        else
        {
            allAddCaddies = [allAddCaddies stringByAppendingString:[NSString stringWithFormat:@"_%@",self.addcaddiesArray[i][@"cadnum"]]];
        }
    }
    //获取到所有的球车号，并且组装起来，多个球车之间用"_"分开
    for (unsigned char j = 0; j < [self.addCartsArray count]; j++) {
        if (j == 0) {
            allAddCarts = [NSString stringWithFormat:@"%@",self.addCartsArray[j][@"carnum"]];
        }
        else
        {
            allAddCarts = [allAddCarts stringByAppendingString:[NSString stringWithFormat:@"_%@",self.addCartsArray[j][@"carnum"]]];
        }
    }
    if (![self.addCartsArray count]) {
        allAddCarts = @"";
    }
    //获取到mid号码
    NSString *theMid;
    theMid = [GetRequestIPAddress getUniqueID];
    theMid = [NSString stringWithFormat:@"I_IMEI_%@",theMid];
    //
    NSMutableDictionary *createGroupParameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:theMid,@"mid",@"",@"gronum",selectedCus,@"cus",allAddCarts,@"car",self.theThreeHolesInf.Rows[self.theSelectedHolePosition][@"pdtag"],@"hole",allAddCaddies,@"cad",self.userData.Rows[0][@"caddyLogIn"],@"cadShow",self.userData.Rows[0][@"code"],@"user", nil];
    //
    __weak typeof(self) weakself = self;
    //
    NSString *createGrpURLStr;
    createGrpURLStr = [GetRequestIPAddress getcreateGroupURL];
    //
    [self.stateIndicator startAnimating];
    self.stateIndicator.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        [HttpTools getHttp:createGrpURLStr forParams:createGroupParameters success:^(NSData *nsData){
            CreateGroupViewController *strongself = weakself;
            
//            NSDictionary *receiveCreateGroupDic     = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *receiveCreateGroupDic;// = [NSJSONSerialization JSONObjectWithData:nsData options:NSJSONReadingMutableLeaves error:nil];
            receiveCreateGroupDic = (NSDictionary *)nsData;
            if([receiveCreateGroupDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-1]])
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",receiveCreateGroupDic[@"Msg"]];
                UIAlertView *programErrAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [programErrAlert show];
                //            [UIView beginAnimations:nil context:nil]; // 开始动画
                //            [UIView setAnimationDuration:10.0]; // 动画时长
                //
                //            UIView *view111 = [[UIView alloc] initWithFrame:CGRectMake(weakself.view.frame.size.width/2 - 10, self.view.frame.size.height/2 - 10, 20, 20)];
                //            view111.backgroundColor = [UIColor blackColor];
                //            [weakself.view addSubview:view111];
                //
                //            CGPoint point = view111.center;
                //            point.x -= 150;
                //            [view111 setCenter:point];
                //
                //            [UIView commitAnimations]; // 提交动画
                
                
                NSLog(@"程序异常");
            }
            else if([receiveCreateGroupDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:0]])
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",receiveCreateGroupDic[@"Msg"]];
                UIAlertView *createGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [createGrpFailAlert show];
                NSLog(@"建组失败");
            }
            else if([receiveCreateGroupDic[@"Code"] isEqualToNumber:[NSNumber numberWithInt:-3]])
            {
                NSString *errStr;
                errStr = [NSString stringWithFormat:@"%@",receiveCreateGroupDic[@"Msg"]];
                UIAlertView *hasGrpFailAlert = [[UIAlertView alloc] initWithTitle:errStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [hasGrpFailAlert show];
                NSLog(@"已有球组，建组失败");
            }
            else
            {
                [self.dbCon ExecDataTable:@"delete from tbl_CustomersInfo"];
                [self.dbCon ExecDataTable:@"delete from tbl_selectCart"];
                [self.dbCon ExecDataTable:@"delete from tbl_addCaddy"];
                //tbl_addCaddy
#ifdef DEBUG_MODE
                NSLog(@"grpcod:%@  ;groind:%@  ;grolev:%@  ;gronum:%@  ;grosta:%@",receiveCreateGroupDic[@"Msg"][@"grocod"],receiveCreateGroupDic[@"Msg"][@"groind"],receiveCreateGroupDic[@"Msg"][@"grolev"],receiveCreateGroupDic[@"Msg"][@"gronum"],receiveCreateGroupDic[@"Msg"][@"grosta"]);
#endif
                //组建获取到的组信息的数组
                NSMutableArray *groupInfArray = [[NSMutableArray alloc] initWithObjects:receiveCreateGroupDic[@"Msg"][@"grocod"],receiveCreateGroupDic[@"Msg"][@"groind"],receiveCreateGroupDic[@"Msg"][@"grolev"],receiveCreateGroupDic[@"Msg"][@"gronum"],receiveCreateGroupDic[@"Msg"][@"grosta"],receiveCreateGroupDic[@"Msg"][@"hgcod"],receiveCreateGroupDic[@"Msg"][@"onlinestatus"],receiveCreateGroupDic[@"Msg"][@"createdate"],receiveCreateGroupDic[@"Msg"][@"timestamps"], nil];
                //将数据加载到创建的数据库中
                //grocod text,groind text,grolev text,gronum text,grosta text,hgcod text,onlinestatus text
                
                [self.dbCon ExecNonQuery:@"insert into tbl_groupInf(grocod,groind,grolev,gronum,grosta,hgcod,onlinestatus,createdate,timestamps)values(?,?,?,?,?,?,?,?,?)" forParameter:groupInfArray];
#ifdef DEBUG_MODE
                NSLog(@"successfully create group and the recDic:%@  code:%@",receiveCreateGroupDic[@"Msg"],receiveCreateGroupDic[@"code"]);
#endif
                //获取到登录小组的所有客户的信息
                NSArray *allCustomers = receiveCreateGroupDic[@"Msg"][@"cuss"];
                for (NSDictionary *eachCus in allCustomers) {
                    NSMutableArray *eachCusParam = [[NSMutableArray alloc] initWithObjects:eachCus[@"bansta"],eachCus[@"bantim"],eachCus[@"cadcod"],eachCus[@"carcod"],eachCus[@"cuscod"],eachCus[@"cuslev"],eachCus[@"cusnam"],eachCus[@"cusnum"],eachCus[@"cussex"],eachCus[@"depsta"],eachCus[@"endtim"],eachCus[@"grocod"],eachCus[@"memnum"],eachCus[@"padcod"],eachCus[@"phone"],eachCus[@"statim"], nil];
                    [strongself.dbCon ExecNonQuery:@"insert into tbl_CustomersInfo(bansta,bantim,cadcod,carcod,cuscod,cuslev,cusnam,cusnum,cussex,depsta,endtim,grocod,memnum,padcod,phone,statim) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" forParameter:eachCusParam];
                }
                //保存添加的球车的信息 tbl_selectCart(carcod text,carnum text,carsea text)
                NSArray *allSelectedCartsArray = receiveCreateGroupDic[@"Msg"][@"cars"];
                for (NSDictionary *eachCart in allSelectedCartsArray) {
                    NSMutableArray *selectedCart = [[NSMutableArray alloc] initWithObjects:eachCart[@"carcod"],eachCart[@"carnum"],eachCart[@"carsea"], nil];
                    [strongself.dbCon ExecNonQuery:@"insert into tbl_selectCart(carcod,carnum,carsea) values(?,?,?)" forParameter:selectedCart];
                }
                //保存添加的球童的信息 tbl_addCaddy(cadcod text,cadnam text,cadnum text,cadsex text,empcod text)
                NSArray *allSelectedCaddiesArray = receiveCreateGroupDic[@"Msg"][@"cads"];
                for (NSDictionary *eachCaddy in allSelectedCaddiesArray) {
                    NSMutableArray *selectedCaddy = [[NSMutableArray alloc] initWithObjects:eachCaddy[@"cadcod"],eachCaddy[@"cadnam"],eachCaddy[@"cadnum"],eachCaddy[@"cadsex"],eachCaddy[@"empcod"], nil];
                    [strongself.dbCon ExecNonQuery:@"insert into tbl_addCaddy(cadcod,cadnam,cadnum,cadsex,empcod) values(?,?,?,?,?)" forParameter:selectedCaddy];
                }
                
//                ucCusCounts = (unsigned char)self.theSelectedCusCounts;
//                ucHolePosition = (unsigned char)self.theSelectedHolePosition;
                
                if ([self.cusAndHoleDelegate respondsToSelector:@selector(getCustomerCounts:andHolePosition:)]) {
                    [self.cusAndHoleDelegate getCustomerCounts:self.theSelectedCusCounts andHolePosition:self.theSelectedHolePosition];
                }
                //
                dispatch_async(dispatch_get_main_queue(), ^{
                    //跳转页面
                    [strongself performSegueWithIdentifier:@"toWaitInterface" sender:nil];
                    //建组成功之后，进入心跳处理类中，开始心跳功能
                    HeartBeatAndDetectState *heartBeat = [[HeartBeatAndDetectState alloc] init];
                    if (![heartBeat checkState]) {
                        [heartBeat initHeartBeat];//1、心跳功能
                        [heartBeat enableHeartBeat];//2、开启
                    }
                });
                
            }
            
        }failure:^(NSError *err){
            NSLog(@"create group fail");
            
        }];
    });
    
}
//
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WaitToPlayTableViewController *waitPlay = segue.destinationViewController;
    waitPlay.holeType = self.holePosName;
    waitPlay.customerCounts = self.theSelectedCusCounts;
}

//
- (IBAction)createGroupAndDownCourt:(UIButton *)sender {
    //
    if ([self.inputCartNum.text boolValue]) {//有输入才判断
        if (![self whetherCanAddCart]) {
            return;
        }
        //
        [self displayCurrentCarts];
    }
    //
    if ([self.inputCaddyNum.text boolValue]) {//有输入才判断
        if (![self whetherCanAddCaddy]) {
            return;
        }
        //
        [self displayCurrentCaddies];
    }
    
#ifdef testChangeInterface
    [self performSegueWithIdentifier:@"toWaitInterface" sender:nil];
#else
    [self DownCourt];
#endif
}

- (IBAction)backToCreateWay:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [HeartBeatAndDetectState disableHeartBeat];
}
//#pragma -mark 
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
//{
//    self.getGPSLocation = [locations lastObject];
//}

//change the backgroundcolor of the selected holes
-(void)changeSelectedHoleColor:(NSInteger)holeNum
{
    switch (holeNum) {
        case 0://上九洞
            self.theTop9.backgroundColor = [UIColor HexString:selectedColor];
            self.theDown9.backgroundColor = [UIColor HexString:unselectedColor];
            self.eighteen.backgroundColor = [UIColor HexString:unselectedColor];
            break;
            
        case 1://下九洞
            self.theTop9.backgroundColor = [UIColor HexString:unselectedColor];
            self.theDown9.backgroundColor = [UIColor HexString:selectedColor];
            self.eighteen.backgroundColor = [UIColor HexString:unselectedColor];
            break;
            
        case 2://十八洞
            self.theTop9.backgroundColor = [UIColor HexString:unselectedColor];
            self.theDown9.backgroundColor = [UIColor HexString:unselectedColor];
            self.eighteen.backgroundColor = [UIColor HexString:selectedColor];
            break;
        default:
            break;
    }
    self.theSelectedHolePosition = (holePosition)holeNum;
#ifdef DEBUG_MODE
    NSLog(@"position:%ld",(long)self.theSelectedHolePosition);
#endif
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    [self.heartBeatTime invalidate];
}

/**
 *  键盘发生改变执行
 */
//- (void)keyboardWillChange:(NSNotification *)note
//{
////    NSLog(@"%@", note.userInfo);
//    NSDictionary *userInfo = note.userInfo;
//    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
//    
//    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
//    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height;
//    
//    
//    [UIView animateWithDuration:duration animations:^{
//        self.createGrpScrollView.transform = CGAffineTransformMakeTranslation(0, moveY);
//    }];
//}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    
    int _offset = frame.origin.y + 230 - (self.view.frame.size.height - 216.0);//iPhone键盘高度216，iPad的为352
    NSLog(@"_offset:%d",_offset);
    
    if (_offset <= 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = _offset;
            self.view.frame = frame;
        }];
        
    }
    
    
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0;
        self.view.frame = frame;
    }];
    
    return YES;
}








- (BOOL)whetherCanAddCaddy
{
    BOOL canAdd;
    canAdd = YES;
    //
    if (![self.inputCaddyNum.text boolValue] ) {
        self.inputCaddyNum.text = @"";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入要添加的球童编号" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        canAdd = NO;
    }
    //
    if ([self.addcaddiesArray count] > 3) {//最多只能添加四个球车
        self.inputCaddyNum.text = @"";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"最多只能添加4个球童" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        canAdd = NO;
    }
    
    //
    BOOL hasTheData;
    hasTheData = NO;
    NSString *theInputCaddyNum = self.inputCaddyNum.text;//[self.inputCaddyNum.text integerValue];
    NSString *theResultCaddy;
    //
    for (NSDictionary *eachResult in self.addcaddiesArray) {
        self.inputCaddyNum.text = @"";
        //
        if ([eachResult[@"cadnum"] isEqualToString:theInputCaddyNum]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该组中已有该球童" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            canAdd = NO;
        }
    }
    //
    for (NSDictionary *eachCaddy in self.allCaddiesData.Rows) {
        if ([eachCaddy[@"cadnum"] isEqualToString:theInputCaddyNum]) {
            hasTheData = YES;
            theResultCaddy = [NSString stringWithFormat:@"%@ %@",eachCaddy[@"cadnum"],eachCaddy[@"cadnam"]];
            NSDictionary *eachCaddyInfo = [[NSDictionary alloc] initWithObjectsAndKeys:theResultCaddy,@"resultCaddy",eachCaddy[@"cadnum"],@"cadnum", nil];
            [self.addcaddiesArray addObject:eachCaddyInfo];
            break;
        }
    }
    NSString *displayErr;
    displayErr = [NSString stringWithFormat:@"系统中没有%@球童或者此球童不是可用状态",theInputCaddyNum];
    if (!hasTheData) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:displayErr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        canAdd = NO;
    }
    
    return canAdd;
}

#pragma -mark addCaddy and addCart

- (void)addCaddies
{
    if (![self whetherCanAddCaddy]) {
        return;
    }
    //
    [self displayCurrentCaddies];
}

- (IBAction)addCaddy:(UIButton *)sender {
    [self addCaddies];
}
//
- (void)displayCurrentCaddies
{
    //进入之后，将偏移量清零
    self._caddyOffset = 0;
    //首先清除掉所有之前的球车视图
    for (id eachCaddy in self.allCaddiesViewArray) {
        if ([eachCaddy isKindOfClass:[UIView class]]) {
            [eachCaddy removeFromSuperview];
        }
    }
    //之后将目前数组中的所有球童给显示出来
    for (NSInteger i = 0; i < [self.addcaddiesArray count]; i++) {
        self.caddyIndex = i;
        //
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(self._caddyOffset, self.inputCaddyNum.frame.origin.y, self.subDetailView.frame.size.width, self.subDetailView.frame.size.height)];
        UILabel *detailInf = [[UILabel alloc] initWithFrame:CGRectMake(5, self.detailLabel.frame.origin.y, self.detailLabel.frame.size.width, self.detailLabel.frame.size.height)];
        detailInf.text = self.addcaddiesArray[self.caddyIndex][@"resultCaddy"];
        
        detailInf.textAlignment = NSTextAlignmentCenter;
        detailInf.font = [UIFont systemFontOfSize:15];
        [subView addSubview:detailInf];
        
        subView.backgroundColor = [UIColor HexString:@"eeeeee"];
        subView.layer.cornerRadius = 6.0;
        //
        [self.allCaddiesViewArray addObject:subView];
        //
        [self.caddyScrollView addSubview:subView];
        //    _offset += offset;
        self._caddyOffset += offset;
        //
        subView.tag = (int)self.caddyIndex + 1;
        self.caddyIndex++;
        if (self.caddyIndex == 1) {
            UITapGestureRecognizer *view1Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCaddy:)];
//            view1Gesture.minimumPressDuration = 0.5;
            [subView addGestureRecognizer:view1Gesture];
        }
        else if (self.caddyIndex == 2)
        {
            UITapGestureRecognizer *view2Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCaddy:)];
//            view2Gesture.minimumPressDuration = 0.5;
            [subView addGestureRecognizer:view2Gesture];
        }
        else if (self.caddyIndex == 3)
        {
            UITapGestureRecognizer *view3Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCaddy:)];
//            view3Gesture.minimumPressDuration = 0.5;
            [subView addGestureRecognizer:view3Gesture];
        }
        else if (self.caddyIndex == 4)
        {
            UITapGestureRecognizer *view4Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCaddy:)];
//            view4Gesture.minimumPressDuration = 0.5;
            [subView addGestureRecognizer:view4Gesture];
        }
    }
    
    //
    self.inputCaddyNum.transform = CGAffineTransformMakeTranslation(self._caddyOffset, 0);
    self.addCaddyButton.transform = CGAffineTransformMakeTranslation(self._caddyOffset, 0);
    [self.caddyScrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, self._caddyOffset)];
    self.inputCaddyNum.text = @"";
}


- (BOOL)whetherCanAddCart
{
    BOOL canAdd;
    canAdd = YES;
    //
#ifdef DEBUG_MODE
    NSLog(@"inputCart:%@",self.inputCartNum.text);
#endif
    if (![self.inputCartNum.text boolValue] ) {
        self.inputCartNum.text = @"";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入要添加的球车编号" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        canAdd = NO;
    }
    //
    if ([self.addCartsArray count] > 3) {//最多只能添加四个球车
        self.inputCartNum.text = @"";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"最多只能添加4个球车" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        canAdd = NO;
    }
    //
    BOOL hasTheData;
    hasTheData = NO;
    NSString *theInputCartNum = self.inputCartNum.text;
    NSString *theResultCart;
    //
    for (NSDictionary *eachResult in self.addCartsArray) {
        self.inputCartNum.text = @"";
        //
        if ([eachResult[@"carnum"] isEqualToString:theInputCartNum]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该组中已有该球车" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            canAdd = NO;
        }
    }
    //
    for (NSDictionary *eachCart in self.allCartsData.Rows) {
        if ([eachCart[@"carnum"] isEqualToString:theInputCartNum]) {
            hasTheData = YES;
            theResultCart = [NSString stringWithFormat:@"%@   %@座",eachCart[@"carnum"],eachCart[@"carsea"]];
            NSDictionary *eachCartInfo = [[NSDictionary alloc] initWithObjectsAndKeys:theResultCart,@"resultCart",eachCart[@"carnum"],@"carnum", nil];
            [self.addCartsArray addObject:eachCartInfo];
            break;
        }
    }
    NSString *displayCartErr;
    displayCartErr = [NSString stringWithFormat:@"系统中没有%@球车或者此球车不是可用状态",theInputCartNum];
    if (!hasTheData) {
        self.inputCartNum.text = @"";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:displayCartErr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        canAdd = NO;
    }
    
    return canAdd;
}

#pragma -mark add and display current carts

- (void)addCarts
{
    if (![self whetherCanAddCart]) {
        return;
    }
    //
    [self displayCurrentCarts];
}

- (IBAction)addCart:(UIButton *)sender {
    [self addCarts];
}
//
- (void)displayCurrentCarts
{
    //进入之后，将偏移量清零
    self._cartOffset = 0;
    //首先清除掉所有之前的球车视图
    for (id eachCart in self.allCartsViewArray) {
        if ([eachCart isKindOfClass:[UIView class]]) {
            [eachCart removeFromSuperview];
        }
    }
    //之后将目前数组中的所有球车给显示出来
    for (NSInteger i = 0; i < [self.addCartsArray count]; i++) {
        self.cartIndex = i;
        //
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(self._cartOffset, self.inputCaddyNum.frame.origin.y, self.subDetailView.frame.size.width, self.subDetailView.frame.size.height)];
        UILabel *detailInf = [[UILabel alloc] initWithFrame:CGRectMake(5, self.detailLabel.frame.origin.y, self.detailLabel.frame.size.width, self.detailLabel.frame.size.height)];
        detailInf.text = self.addCartsArray[self.cartIndex][@"resultCart"];
        
        detailInf.textAlignment = NSTextAlignmentCenter;
        detailInf.font = [UIFont systemFontOfSize:15];
        [subView addSubview:detailInf];
        
        subView.backgroundColor = [UIColor HexString:@"eeeeee"];
        subView.layer.cornerRadius = 6.0;
        //
        [self.allCartsViewArray addObject:subView];
        //
        [self.cartScrollView addSubview:subView];
        self._cartOffset += offset;
        //
        subView.tag = (int)self.cartIndex + 1;
        self.cartIndex++;
        if (self.cartIndex == 1) {
            UITapGestureRecognizer *view1Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCart:)];
//            view1Gesture.minimumPressDuration = 0.5;
            [subView addGestureRecognizer:view1Gesture];
        }
        else if (self.cartIndex == 2)
        {
            UITapGestureRecognizer *view2Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCart:)];
//            view2Gesture.minimumPressDuration = 0.5;
            [subView addGestureRecognizer:view2Gesture];
        }
        else if (self.cartIndex == 3)
        {
            UITapGestureRecognizer *view3Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCart:)];
//            view3Gesture.minimumPressDuration = 0.5;
            [subView addGestureRecognizer:view3Gesture];
        }
        else if (self.cartIndex == 4)
        {
            UITapGestureRecognizer *view4Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCart:)];
//            view4Gesture.minimumPressDuration = 0.5;
            [subView addGestureRecognizer:view4Gesture];
        }
    }
    
    
    
    self.inputCartNum.transform = CGAffineTransformMakeTranslation(self._cartOffset, 0);
    self.addCartButton.transform = CGAffineTransformMakeTranslation(self._cartOffset, 0);
    [self.cartScrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, self._cartOffset)];
    self.inputCartNum.text = @"";
}

@end
