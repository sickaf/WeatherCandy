//
//  WCSettingsViewController.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/3/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCSettingsViewController.h"
#import "WCConstants.h"

@interface WCSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WCSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
}

@end
