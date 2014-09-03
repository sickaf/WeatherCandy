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
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

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
    
    // Change the keyboard return key to done
    for (UIView *subview in self.searchBar.subviews)
    {
        for (UIView *subSubview in subview.subviews)
        {
            if ([subSubview conformsToProtocol:@protocol(UITextInputTraits)])
            {
                UITextField *textField = (UITextField *)subSubview;
                [textField setKeyboardAppearance: UIKeyboardAppearanceAlert];
                textField.returnKeyType = UIReturnKeyDone;
                break;
            }
        }
    }
    
    // Change search bar text color
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
    _manager = [AFHTTPRequestOperationManager manager];
    [_manager.operationQueue setMaxConcurrentOperationCount:1];
    
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
    
    NSData *dataRepresentingSavedArray = [ud objectForKey:@"cities"];
    if (dataRepresentingSavedArray)
    {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        [_savedCities addObjectsFromArray:oldSavedArray];
    }
    
    [self.tableView reloadData];
}

- (void)saveCityData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"cities"];
    [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:_savedCities] forKey:@"cities"];
    [ud synchronize];
}

- (void)stopSearching
{
    [_searchResults removeAllObjects];
    self.searching = NO;
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
        
        WCCity *city;
        
        if (_searchResults.count > 0) {
           city  = _searchResults[indexPath.row];
        }
        else {
            city = _savedCities[indexPath.row];
        }
        
        NSString *cityName = city.name;
        NSString *adminName = city.adminName;
        NSString *countryCode = city.country;
        
        NSString *wholeString = [NSString stringWithFormat:@"%@, %@ (%@)", cityName, adminName, countryCode];
        cell.textLabel.text = wholeString;
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searching) return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WCCity *selectedCity;
    
    if (_searchResults.count > 0) {
        
        selectedCity = _searchResults[indexPath.row];
        [_savedCities addObject:selectedCity];
        [self saveCityData];
        
        [self.searchBar setText:@""];
        [self.searchBar resignFirstResponder];
        [self stopSearching];
    }
    else {
        selectedCity = _savedCities[indexPath.row];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCityChangedNotification object:nil userInfo:@{@"city": selectedCity}];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions

- (void)pressedDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // Cancel all requests so far
    [_manager.operationQueue cancelAllOperations];
    
    if (!searchText.length) {
        [self stopSearching];
        return;
    }
    
    self.searching = YES;
    
    NSDictionary *params = @{@"name": searchBar.text, @"name_startsWith": searchBar.text, @"cities": @"cities1000", @"maxRows": @"50", @"isNameRequired": @"true", @"orderby": @"relevance", @"featureClass":@"P", @"username": @"codyko"};
    [_manager GET:@"http://api.geonames.org/searchJSON" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (!operation.isCancelled) {
            NSDictionary *dict = responseObject;
            [_searchResults removeAllObjects];
            
            for (NSDictionary *cityDict in dict[@"geonames"]) {
                WCCity *newCity = [WCCity new];
                newCity.cityID = cityDict[@"geonameId"];
                newCity.name = cityDict[@"name"];
                newCity.adminName = cityDict[@"adminName1"];
                newCity.country = cityDict[@"countryCode"];
                
                [_searchResults addObject:newCity];
            }
            
            self.searching = NO;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
