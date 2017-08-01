//
//  ZQBlueToothMachineDetailViewController.m
//  coreBluetooth
//
//  Created by Joyce on 17/7/31.
//  Copyright © 2017年 Joyce. All rights reserved.
//

#import "ZQBlueToothMachineDetailViewController.h"

@interface ZQBlueToothMachineDetailViewController ()

@end

@implementation ZQBlueToothMachineDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
