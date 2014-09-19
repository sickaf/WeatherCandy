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
    WCImageCategory _chosenImageCategory;
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
    _chosenImageCategory = _previousImageCategory;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) return;
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_chosenImageCategory inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    _chosenImageCategory = indexPath.row;
    [[WCSettings sharedSettings] setSelectedImageCategory:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WCCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    WCImageCategory cat = [[WCSettings sharedSettings] selectedImageCategory];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (_chosenImageCategory == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

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
