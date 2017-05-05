//
//  STAssetPickerCollectionViewCell.h
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STAssetModel;
@interface STAssetPickerCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;

@property (strong, nonatomic) STAssetModel *assetModel;
@end
