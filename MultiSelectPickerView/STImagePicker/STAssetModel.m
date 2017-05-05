//
//  STAssetModel.m
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import "STAssetModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
@implementation STAssetModel
- (void)originalImage:(void (^)(UIImage *))returnImage
{
    if (SYSTEMVERSION >= 8.0) {
        [[PHImageManager defaultManager]requestImageDataForAsset:self.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image = [UIImage imageWithData:imageData];
            returnImage(image);
        }];
    }else
    {
        ALAssetRepresentation *representation = [self.asset defaultRepresentation];
        returnImage([UIImage imageWithCGImage:[representation fullScreenImage]]);
    } 
}
- (void)thumbnailImage:(void (^)(UIImage *image))thunbnailImage
{
    if (SYSTEMVERSION >= 8.0) {
        [[PHImageManager defaultManager]requestImageForAsset:self.asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            thunbnailImage(result);
        }];
    }else
    {
        thunbnailImage([UIImage imageWithCGImage:[self.asset thumbnail]]);
    }
}
@end
