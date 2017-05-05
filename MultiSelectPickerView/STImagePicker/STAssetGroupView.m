//
//  STAssetGroupView.m
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import "STAssetGroupView.h"
#import <Photos/Photos.h>
#import "STAssetModel.h"
#import "UIView+Extension.h"
static CGFloat RowHeight = 60.f;
@interface STAssetGroupViewTableViewCell ()
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UIImageView *pic;
@end
@implementation STAssetGroupViewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.pic = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, RowHeight - 10, RowHeight - 10)];
        self.pic.contentMode = UIViewContentModeScaleAspectFill;
        self.pic.clipsToBounds = YES;

        [self.contentView addSubview:self.pic];
        
        self.name = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.pic.frame) + 10, 0, self.bounds.size.width - CGRectGetMaxX(self.pic.frame) - 30, RowHeight)];
        [self.name setTextColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1]];
        [self.name setFont:[UIFont systemFontOfSize:15]];
        [self.contentView addSubview:self.name];
    }
    return self;
}
+ (STAssetGroupViewTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    STAssetGroupViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[STAssetGroupViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}
@end
@interface STAssetGroupView ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@end
@implementation STAssetGroupView
{
    NSMutableArray *_assetArray;
    NSMutableArray *_groupNameArray;
}
- (instancetype)initWithFrame:(CGRect)frame assetArray:(NSMutableArray *)assetArray groupName:(NSMutableArray *)groupNameArray
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self setHidden:YES];
        _assetArray = assetArray;
        _groupNameArray = groupNameArray;
        [self tableViewShow];
    }
    return self;
}
- (void)assetGroupViewShow
{
    [self setHidden:NO];
    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.y = 0;
    }];
}
- (void)tableViewShow
{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, -self.height * 0.6, self.width, self.height * 0.6) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = RowHeight;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groupNameArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STAssetGroupViewTableViewCell *cell = [STAssetGroupViewTableViewCell cellWithTableView:tableView];
    [[_assetArray[indexPath.row] lastObject] thumbnailImage:^(UIImage *image) {
        [cell.pic setImage:image];
    }];
//    if (KSYSTEMVERSION >= 8.0) {
        [cell.name setText:[NSString stringWithFormat:@"%@(%zd)",_groupNameArray[indexPath.row],[_assetArray[indexPath.row] count]]];
//    }
//    else
//    {
//        ALAssetsGroup *assetsGroup = _assetArray[indexPath.row];
//        [cell.name setText:[NSString stringWithFormat:@"%@(%zd)",_groupNameArray[indexPath.row],[assetsGroup numberOfAssets]]];
//    }

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(assetGroupViewSelectedIndex:)]) {
        [self.delegate assetGroupViewSelectedIndex:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(assetGroupViewDismiss)]) {
        [self.delegate assetGroupViewDismiss];
    }
}
- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
         self.tableView.y = - self.height * 0.6;
    } completion:^(BOOL finished) {
        [self setHidden:YES];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
