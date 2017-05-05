//
//  STAssetModel.h
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SYSTEMVERSION [[UIDevice currentDevice].systemVersion floatValue]
@interface STAssetModel : NSObject
@property (nonatomic,strong) id asset;
@property (strong, nonatomic) NSString *url;
@property (nonatomic,assign) BOOL isSelected;//是否被选中
- (void)originalImage:(void (^)(UIImage *image))returnImage;//获取原图
- (void)thumbnailImage:(void (^)(UIImage *image))returnImage;//获取缩略图
@end
