//
//  STAssetPickerRootViewController.m
//  ImagePicker
//
//  Created by 8dage on 16/5/31.
//  Copyright © 2016年 8dage. All rights reserved.
//

#import "STAssetPickerRootViewController.h"
@interface STAssetPickerRootViewController ()

@end

@implementation STAssetPickerRootViewController
- (instancetype)initWithSelectedArray:(NSMutableArray *)selectedArray maxImageNumber:(NSInteger)number photos:(void(^)(NSMutableArray *allselectedArray, NSMutableArray *currentSelectedArray))photos
{
    STAssetPickerViewController *VC = [[STAssetPickerViewController alloc]init];
    VC.selectedArray = selectedArray;
    VC.maxImageNumber = number;
    VC.photos = ^(NSMutableArray *allselectedArray, NSMutableArray *currentSelectedArray){
        photos(allselectedArray,currentSelectedArray);
    };
    self = [super initWithRootViewController:VC];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
