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
    
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
}

#pragma mark - Actions

- (IBAction)pressedDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Units";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

@end
