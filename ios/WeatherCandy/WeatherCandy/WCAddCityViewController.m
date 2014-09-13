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
#import "WCSettings.h"

@interface WCAddCityViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (strong, nonatomic) NSMutableArray *savedCities;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

@property (assign, nonatomic) BOOL searching;
@property (assign, nonatomic) BOOL showSearchResults;

@end

@implementation WCAddCityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _savedCities = [NSMutableArray new];
    _searchResults = [NSMutableArray new];
    
    self.bgImgView.image = self.bgImg;
    
    self.tableView.backgroundColor = [UIColor clearColor];
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

#pragma mark - Actions

- (void)pressedTitle:(id)sender
{
    [_manager.operationQueue cancelAllOperations];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    WCCity *currentLocation = [WCCity new];
    currentLocation.name = @"Current Location";
    currentLocation.currentLocation = YES;
    [_savedCities insertObject:currentLocation atIndex:0];
    
    [self.tableView reloadData];
}

- (void)saveCityData
{
    [_savedCities removeObjectAtIndex:0];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"cities"];
    [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:_savedCities] forKey:@"cities"];
    [ud synchronize];
}

- (void)saveLastSelectedCity:(WCCity *)city
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:city] forKey:kLastSelectedCity];
    [ud synchronize];
}

- (void)stopSearching
{
    [_searchResults removeAllObjects];
    self.showSearchResults = NO;
    self.searching = NO;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    
    if (_showSearchResults) {
        if (_searching || _searchResults.count == 0) {
            numRows = 1;
        }
        else {
            numRows = _searchResults.count;
        }
    }
    else {
        numRows = _savedCities.count;
    }
    
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    if (_showSearchResults) {
        if (_searching) {
            cell.textLabel.text = @"Searching...";
        }
        else if (_searchResults.count > 0) {
            WCCity *city = _searchResults[indexPath.row];
            [self formatCell:cell withCity:city];
        }
        else {
            cell.textLabel.text = @"No Results";
        }
    }
    else {
        WCCity *city = _savedCities[indexPath.row];
        [self formatCell:cell withCity:city];
    }
    
    return cell;
}

- (void)formatCell:(UITableViewCell *)cell withCity:(WCCity *)city
{
    NSString *cityName = city.name;
    NSString *adminName = city.adminName;
    NSString *countryCode = city.country;
    
    NSString *wholeString;
    
    if (!city.currentLocation) {
        wholeString = [NSString stringWithFormat:@"%@, %@ (%@)", cityName, adminName, countryCode];
    }
    else {
        wholeString = [NSString stringWithFormat:@"%@", cityName];
    }
    
    cell.textLabel.text = wholeString;
}

#pragma mark - Table View Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !(_searching || (_showSearchResults && !_searchResults.count));
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searching || (_showSearchResults && !_searchResults.count)) return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WCCity *selectedCity;
    
    if (_searchResults.count > 0) {
        
        selectedCity = _searchResults[indexPath.row];
        [_savedCities insertObject:selectedCity atIndex:1];
        
        if (_savedCities.count > 7) {
            [_savedCities removeLastObject];
        }
        
        [self saveCityData];
        
        [self.searchBar setText:@""];
        [self.searchBar resignFirstResponder];
        [self stopSearching];
    }
    else {
        selectedCity = _savedCities[indexPath.row];
        
        // Check if we selected the current location
        if (selectedCity.currentLocation && ![[WCSettings sharedSettings] locationEnabled]) {
            [self handleNoLocationError];
            return;
        }
    }
    
    // If we did not select current location, save this as the last chosen city
    if (!selectedCity.currentLocation) {
        [self saveLastSelectedCity:selectedCity];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCityChangedNotification object:nil userInfo:@{@"city": selectedCity}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleNoLocationError
{
    UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Location services isn't currently enabled for this app. Please turn on location services to use this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [err show];
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
    
    self.showSearchResults = YES;
    self.searching = YES;
    
    // remove all search objects first
    [self.searchResults removeAllObjects];
    
    NSDictionary *params = @{@"name": searchBar.text, @"name_startsWith": searchBar.text, @"cities": @"cities1000", @"maxRows": @"50", @"isNameRequired": @"true", @"orderby": @"relevance", @"featureClass":@"P", @"username": @"codyko"};
    
    __weak id weakSelf = self;
    
    [_manager GET:@"http://api.geonames.org/searchJSON" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        __strong WCAddCityViewController *strongSelf = weakSelf;
        
        if (!operation.isCancelled) {
            NSDictionary *dict = responseObject;
            
            for (NSDictionary *cityDict in dict[@"geonames"]) {
                WCCity *newCity = [WCCity new];
                newCity.cityID = cityDict[@"geonameId"];
                newCity.name = cityDict[@"name"];
                newCity.adminName = cityDict[@"adminName1"];
                newCity.country = cityDict[@"countryCode"];
                
                [strongSelf.searchResults addObject:newCity];
            }
            
            strongSelf.searching = NO;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!operation.isCancelled) {
            __strong WCAddCityViewController *strongSelf = weakSelf;
            strongSelf.searching = NO;
        }
    }];
}

@end
