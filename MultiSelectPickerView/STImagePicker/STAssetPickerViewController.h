//
//  STAssetPickerViewController.h
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "STAssetModel.h"
#import "UIView+Extension.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
typedef enum PhotoType{
    PhotoTypeAlbum,
    PhotoTypeCamera
}PhotoType;

typedef void(^PhotosBlock)(NSMutableArray *allSelectedArray ,NSMutableArray *currentSelectedArray);
@interface STAssetPickerViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (assign, nonatomic) NSInteger maxImageNumber;
@property (strong, nonatomic) PhotosBlock photos;
/**
 *  判断相册相机权限
 */
+ (void)PhotoAuthorizationStatus:(PhotoType)type authResult:(void(^)(BOOL authorized))authReault;

@end
