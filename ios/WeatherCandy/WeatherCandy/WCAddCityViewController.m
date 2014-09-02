//
//  WCAddCityViewController.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/2/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCAddCityViewController.h"
#import "WCConstants.h"
#import "WCCity.h"
#import "WCCityCell.h"
#import "AFNetworking.h"

@interface WCAddCityViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSMutableArray *savedCities;
@property (strong, nonatomic) NSMutableArray *searchResults;

@property (assign, nonatomic) BOOL searching;

@end

@implementation WCAddCityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    _savedCities = [NSMutableArray new];
    _searchResults = [NSMutableArray new];
    
    UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
    [butt setTitle:@"Boston" forState:UIControlStateNormal];
    [butt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [butt setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    butt.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
    [butt addTarget:self action:@selector(pressedDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setTitleView:butt];
    
    self.tableView.backgroundColor = kDefaultGreyColor;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.tintColor = [UIColor whiteColor];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
    [self getSavedCityData];
}

#pragma mark - Properties

- (void)setSearching:(BOOL)searching
{
    _searching = searching;
    [self.tableView reloadData];
}

#pragma mark - Helpers

- (void)getSavedCityData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *savedCities = [ud objectForKey:@"cities"];
    [_savedCities addObjectsFromArray:savedCities];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    
    if (_searching) {
        numRows = 1;
    }
    else {
        if (_searchResults.count > 0) {
            numRows = _searchResults.count;
        }
        else {
            numRows = _savedCities.count;
        }
    }
    
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
    
    if (_searching) {
        cell.textLabel.text = @"Searching...";
    }
    else {
        if (_searchResults.count > 0) {
            cell.textLabel.text = _searchResults[indexPath.row][@"name"];
        }
        else {
            //WCCity *city = self.savedCities[indexPath.row];
            cell.textLabel.text = @"we made it";
        }
    }
    
    return cell;
}

#pragma mark - Table View Delegate

#pragma mark - Actions

- (void)pressedDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    
    if (!searchText.length) {
        [_searchResults removeAllObjects];
        self.searching = NO;
        return;
    }
    
    self.searching = YES;
    
    NSDictionary *params = @{@"name": searchText, @"name_startsWith": searchText, @"cities": @"cities1000", @"maxRows": @"50", @"isNameRequired": @"true", @"orderby": @"relevance", @"featureClass":@"P", @"username": @"codyko"};
    [manager GET:@"http://api.geonames.org/searchJSON" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (!operation.isCancelled) {
            NSDictionary *dict = responseObject;
            [_searchResults removeAllObjects];
            [_searchResults addObjectsFromArray:dict[@"geonames"]];
            self.searching = NO;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
