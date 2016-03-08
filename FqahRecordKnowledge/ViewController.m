//
//  ViewController.m
//  FqahRecordKnowledge
//
//  Created by __无邪_ on 3/4/16.
//  Copyright © 2016 fqah. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"sss%@",self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)funAction:(id)sender {
    NSLog(@"-----");
    NSArray *logs = @[@"err"];
    NSLog(@"%@",logs[2]);
}
- (IBAction)fun2Action:(id)sender {
    NSLog(@"---=========");
}

@end
