//
//  ViewController.m
//  CMPopTip
//
//  Created by 宓珂璟 on 16/6/22.
//  Copyright © 2016年 宓珂璟. All rights reserved.
//

#import "ViewController.h"
#import <CMPopTipView.h>
#import "MKJAFNetWorkHelp.h"
#import "MKJCollectionViewCell.h"
#import <UIImageView+WebCache.h>
#import "MKJModel.h"

@interface ViewController () <CMPopTipViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) CMPopTipView *roundRectButtonPopTipView;

@property (nonatomic,strong) NSMutableArray       *dataSource; //!< collectionView的数据源
@property (nonatomic,strong) GroupList            *list;       //!< 请求回来的数据
@property (nonatomic,strong) UICollectionView     *collectionView;
@property (nonatomic,strong) UIImageView          *imageView;
@property (nonatomic,strong) UIImageView          *imageView1;
@property (weak,  nonatomic) IBOutlet UILabel     *middleLabel;
@property (nonatomic,strong) NSMutableArray	      *visiblePopTipViews; //!< 可见的PopView
@property (nonatomic,strong) id				      currentPopTipViewTarget;  //!< 当前的按钮
@property (nonatomic,strong) UITableView          *tableView;
@property (nonatomic,strong) NSMutableArray       *tableDataSource;
@property (nonatomic,strong) UIButton             *gotoCartButton; // NVBar的按钮

@end


static NSString *identyfy = @"MKJCollectionViewCell";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initCollectioView];
    [self initTableView];
    [self initImage];
    [self initData];
    
    // 以下是一个小的简单富文本
    self.visiblePopTipViews = [NSMutableArray new];
    NSMutableAttributedString *mutableStr = [[NSMutableAttributedString alloc] init];
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@"It" attributes:@{NSFontAttributeName :[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName :[UIColor whiteColor],NSBackgroundColorAttributeName :[UIColor blackColor]}];
    NSAttributedString *str3 = [[NSAttributedString alloc] initWithString:@"   is  " attributes:@{NSFontAttributeName :[UIFont boldSystemFontOfSize:22],NSForegroundColorAttributeName :[UIColor blackColor]}];
    NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@"Amazing!!!" attributes:@{NSFontAttributeName :[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:[UIColor redColor],NSBackgroundColorAttributeName :[UIColor colorWithRed:255/255.0 green:194/255.0 blue:1/255.0 alpha:1]}];

    [mutableStr appendAttributedString:str1];
    [mutableStr appendAttributedString:str3];
    [mutableStr appendAttributedString:str2];
    self.middleLabel.attributedText = mutableStr;
    
    // 右上角按钮安装
    self.gotoCartButton = [[UIButton alloc] init];
    [self.gotoCartButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.gotoCartButton setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.gotoCartButton setTitle:@"点我" forState:UIControlStateNormal];
    [self.gotoCartButton sizeToFit];
    self.gotoCartButton.frame = CGRectMake(0, 0, 44, 44);
    [self.gotoCartButton addTarget:self action:@selector(gotoCart:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:self.gotoCartButton];
    self.navigationItem.rightBarButtonItem = item2;
}

// 点击了NavigationController上的按钮
- (void)gotoCart:(UIButton *)sender
{
    [self dismissAllPopTipViews];
    if (sender == self.currentPopTipViewTarget) {
        self.currentPopTipViewTarget = nil;
    }
    else
    {
        CGFloat height;
        [self.tableView reloadData];
        height  = self.tableView.contentSize.height;
        self.tableView.frame = CGRectMake(0, 0, 100, height);
        self.tableView.backgroundColor = [UIColor blackColor];
        self.tableView.alwaysBounceVertical = YES;
        CMPopTipView *popView = [[CMPopTipView alloc] initWithCustomView:self.tableView];
        popView.delegate = self;
        popView.cornerRadius = 5;
        popView.backgroundColor = [UIColor blackColor];
        popView.textColor = [UIColor whiteColor];
        // 0是Slide  1是pop  2是Fade但是有问题，用前两个就好了
        popView.animation = arc4random() % 1;
        // 立体效果，默认是YES
        popView.has3DStyle = arc4random() % 1;
        //        popView.dismissTapAnywhere = YES;
        //        [popView autoDismissAnimated:YES atTimeInterval:5.0];
        
        [popView presentPointingAtView:sender inView:self.view animated:YES];
        
        // 如果是原生的UIBarButtonItem，那么就调用这个方法
//        popView presentPointingAtBarButtonItem:<#(UIBarButtonItem *)#> animated:<#(BOOL)#>
        [self.visiblePopTipViews addObject:popView];
        self.currentPopTipViewTarget = sender;
    }
}


- (void)initImage
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"5ACD385229C987206C40B34FDF6204DE.jpg"];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageView.clipsToBounds = YES;
    
    self.imageView1 = [[UIImageView alloc] init];
    self.imageView1.image = [UIImage imageNamed:@"C72BF07FA6F73B54D98E0678B5F1AFFB.jpg"];
    self.imageView1.contentMode = UIViewContentModeScaleToFill;
    self.imageView1.clipsToBounds = YES;
}

// 请求网络数据
- (void)initData
{
    [[MKJAFNetWorkHelp shareRequest] MKJGETRequest:@"http://cgi.taowaitao.cn/index/discovery/groups" page:0 parameters:nil succeed:^(NSError *err, id obj) {
        
        GroupList *list = (GroupList *)obj;
        self.list = list;
        self.dataSource = [[NSMutableArray alloc] initWithArray:list.data.role];
        [self.collectionView reloadData];
        
    } failure:^(NSError *err, id obj) {
        // failed
    }];
}

// 初始化CollectionView
- (void)initCollectioView
{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.minimumLineSpacing = 20;
    flow.minimumInteritemSpacing = 10;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 300, 300) collectionViewLayout:flow];
    [self.collectionView registerNib:[UINib nibWithNibName:identyfy bundle:nil] forCellWithReuseIdentifier:identyfy];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

// 初始化tableView
- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 160) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableViewCell"];
}

#pragma mark - uitableViewDeleagete
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.tableDataSource[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

#pragma mark - collectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DetailList *list = self.dataSource[indexPath.item];
    MKJCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identyfy forIndexPath:indexPath];
    cell.titleLable.text = list.group;
    __weak typeof(cell)weakCell = cell;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:list.pic] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
       
        if (image && cacheType == SDImageCacheTypeNone) {
            weakCell.imageView.alpha = 0;
            [UIView animateWithDuration:1.0 animations:^{
               
                weakCell.imageView.alpha = 1.0f;
                
            }];
        }
        else
        {
            weakCell.imageView.alpha = 1.0f;
        }
        
    }];
    return cell;
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 90);
}


- (IBAction)click:(UIButton *)sender
{
    // 先dismiss之前的所有popView
    [self dismissAllPopTipViews];
    // 当检测到是和之前一样的按钮，由于已经清空，那么不进行任何操作，也把容器清空，下次再点就可以下一波操作了
    if (sender == self.currentPopTipViewTarget) {
        self.currentPopTipViewTarget = nil;
    }
    else
    {
        // 没有pop的时候，先计算出collectionView的高度
        CGFloat height;
        if (sender.tag == 1000) {
            self.dataSource = [[NSMutableArray alloc] initWithArray:self.list.data.role];
            [self.collectionView reloadData];
            
        }
        else if (sender.tag == 1003)
        {
            self.dataSource = [[NSMutableArray alloc] initWithArray:self.list.data.list];
            [self.collectionView reloadData];
            
        }
        // 算高度
        height  = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
        
        
        
        NSString *title = nil;
        NSString *msg = nil;
        CMPopTipView *popView;
        switch (sender.tag) {
            case 1000:
                self.collectionView.frame = CGRectMake(0, 0, 300, height);
                self.collectionView.alwaysBounceVertical = YES;
                // 加载自定义View
                popView = [[CMPopTipView alloc] initWithCustomView:self.collectionView];
                break;
            case 1001:
                msg = @"这是一个简单的Demo，希望大家看明白，能用在自己的项目中";
                title = @"博主是逗逼";
                // 加载title和Msg的混合
                popView = [[CMPopTipView alloc] initWithTitle:title message:msg];
                break;
            case 1002:
                self.imageView.frame = CGRectMake(0, 0, 350, 300);
                popView = [[CMPopTipView alloc] initWithCustomView:self.imageView];
                break;
            case 1003:
                self.collectionView.frame = CGRectMake(0, 0, 300, height>400?400:height);
                self.collectionView.alwaysBounceVertical = YES;
                popView = [[CMPopTipView alloc] initWithCustomView:self.collectionView];
                break;
            case 1004:
                msg = @"With groups, Xcode stores in the project a reference to each individual file.";
                title = @"博主我爱你";
                popView = [[CMPopTipView alloc] initWithTitle:title message:msg];
                break;
            case 1005:
                self.imageView1.frame = CGRectMake(0, 0, 350, 300);
                popView = [[CMPopTipView alloc] initWithCustomView:self.imageView1];
                break;
                
            default:
                break;
        }
        popView.delegate = self;
        popView.cornerRadius = 5;
        // 是否有阴影
        //popView.hasShadow = YES;
        // 是否有梯度
        //popView.hasGradientBackground = NO;
        popView.backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:1];
        popView.textColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:1];
        // 0是Slide  1是pop  2是Fade但是有问题，用前两个就好了
        popView.animation = arc4random() % 1;
        // 立体效果，默认是YES
        popView.has3DStyle = arc4random() % 1;
        // 是否点击任意位子就影藏
        //popView.dismissTapAnywhere = YES;
        // 是否自定影藏
        //[popView autoDismissAnimated:YES atTimeInterval:5.0];
        
        [popView presentPointingAtView:sender inView:self.view animated:YES];
        [self.visiblePopTipViews addObject:popView];
        self.currentPopTipViewTarget = sender;
    }
    
}
// 默认值
//- (id)initWithFrame:(CGRect)frame
//{
//    if ((self = [super initWithFrame:frame])) {
//        // Initialization code
//        self.opaque = NO;
//        
//        _topMargin = 2.0;
//        _pointerSize = 12.0;
//        _sidePadding = 2.0;
//        _borderWidth = 1.0;
//        
//        self.textFont = [UIFont boldSystemFontOfSize:14.0];
//        self.textColor = [UIColor whiteColor];
//        self.textAlignment = NSTextAlignmentCenter;
//        self.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:60.0/255.0 blue:154.0/255.0 alpha:1.0];
//        self.has3DStyle = YES;
//        self.borderColor = [UIColor blackColor];
//        self.hasShadow = YES;
//        self.animation = CMPopTipAnimationSlide;
//        self.dismissTapAnywhere = NO;
//        self.preferredPointDirection = PointDirectionAny;
//        self.hasGradientBackground = YES;
//        self.cornerRadius = 10.0;
//    }
//    return self;
//}

- (void)dismissAllPopTipViews
{
    while ([self.visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [self.visiblePopTipViews removeObjectAtIndex:0];
    }
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    NSLog(@"消失了");
    self.roundRectButtonPopTipView = nil;
}



- (NSMutableArray *)tableDataSource
{
    if (_tableDataSource == nil) {
        _tableDataSource = [[NSMutableArray alloc] initWithArray:@[@"发起群聊",@"添加朋友",@"扫一扫",@"收付款",@"博主真帅"]];
    }
    return _tableDataSource;
}
@end
