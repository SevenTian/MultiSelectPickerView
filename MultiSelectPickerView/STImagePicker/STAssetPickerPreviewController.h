//
//  STAssetPickerPreview.h
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AssetColor(r,g,b,a) [UIColor colorWithRed:r/250.0 green:g/250.0 blue:b/250.0 alpha:1]
typedef void(^ResultBlock)(NSMutableArray *currentSelectedArray);

@protocol STAssetPickerPreviewControllerDelegate <NSObject>

- (void)assetPickerPreviewControllerConfirm;

@end
@interface STAssetPickerPreviewCollectionViewCell : UICollectionViewCell
@end

@interface STAssetPickerPreviewController : UIViewController
@property (strong, nonatomic) ResultBlock result;
@property (strong, nonatomic) NSMutableArray *assetArray;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (strong, nonatomic) NSMutableArray *currentSelectedArray;
@property (assign, nonatomic) NSInteger scrollIndex;
@property (assign, nonatomic) NSInteger maxImageNumber;
@property (weak, nonatomic) id <STAssetPickerPreviewControllerDelegate> delegate;
@end
