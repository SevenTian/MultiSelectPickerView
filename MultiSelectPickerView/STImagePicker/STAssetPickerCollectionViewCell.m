//
//  STAssetPickerCollectionViewCell.m
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import "STAssetPickerCollectionViewCell.h"
#import "STAssetModel.h"
@implementation STAssetPickerCollectionViewCell
- (void)setAssetModel:(STAssetModel *)assetModel
{
    _assetModel = assetModel;
    [assetModel thumbnailImage:^(UIImage *image) {
        [self.photo setImage:image];
    }];
    self.selectedBtn.selected = assetModel.isSelected;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
