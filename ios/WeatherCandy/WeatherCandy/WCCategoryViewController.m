//
//  WCCategoryViewController.m
//  WeatherCandy
//
//  Created by dtown on 9/13/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCCategoryViewController.h"
#import "WCCategoryCell.h"
#import "WCSettings.h"
#import "WCConstants.h"

@interface WCCategoryViewController () {
    WCImageCategory _previousImageCategory;
}

@end

@implementation WCCategoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Categories";
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.000];
    
    _previousImageCategory = [[WCSettings sharedSettings] selectedImageCategory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if ([[WCSettings sharedSettings] selectedImageCategory] != _previousImageCategory) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadImagesNotification object:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;

    if(indexPath.row == 0)
    {
        [[WCSettings sharedSettings] setSelectedImageCategory:WCImageCategoryGirl];
    }
    else if(indexPath.row == 1)
    {
        [[WCSettings sharedSettings] setSelectedImageCategory:WCImageCategoryAnimal];
    }
    
    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WCCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    WCImageCategory cat = [[WCSettings sharedSettings] selectedImageCategory];
    cell.accessoryType = UITableViewCellAccessoryNone;

    if(indexPath.row == 0)
    {
        cell.textLabel.text = @"Hot Girls";
        if(cat == WCImageCategoryGirl) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Cute Animals";
        if(cat == WCImageCategoryAnimal) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
      return cell;
}

@end
