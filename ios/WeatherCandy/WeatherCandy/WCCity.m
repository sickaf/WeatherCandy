//
//  WCCity.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/2/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCCity.h"

@implementation WCCity

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [super init];
    if (self)
    {
        _cityID = [coder decodeObjectForKey:@"cityID"];
        _name = [coder decodeObjectForKey:@"name"];
        _adminName = [coder decodeObjectForKey:@"adminName"];
        _country = [coder decodeObjectForKey:@"country"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.cityID forKey:@"cityID"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.adminName forKey:@"adminName"];
    [coder encodeObject:self.country forKey:@"country"];
}

@end
