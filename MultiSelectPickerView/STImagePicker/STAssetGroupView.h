//
//  STAssetGroupView.h
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol STAssetGroupViewDelegate <NSObject>

- (void)assetGroupViewSelectedIndex:(NSInteger)index;
- (void)assetGroupViewDismiss;
@end
@interface STAssetGroupViewTableViewCell : UITableViewCell

@end
@interface STAssetGroupView : UIView
@property (weak, nonatomic) id <STAssetGroupViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame assetArray:(NSMutableArray *)assetArray groupName:(NSMutableArray *)groupNameArray;
- (void)assetGroupViewShow;
- (void)dismiss;
@end
