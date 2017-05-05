//
//  STAssetPickerViewController.m
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import "STAssetPickerViewController.h"
#import "TitleButton.h"
#import "UIView+Extension.h"
#import "STAssetPickerCollectionViewCell.h"
#import "STAssetPickerPreviewController.h"
#import "STAssetGroupView.h"
#import <CoreLocation/CoreLocation.h>
#import "UILabel+Extension.h"
static NSString *AssetPickerCell = @"assetPickerCell";
@interface STAssetPickerViewController ()<UIAlertViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,STAssetGroupViewDelegate,STAssetPickerPreviewControllerDelegate>
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSMutableArray *groupNames;
@property (strong, nonatomic) NSMutableArray *models;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) STAssetGroupView *groupView;
@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) NSMutableArray *currentSelectedArray;
@end

@implementation STAssetPickerViewController
{
    UIButton *_confirmBtn;
    NSInteger _index;//记录分组索引
    BOOL _isPreview;//是否预览
    UIButton *_previewBtn;
    UIView *_backView;
    TitleButton *_groupBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.currentSelectedArray = [self.selectedArray mutableCopy];
    _index = 0;
    [STAssetPickerViewController PhotoAuthorizationStatus:PhotoTypeAlbum authResult:^(BOOL authorized) {
        if (authorized) {
            [self collectionViewShow];
            
            [self navViewShow];
            [self bottomToolBar];
            if (SYSTEMVERSION >= 8.0) {
                [self iOS9GetALbum];
            }else
            {
                [self iOS7GetAlbum];
            }
        }else
        {
            [self alertViewWithDelegate:self title:nil message:@"亲，您需要在[系统设置->隐私->照片]里面设置允许  访问照片才行哦~" cancel:@"取消" other:@"设置"];
        }
    }];
}
#pragma mark - lazy

- (NSMutableArray *)groupNames
{
    if (!_groupNames) {
        _groupNames = [[NSMutableArray alloc]init];
    }
    return _groupNames;
}
- (NSMutableArray *)models
{
    if (!_models) {
        _models = [[NSMutableArray alloc]init];
    }
    return _models;
}
- (NSMutableArray *)groups
{
    if (!_groups) {
        _groups = [[NSMutableArray alloc]init];
    }
    return _groups;
}
- (NSMutableArray *)currentSelectedArray
{
    if (!_currentSelectedArray) {
        _currentSelectedArray = [[NSMutableArray alloc]init];
    }
    return _currentSelectedArray;
}
- (STAssetGroupView *)groupView
{
    if (!_groupView) {
        _groupView = [[STAssetGroupView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64) assetArray:self.models groupName:self.groupNames];
        _groupView.delegate = self;
        [self.view insertSubview:_groupView atIndex:1];
    }
    return _groupView;
}
#pragma mark - UI
/**
 *  导航
 */
- (void)navViewShow
{
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    [navView setBackgroundColor:AssetColor(245,245,245,1)];
    [self.view addSubview:navView];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, navView.height - 0.5, navView.width, 0.5)];
    [lineView setBackgroundColor:AssetColor(200,200,200,1)];
    [navView addSubview:lineView];
    
    TitleButton *groupBtn = [[TitleButton alloc] initWithFrame:CGRectZero font:18 titleColor:[UIColor blackColor] normalImage:@"assetPicker_down" selectedImage:@"assetPicker_top" title:@"相机胶卷"];
    [groupBtn setTitleColor:AssetColor(70,70,70,1) forState:UIControlStateNormal];
    [groupBtn sizeToFit];
    groupBtn.center = CGPointMake(self.view.bounds.size.width * 0.5, 42);
     [groupBtn addTarget:self action:@selector(groupShow:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:groupBtn];
    _groupBtn = groupBtn;
    
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 20, 40, 44)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:cancelBtn];
    
    _confirmBtn = [[UIButton alloc]init];
    _confirmBtn.layer.cornerRadius = 3;
    _confirmBtn.layer.masksToBounds = YES;
    [_confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self changeConfirmState];
    [_confirmBtn addTarget:self action:@selector(confirmButtonDoClick) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:_confirmBtn];

}
- (void)bottomToolBar
{
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 42, self.view.bounds.size.width, 0.5)];
    [lineView setBackgroundColor:AssetColor(200,200,200,1)];
    [self.view addSubview:lineView];
    
    _previewBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), lineView.width, 41.5)];
    [_previewBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_previewBtn addTarget:self action:@selector(pushPreview) forControlEvents:UIControlEventTouchUpInside];
    [self previewButtonState];
    [self.view addSubview:_previewBtn];
}
- (void)pushPreview
{
    if (self.selectedArray.count == 0) {
        return;
    }
    [self popToPreview:0 array:self.selectedArray];
}
- (void)popToPreview:(NSInteger)scrollIndex array:(NSMutableArray *)array
{
    STAssetPickerPreviewController *VC = [[STAssetPickerPreviewController
                                           alloc]init];
    VC.assetArray = array;
    //    VC.selectedArray = self.selectedArray;
    VC.currentSelectedArray = self.currentSelectedArray;
    VC.scrollIndex = scrollIndex;
    VC.delegate = self;
    VC.result = ^(NSMutableArray *asset){
        self.currentSelectedArray = asset;
        [self.collectionView reloadData];
        [self changeConfirmState];
        [self previewButtonState];
    };
    [self.navigationController pushViewController:VC animated:YES];

}
/**
 *  预览按钮状态改变
 */
- (void)previewButtonState
{
    if (self.currentSelectedArray.count == 0) {
        [_previewBtn setTitleColor:AssetColor(200,200,200,1) forState:UIControlStateNormal];
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    }else
    {
        [_previewBtn setTitleColor:AssetColor(255,102,102,1) forState:UIControlStateNormal];
        [_previewBtn setTitle:[NSString stringWithFormat:@"预览(%zd)",self.currentSelectedArray.count] forState:UIControlStateNormal];
    }
}
/**
 *  按钮状态改变
 */
- (void)changeConfirmState
{
    if (self.currentSelectedArray.count == 0) {
        [_confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:AssetColor(200,200,200,1) forState:UIControlStateNormal];
        [_confirmBtn setBackgroundColor:[UIColor whiteColor]];
        _confirmBtn.layer.borderColor = AssetColor(200,200,200,1).CGColor;
        _confirmBtn.layer.borderWidth = 0.5;
    }else
    {
        [_confirmBtn setTitle:[NSString stringWithFormat:@"完成(%zd)",self.currentSelectedArray.count] forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.layer.borderWidth = 0;
        _confirmBtn.layer.borderColor = [UIColor clearColor].CGColor;
        [_confirmBtn setBackgroundColor:AssetColor(255,102,102,1)];
    }
    [_confirmBtn sizeToFit];
    _confirmBtn.frame = CGRectMake(self.view.width - _confirmBtn.width - 40, 28, _confirmBtn.width + 25, 28);
}
- (void)groupShow:(TitleButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.groupView assetGroupViewShow];
    }else
    {
        [self.groupView dismiss];
    }
}
#pragma mark - 取消
- (void)cancel
{
    if (self.currentSelectedArray.count != 0) {
        for (STAssetModel *model in self.currentSelectedArray) {
                if ([self.selectedArray containsObject:model]) {
                    [self.selectedArray removeObject:model];
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 完成按钮点击
- (void)confirmButtonDoClick
{
    [self getCurrentSelectedImages];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - STAssetPickerPreviewControllerDelegate
- (void)assetPickerPreviewControllerConfirm
{
    [self getCurrentSelectedImages];
}
#pragma mark - 过滤之前选择的图片
- (void)getCurrentSelectedImages
{
    if (self.currentSelectedArray.count == 0) {
        [UILabel promptMessage:@"请选择照片"];
        return;
    }
    if (self.selectedArray.count  == 0) {
        self.photos(self.currentSelectedArray,self.currentSelectedArray);
    }else
    {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (STAssetModel *model in self.currentSelectedArray) {
            if (![self.selectedArray containsObject:model]) {
                [array addObject:model];
            }
        }
        self.photos(self.currentSelectedArray,array);
    }
}

#pragma mark - 判断相册相机权限
+ (void)PhotoAuthorizationStatus:(PhotoType)type authResult:(void(^)(BOOL authorized))authReault
{
    
    if(type == PhotoTypeCamera)
    {
        //判断相机权限
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
            authReault(NO);
        }
        authReault(YES);
    }else if (type == PhotoTypeAlbum)
    {
        
        if (SYSTEMVERSION >= 8.0) {
            //判断相册权限
            PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
            if (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied) {
                authReault(NO);
            }else if (authStatus == PHAuthorizationStatusNotDetermined) {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (status == PHAuthorizationStatusAuthorized) {
                            authReault(YES);
                        }else
                        {
                            authReault(NO);
                        }

                    });
                }];
                
            }else
            {
                authReault(YES);
            }

        }else
        {
            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied) {
                authReault(NO);
            }else
            {
                authReault(YES);
            }
        }
    }
}

- (void)iOS9GetALbum
{
    //得到所有系统相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    //图片类型
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    for (int i = 0; i < smartAlbums.count; i ++) {
        PHCollection *collection = smartAlbums[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary || assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded) {
                if (fetchResult.count != 0) {
                    if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                        [self.groups  insertObject:fetchResult atIndex:0];
                        [self.groupNames insertObject:collection.localizedTitle atIndex:0];
                    }else
                    {
                        [self.groups  addObject:fetchResult];
                        [self.groupNames addObject:collection.localizedTitle];
                    }

                }
            }
        }
    }
    //得到用户添加的自定义相册
    PHFetchResult *userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    for (int i = 0; i < userCollections.count; i ++) {
        PHCollection *collection = (PHCollection *)userCollections[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if (fetchResult.count != 0) {
                [self.groups addObject:fetchResult];
                [self.groupNames addObject:assetCollection.localizedTitle];

        }
        }
    }
    
    
    
    if (self.groups.count == 0) {
        [self showNoAssets];
    }else
    {
        TitleButton *btn = (TitleButton *)self.navigationItem.titleView;
        [btn setTitle:self.groupNames[0] forState:UIControlStateNormal];
        
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (int i = 0; i < [[self.groups firstObject]count]; i ++) {
            STAssetModel *model = [[STAssetModel alloc]init];
            model.asset = [self.groups firstObject][i];
            model.isSelected = NO;
            [array insertObject:model atIndex:0];
        }
        [self.models addObject:array];
        [self.collectionView reloadData];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 1; i < self.groups.count; i ++) {
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for (int j = 0; j < [self.groups[i] count]; j ++) {
                STAssetModel *model = [[STAssetModel alloc]init];
                model.asset = self.groups[i][j];
                model.isSelected = NO;
                [array insertObject:model atIndex:0];
            }
            [self.models addObject:array];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });

    
}

- (void)iOS7GetAlbum
{
    ALAssetsLibraryGroupsEnumerationResultsBlock resultBlock = ^(ALAssetsGroup *group, BOOL *stop){
        if (group.numberOfAssets > 0) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"相机胶卷"]) {
                [self.groups insertObject:group atIndex:0];
                [self.groupNames insertObject:[group valueForProperty:ALAssetsGroupPropertyName] atIndex:0];
            }else
            {
                [self.groups addObject:group];
                [self.groupNames addObject:[group valueForProperty:ALAssetsGroupPropertyName]];
            }
                if (self.models.count == 0) {
                    ALAssetsGroup *group1 = [self.groups firstObject];
                    NSMutableArray *array = [[NSMutableArray alloc]init];
                    ALAssetsGroupEnumerationResultsBlock resultBlock1 = ^(ALAsset *asset,NSUInteger index,BOOL *stop)
                    {
                        if (asset) {
                            STAssetModel *model = [[STAssetModel alloc]init];
                            model.asset = asset;
                            model.isSelected = NO;
                            model.url = [NSString stringWithFormat:@"%@",[[asset defaultRepresentation] url]];
                            [array insertObject:model atIndex:0];
                        }
                    };
                    [group1 enumerateAssetsUsingBlock:resultBlock1];
                    [self.models addObject:array];
                    [_backView removeFromSuperview];
                    [self.collectionView setHidden:NO];
                    [self.collectionView reloadData];
                }else
                {
                    [self ergodicObject:group];
                }
        }
    };

    self.assetsLibrary = [[ALAssetsLibrary alloc]init];
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        
    };
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:resultBlock
                                    failureBlock:failureBlock];
    
    // Then all other groups
    NSUInteger type =
    ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent |
    ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    
    [self.assetsLibrary enumerateGroupsWithTypes:type
                                      usingBlock:resultBlock
                                    failureBlock:failureBlock];
}
- (void)ergodicObject:(ALAssetsGroup *)group
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *array = [[NSMutableArray alloc]init];
            ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *asset,NSUInteger index,BOOL *stop)
            {
                if (asset) {
                    STAssetModel *model = [[STAssetModel alloc]init];
                    model.asset = asset;
                    model.isSelected = NO;
                    model.url = [NSString stringWithFormat:@"%@",[[asset defaultRepresentation] url]];
                    [array insertObject:model atIndex:0];
                }
            };
            [group enumerateAssetsUsingBlock:resultBlock];
            [self.models addObject:array];
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });

}
/**
 *  没有照片的时候显示
 */
- (void)showNoAssets
{
    [self.collectionView setHidden:YES];
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    backView.backgroundColor = [UIColor whiteColor];
    //    backView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backView];
    
    
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"无照片或视频";
    titleLabel.font = [UIFont systemFontOfSize:26];
    titleLabel.textColor = [UIColor lightGrayColor];
    [backView addSubview:titleLabel];
    
    UILabel *label = [[UILabel alloc]init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = @"您可以使用相机拍摄照片和视频，或使用iTunes将照片和视频同步到iPhone";
    label.textColor = [UIColor grayColor];
    [backView addSubview:label];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(backView,titleLabel,label);
    
    [backView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[titleLabel]-15-|" options:0 metrics:nil views:views]];
    [backView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLabel(40)]" options:0 metrics:nil views:views]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:-45.0f]];
    
    [backView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[label]-15-|" options:0 metrics:nil views:views]];
    [backView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLabel][label(50)]" options:0 metrics:nil views:views]];
    _backView = backView;
}

- (void)alertViewWithDelegate:(nullable id)delegate title:(nullable NSString *)title message:(nullable NSString *)message cancel:(nullable NSString *)cancel other:(nullable NSString *)other
{
    if ([[UIDevice currentDevice].systemVersion intValue] >= 8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self cancelButtonDoClick];
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:other style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self otherButtonDoClick];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:otherAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:other, nil];
        [alertView show];
    }
    
}
- (void)otherButtonDoClick
{
    if (SYSTEMVERSION >= 8.0) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else
    {
        NSString *app_id = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"prefs:root=%@", app_id]]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)cancelButtonDoClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self otherButtonDoClick];
    }
    [self cancelButtonDoClick];
}
- (void)collectionViewShow
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 3;
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    flowLayout.itemSize = CGSizeMake((self.view.bounds.size.width - 6)/3, (self.view.bounds.size.width - 10)/3);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 90) collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"STAssetPickerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:AssetPickerCell];
}
#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.models.count == 0) {
        return 0;
    }
    return [self.models[_index]count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STAssetPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AssetPickerCell forIndexPath:indexPath];
    [cell.selectedBtn addTarget:self action:@selector(selectedPhoto:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectedBtn.tag = indexPath.item + 1;
    if (SYSTEMVERSION >= 8.0) {
        STAssetModel *model = self.models[_index][indexPath.item];
        for (id obj in self.currentSelectedArray) {
            if ([obj isKindOfClass:[STAssetModel class]]) {
                if ([[obj asset] isEqual:model.asset]) {
                    model.isSelected = YES;
                    [self.currentSelectedArray removeObject:obj];
                    [self.currentSelectedArray addObject:model];
                    if ([self.selectedArray containsObject:obj]) {
                        [self.selectedArray removeObject:obj];
                        [self.selectedArray addObject:model];
                    }
                    
                    break;
                }
            }
        }
        cell.assetModel = model;
    }else
    {
        STAssetModel *model = self.models[_index][indexPath.item];
        for (id obj in self.currentSelectedArray) {
            if ([obj isKindOfClass:[STAssetModel class]]) {
                if ([[(STAssetModel *)obj url] isEqualToString:model.url]) {
                    model.isSelected = YES;
                    [self.currentSelectedArray removeObject:obj];
                    [self.currentSelectedArray addObject:model];
                    if ([self.selectedArray containsObject:obj]) {
                        [self.selectedArray removeObject:obj];
                        [self.selectedArray addObject:model];
                    }
                    break;
                }
            }
        }
        cell.assetModel = self.models[_index][indexPath.item];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self popToPreview:indexPath.item array:self.models[_index]];
}
#pragma mrk - 选择按钮点击
- (void)selectedPhoto:(UIButton *)btn
{
    btn.selected = !btn.selected;
    STAssetModel *model = self.models[_index][btn.tag - 1];
    model.isSelected = btn.selected;
    if (model.isSelected) {
        if (self.maxImageNumber != 0) {
            if (self.currentSelectedArray.count == self.maxImageNumber) {
                [UILabel promptMessage:[NSString stringWithFormat:@"最多选择%ld张照片",(long)self.maxImageNumber]];
                btn.selected = NO;
                model.isSelected = btn.selected;
                return;
            }
        }
        [self.currentSelectedArray addObject:model];
    }else
    {
        [self.currentSelectedArray removeObject:model];
    }
    [self changeConfirmState];
    [self previewButtonState];
}
#pragma mark - STAssetGroupViewDelegate
- (void)assetGroupViewSelectedIndex:(NSInteger)index
{
    _groupBtn.selected = !_groupBtn.selected;
    [_groupBtn setTitle:self.groupNames[index] forState:UIControlStateNormal];
    [_groupBtn sizeToFit];
    _groupBtn.center = CGPointMake(self.view.bounds.size.width * 0.5, 42);
    _index = index;
    [self.collectionView reloadData];
}
- (void)assetGroupViewDismiss
{
    _groupBtn.selected = !_groupBtn.selected;
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

@end
