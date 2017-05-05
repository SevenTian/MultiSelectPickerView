//
//  ViewController.m
//  MultiSelectPickerView
//
//  Created by 8dage on 2017/5/5.
//  Copyright © 2017年 冯倩. All rights reserved.
//
#define kDeviceWidth  [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height
#define KSYSTEMVERSION [[UIDevice currentDevice].systemVersion floatValue]
#import "ViewController.h"
#import "CollectionViewCell.h"
#import "STAssetPickerRootViewController.h"
#import "STAlertTool.h"
#import <CoreLocation/CoreLocation.h>
@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(strong, nonatomic, nullable)UICollectionView *collectionView;
@property(strong, nonatomic, nullable)NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片选择器";
    [self.view addSubview:self.collectionView];
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.itemSize = CGSizeMake((kDeviceWidth - 50)/4, (kDeviceWidth - 50)/4);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [_collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count + 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.item == self.dataArray.count) {
        [cell.pic setImage:[UIImage imageNamed:@"camera_small"]];
    }else
    {
        STAssetModel *model = self.dataArray[indexPath.item];
        //获取缩略图
        [model thumbnailImage:^(UIImage *image) {
            [cell.pic setImage:image];
        }];
        //获取原图
//        [model originalImage:^(UIImage *image) {
//            [cell.pic setImage:image];
//        }];
    }
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.dataArray.count) {
        //添加图片
        if (KSYSTEMVERSION >= 8.0) {
            //判断相册权限
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                [self notPermission:@"获取相册权限" message:@"没有权限访问您的相册，请打开设置->隐私->照片"];
            }else
            {
                [self selectPics];
            }
            
        }else
        {
            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied) {
                [self notPermission:@"获取相册权限" message:@"没有权限访问您的相册，请打开设置->隐私->照片"];
            }else
            {
                [self selectPics];
            }
        }
    }
}
- (void)selectPics
{
    STAssetPickerRootViewController *picSelectVC = [[STAssetPickerRootViewController alloc] initWithSelectedArray:self.dataArray maxImageNumber:5 photos:^(NSMutableArray *allselectedArray, NSMutableArray *currentSelectedArray) {
        self.dataArray = allselectedArray;
        [self.collectionView reloadData];
    }];
    [self presentViewController:picSelectVC animated:YES completion:nil];
}
- (void)notPermission:(NSString *)title message:(NSString *)message
{
    [STAlertTool initWithViewController:self title:title message:message cancleButtonTitle:@"取消" OtherButton:@"设置" otherButtonClick:^{
        if (KSYSTEMVERSION >= 8.0) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }else
        {
            NSString *app_id = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"prefs:root=%@", app_id]]];
        }
        
    } cancelClick:^{
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
