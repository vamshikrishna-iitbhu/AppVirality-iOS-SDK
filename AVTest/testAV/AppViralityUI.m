//
//  AppViralityUI.m
//  testAV
//
//  Created by Ram on 08/05/15.
//  Copyright (c) 2015 AppVirality. All rights reserved.
//

#import "AppViralityUI.h"
#import "AppViralityAlertViewController.h"
#import "AppViralityWelcomeViewController.h"
#import "MBProgressHUD.h"

@implementation AppViralityUI
+ (void)showGrowthHack:(GrowthHackType)growthHack  FromController:(UIViewController*)viewController
{
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    [AppVirality getGrowthHack:growthHack completion:^(NSDictionary *campaignDetails,NSError*error) {
        [MBProgressHUD hideHUDForView:viewController.view animated:YES];
        if (campaignDetails) {
            AppViralityGrowthHackViewController * growthHackVC = [[AppViralityGrowthHackViewController alloc] initWithCampaignDetails:campaignDetails ForGrowthHack:growthHack];
            if (growthHackVC) {
                UINavigationController * navVC = [[UINavigationController alloc] initWithRootViewController:growthHackVC];
                [viewController presentViewController:navVC animated:YES completion:^{
                    
                }];
            }
        }
        else {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:@"No Active Campaigns found" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [av show];
        }
      
    }];
    
}

+ (void)showLaunchBar:(GrowthHackType)growthHack  FromController:(UIViewController*)viewController
{
    [AppVirality getGrowthHack:growthHack completion:^(NSDictionary *campaignDetails,NSError* error) {
        if (campaignDetails&&[campaignDetails objectForKey:@"OfferTitle"]) {
            
            [AppViralityAlertViewController CurrentView:viewController.view errorString:campaignDetails isPopup:NO];
        }
        
    }];
    __block NSString * statsId;
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:@"false",@"click",@"true",@"impression", nil];
    [AppVirality recordImpressionsForGrowthHack:GrowthHackTypeWordOfMouth WithParams:params completion:^(NSDictionary *response, NSError* error) {
        if (response) {
            statsId  = [response valueForKey:@"statsid"];
        }
    }];
    
   __block id observer =  [[NSNotificationCenter defaultCenter] addObserverForName:@"showGrowthHack" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (![statsId isEqual:[NSNull null]]) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            [AppVirality recordImpressionsForGrowthHack:GrowthHackTypeWordOfMouth WithParams:[NSDictionary dictionaryWithObjectsAndKeys:@"true",@"click",@"true",@"impression",statsId,@"CampaignStatsId", nil] completion:^(NSDictionary *response,NSError * error) {
                
            }];
        }
        [self showGrowthHack:growthHack FromController:viewController];
    }];
}

+ (void)showWelcomeScreenFromController:(UIViewController*)viewController
{
    [AppVirality getReferrerDetails:^(NSDictionary *referrerDetails,NSError* error) {
        //NSLog(@"iski %@ %@",[error valueForKey:NSLocalizedFailureReasonErrorKey],referrerDetails);
        AppViralityWelcomeViewController * welcomeVC = [[AppViralityWelcomeViewController alloc] initWithReferrerDetails:referrerDetails];
        if (welcomeVC) {
            UINavigationController * navVC = [[UINavigationController alloc] initWithRootViewController:welcomeVC];
            [viewController presentViewController:navVC animated:YES completion:^{
                //make isExistingUser True after showing welcome screen so that welcome screen should not be shown again.
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AV_ReferrerDetails"]) {
                    NSMutableDictionary * referrerDetails = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"AV_ReferrerDetails"] mutableCopy];
                    if ([referrerDetails objectForKey:@"isExistingUser"]) {
                        [referrerDetails setValue:@"True" forKey:@"isExistingUser"];
                        [[NSUserDefaults standardUserDefaults] setObject:referrerDetails forKey:@"AV_ReferrerDetails"];
                    }
                }
            }];
        }
    }];
  

    [[NSNotificationCenter defaultCenter] addObserverForName:@"SignUpClicked" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    }];
    
}

+ (void)showPopUp:(GrowthHackType)growthHack  FromController:(UIViewController*)viewController
{
    [AppVirality getGrowthHack:growthHack completion:^(NSDictionary *campaignDetails,NSError * error) {
        if (campaignDetails&&[campaignDetails objectForKey:@"OfferTitle"]) {
            
            [AppViralityAlertViewController CurrentView:viewController.view errorString:campaignDetails isPopup:YES];
        }
        
    }];
    __block NSString * statsId;
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:@"false",@"click",@"true",@"impression", nil];
    [AppVirality recordImpressionsForGrowthHack:GrowthHackTypeWordOfMouth WithParams:params completion:^(NSDictionary *response, NSError* error) {
        if (response) {
           statsId  = [response valueForKey:@"statsid"];
        }
    }];
    
   __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"showGrowthHack" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (![statsId isEqual:[NSNull null]]) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            [AppVirality recordImpressionsForGrowthHack:GrowthHackTypeWordOfMouth WithParams:[NSDictionary dictionaryWithObjectsAndKeys:@"true",@"click",@"true",@"impression",statsId,@"CampaignStatsId", nil] completion:^(NSDictionary *response, NSError * error) {
                
            }];
        }

        [self showGrowthHack:growthHack FromController:viewController];
    }];
    
}

@end

