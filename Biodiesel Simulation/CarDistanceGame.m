//
//  CarDistanceGame.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 11/3/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "CarDistanceGame.h"

@implementation CarDistanceGame

#define LEVEL_TWO_DISTANCE 5
#define LEVEL_THREE_DISTANCE 95
#define LEVEL_FOUR_DISTANCE 200
#define LEVEL_FIVE_DISTANCE 250

+ (NSDictionary*)computeTheDistanceWithFuel:(NSDictionary *)fuel
{
    NSDictionary *gameResults;
    
    double wallet = 50; // the amount of money available to buy fuel
    double pricePerGallon = [(NSNumber*)fuel[@"Cost"] doubleValue];
    double effeciency = [(NSNumber*)fuel[@"Eout"] doubleValue] / 10;
    
    double gallons = wallet / pricePerGallon;
    
    double distanceTravelled = gallons * effeciency;
    
    NSString *fuelQualityTooLow = @"No";
    
    if([fuel[@"Convout"] floatValue] < 95)
    {
        fuelQualityTooLow = @"Yes";
        
        gameResults = @{@"Price": [NSNumber numberWithDouble:pricePerGallon], @"Gallons":[NSNumber numberWithDouble:gallons] , @"Distance": @0, @"Fuel Quality": fuelQualityTooLow};
    } else
    {
        gameResults = @{@"Price": [NSNumber numberWithDouble:pricePerGallon], @"Gallons": [NSNumber numberWithDouble:gallons],
                                      @"Distance": [NSNumber numberWithDouble:distanceTravelled], @"Fuel Quality": fuelQualityTooLow};
    }
    
    return gameResults;
}

+ (int)getHighestUnlockedLevel
{
    int highestUnlockedLevel = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"Highest Unlocked Level"];
    
    if(!highestUnlockedLevel)
    {
        highestUnlockedLevel = 1;
        [[NSUserDefaults standardUserDefaults] setInteger:highestUnlockedLevel forKey:@"Highest Unlocked Level"];
    }
    
    return highestUnlockedLevel;
}

+ (BOOL)checkDistanceForLevelUp:(CGFloat)distance andStoreLevelUpInfo:(BOOL)shouldStore
{
    BOOL shouldLevelUp = NO;
    int currentLevel = 1;
    
    if(distance > LEVEL_FIVE_DISTANCE)
    {
        currentLevel = 5;
    } else if(distance > LEVEL_FOUR_DISTANCE)
    {
        currentLevel = 4;
    } else if(distance > LEVEL_THREE_DISTANCE)
    {
        currentLevel = 3;
    } else if(distance > LEVEL_TWO_DISTANCE)
    {
        currentLevel = 2;
    }
    
    if([self getHighestUnlockedLevel] < currentLevel)
    {
        shouldLevelUp = YES;
    }
    
    if(shouldStore)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:currentLevel forKey:@"Highest Unlocked Level"];
    }
    
    return shouldLevelUp;
}

@end
