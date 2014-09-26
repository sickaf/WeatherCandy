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
#import "WCNetworkManager.h"

@interface WCAddCityViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (strong, nonatomic) NSMutableArray *savedCities;
@property (strong, nonatomic) NSMutableArray *searchResults;

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
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.6];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.tintColor = [UIColor whiteColor];
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
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
                textField.font = kDefaultFontMedium(14);
                break;
            }
        }
    }
    
    // Change search bar text color
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
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
    [[WCNetworkManager sharedManager] cancelAllAddCityRequests];
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
    NSMutableArray *cityArray = [NSMutableArray arrayWithArray:_savedCities];
    [cityArray removeObjectAtIndex:0];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"cities"];
    [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:cityArray] forKey:@"cities"];
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

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_savedCities removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        [self saveCityData];
        //[self.tableView reloadData];

    }
}

//keep user from deleting current location

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return UITableViewCellEditingStyleNone;
    else
        return UITableViewCellEditingStyleDelete;
}

- (BOOL)cityIsSaved:(WCCity *)city
{
    for (WCCity *savedCity in _savedCities) {
        if (savedCity.cityID == city.cityID)
            return YES;
    }
    return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searching || (_showSearchResults && !_searchResults.count)) return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WCCity *selectedCity;
    
    if (_searchResults.count > 0) {
        
        selectedCity = _searchResults[indexPath.row];
        if (![self cityIsSaved:selectedCity]) {
            [_savedCities insertObject:selectedCity atIndex:1];
        }

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
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCityChangedNotification object:nil userInfo:@{@"city": selectedCity}];
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
    [[WCNetworkManager sharedManager] cancelAllAddCityRequests];
    
    if (!searchText.length) {
        [self stopSearching];
        return;
    }
    
    self.showSearchResults = YES;
    self.searching = YES;
    
    // remove all search objects first
    [self.searchResults removeAllObjects];
    
    __weak id weakSelf = self;
    
    [[WCNetworkManager sharedManager] findCitiesWithSearchText:searchText completion:^(NSArray *cities, NSError *error) {
        __strong WCAddCityViewController *strongSelf = weakSelf;

        if (!error) {
            strongSelf.searchResults = [NSMutableArray arrayWithArray:cities];
        }
        
        strongSelf.searching = NO;
    }];
}

@end
