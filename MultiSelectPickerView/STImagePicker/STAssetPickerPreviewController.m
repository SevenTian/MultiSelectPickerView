//
//  STAssetPickerPreview.m
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import "STAssetPickerPreviewController.h"
#import "STAssetModel.h"
#import "UIView+Extension.h"
#import "UILabel+Extension.h"
static NSString *AssetPickerPreviewCell = @"AssetPickerPreviewCollectionViewCell";

@interface STAssetPickerPreviewCollectionViewCell ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (strong, nonatomic) STAssetModel *assetModel;

@property (nonatomic, copy, nullable)   void(^singleTapBlock)();
@end
@implementation STAssetPickerPreviewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, self.width, self.height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
        
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        [_scrollView addSubview:_imageContainerView];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageContainerView addSubview:_imageView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
    }
    return self;
}
- (void)setAssetModel:(STAssetModel *)assetModel
{
    _assetModel = assetModel;
    [self.scrollView setZoomScale:1.0f];
    [assetModel originalImage:^(UIImage *image) {
        [self.imageView setImage:image];
        [self resizeSubviews];
    }];
    
}
- (void)resizeSubviews {
    _imageContainerView.size = _imageView.size;
    _imageContainerView.center= CGPointMake(self.width/2, self.height/2);
    _scrollView.contentSize = CGSizeMake(self.width, MAX(_imageContainerView.height, self.height));
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.height <= self.height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
}


- (void)_handleSingleTap {
    self.singleTapBlock ? self.singleTapBlock() : nil;
}

- (void)_handleDoubleTap:(UITapGestureRecognizer *)doubleTap {
    if (self.scrollView.zoomScale > 1.0f) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }else {
        CGPoint touchPoint = [doubleTap locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapBlock) {
        self.singleTapBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    CGSize boundsSize = scrollView.bounds.size;
//    CGRect imageFrame = _imageContainerView.frame;
//    CGSize contentSize = scrollView.contentSize;
//    
//    CGPoint centerPoint = CGPointMake(contentSize.width * 0.5, contentSize.height * 0.5);
//    if (imageFrame.size.width <= boundsSize.width) {
//        centerPoint.x = boundsSize.width * 0.5;
//    }
//    if (imageFrame.size.height <= boundsSize.height) {
//        centerPoint.y = boundsSize.height * 0.5;
//        NSLog(@"%f",boundsSize.height);
//    }
//    self.imageContainerView.center = centerPoint;
//    self.imageView.center = centerPoint;
    CGFloat offsetX = (scrollView.width > scrollView.contentSize.width) ? (scrollView.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.height > scrollView.contentSize.height) ? (scrollView.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end
@interface STAssetPickerPreviewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@end
@implementation STAssetPickerPreviewController
{
    UIButton *_selectedBtn;
    NSInteger _currentIndex;
    UIButton *_confirmBtn;
    UIButton *_titleBtn;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self navViewShow];
    [self collectionViewShow];
}
/**
 *  导航
 */
- (void)navViewShow
{
    _currentIndex = _scrollIndex;
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    [navView setBackgroundColor:AssetColor(245,245,245,1)];
    [self.view addSubview:navView];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, navView.height - 0.5, navView.width, 0.5)];
    [lineView setBackgroundColor:AssetColor(200,200,200,1)];
    [navView addSubview:lineView];
    
    UIButton *titleBtn = [[UIButton alloc]init];
    [titleBtn setTitle:[NSString stringWithFormat:@"%zd/%zd",_scrollIndex + 1,self.assetArray.count] forState:UIControlStateNormal];
        [titleBtn setTitleColor:AssetColor(70,70,70,1) forState:UIControlStateNormal];
    titleBtn.size = CGSizeMake(100, 44);
    titleBtn.center = CGPointMake(self.view.bounds.size.width * 0.5, 42);
    [navView addSubview:titleBtn];
    _titleBtn = titleBtn;
    
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 20, 40, 44)];
    [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [cancelBtn addTarget:self action:@selector(getBack) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:cancelBtn];
    
    _confirmBtn = [[UIButton alloc]init];
    _confirmBtn.layer.cornerRadius = 3;
    _confirmBtn.layer.masksToBounds = YES;
    [_confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self changeConfirmState];
    [_confirmBtn addTarget:self action:@selector(confirmButtonDoClick) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:_confirmBtn];
    
}
- (void)getBack
{
    self.result(self.currentSelectedArray);
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)confirmButtonDoClick
{
    if (self.currentSelectedArray.count == 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(assetPickerPreviewControllerConfirm)]) {
        [self.delegate assetPickerPreviewControllerConfirm];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
- (void)collectionViewShow
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - 64);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64) collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
    
    _selectedBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40, 75, 30, 30)];
    [_selectedBtn setImage:[UIImage imageNamed:@"assetPicker_normal"] forState:UIControlStateNormal];
    [_selectedBtn setImage:[UIImage imageNamed:@"assetPicker_selected"] forState:UIControlStateSelected];
    [_selectedBtn addTarget:self action:@selector(selectenButtonDoClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_selectedBtn];

    [self.collectionView registerClass:[STAssetPickerPreviewCollectionViewCell class] forCellWithReuseIdentifier:AssetPickerPreviewCell];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_scrollIndex] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    _selectedBtn.selected = [_assetArray[_scrollIndex] isSelected];
    
}
- (void)selectenButtonDoClick:(UIButton *)btn
{
    //改变选中状态
    btn.selected = !btn.selected;
    STAssetModel *model = _assetArray[_currentIndex];
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
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (_assetArray) {
        return _assetArray.count;
    }
    return 0;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STAssetPickerPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AssetPickerPreviewCell forIndexPath:indexPath];
    cell.assetModel = _assetArray[indexPath.section];
    return cell;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //当前索引
    _currentIndex = scrollView.contentOffset.x/self.view.bounds.size.width;
    
    [_titleBtn setTitle:[NSString stringWithFormat:@"%zd/%zd",_currentIndex + 1,self.assetArray.count] forState:UIControlStateNormal];
    //改变选中状态
    STAssetModel *model = _assetArray[_currentIndex];
    _selectedBtn.selected = model.isSelected;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
