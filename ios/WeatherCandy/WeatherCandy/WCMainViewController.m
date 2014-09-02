//
//  ViewController.m
//  WeatherCandy
//
//  Created by dtown on 8/31/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCMainViewController.h"
#import "WCCollectionViewCell.h"
#import "WCConstants.h"
#import "AFNetworking.h"
#import "WCSlideDownModalAnimation.h"

#import <Parse/Parse.h>

@interface WCMainViewController () {
    NSArray *_imgData;
    NSMutableArray *_imgs;
}

@end

@implementation WCMainViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    self.view.backgroundColor = kDefaultGreyColor;
    
    _imgData = @[@"http://photos-a.ak.instagram.com/hphotos-ak-xpf1/10553999_1447827782154488_388662961_n.jpg",
                 @"http://photos-e.ak.instagram.com/hphotos-ak-xfa1/10012522_259935160847948_1011959515_n.jpg",
                 @"http://photos-d.ak.instagram.com/hphotos-ak-xaf1/10601929_1546280335592507_1297605176_n.jpg",
                 @"http://photos-h.ak.instagram.com/hphotos-ak-xaf1/10661088_579312335512287_864534314_n.jpg"];
    _imgs = [NSMutableArray new];
    
    self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.alignBottom = YES;
    
    UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
    [butt setTitle:@"Boston" forState:UIControlStateNormal];
    [butt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [butt setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    butt.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
    [butt addTarget:self action:@selector(pressedCityName:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setTitleView:butt];
}

//- (void)refreshVisibleCells
//{
//    NSArray *vis = self.collectionView.visibleCells;
//    for (WCCollectionViewCell *cell in vis) {
//        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
//        if (_imgs.count > indexPath.row) {
//            cell.imageView.image = _imgs[indexPath.row];
//        }
//    }
//}

//
//- (IBAction)getWeatherCandyDataButton:(id)sender {
//    
////   stringToReturn =  ""+obj.name + "$"+obj.weather[0].description+"$"+(obj.main.temp-kelvin)+"$"+obj.main.temp_max+"$"+obj.main.temp_min+"$"+obj.IGPhotos[0].IGUrl;
//
//    
//    [PFCloud callFunctionInBackground:@"getWeatherCandyData"
//                       withParameters:@{@"cityName": self.cityTextField.text,@"date":self.dateTextField.text}
//                                block:^(NSDictionary *result, NSError *error) {
//                                    if (!error) {
//                                        self.cityNameLabel.text =    [result componentsSeparatedByString:@"$"][0];
//                                        self.descriptionLabel.text = [result componentsSeparatedByString:@"$"][1];
//                                        self.currentTempLabel.text = [result componentsSeparatedByString:@"$"][2];
//                                        self.highTempLabel.text = [result componentsSeparatedByString:@"$"][3];
//                                        self.lowTempLabel.text = [result componentsSeparatedByString:@"$"][4];
//
//                                        
//                                        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [result componentsSeparatedByString:@"$"][5]]];
//                                        self.igImageView.image = [UIImage imageWithData: imageData];
//                                        
//                                    }
//                                }];
//    
//}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _imgData.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.imageView.backgroundColor = [self random];
    cell.imageURL = _imgData[indexPath.row];
    return cell;
}
- (IBAction)pressedCityName:(id)sender
{
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddCity"];

    self.navigationController.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - animation delegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    WCSlideDownModalAnimation *slide = [WCSlideDownModalAnimation new];
    if (operation == UINavigationControllerOperationPop) {
        slide.presenting = YES;
    }
    return slide;
}

- (UIColor *)random
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
@end
