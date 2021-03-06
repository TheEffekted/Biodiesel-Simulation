//
//  InputDataTableViewController.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 10/19/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "InputDataTableViewController.h"
#import "SimulationViewController.h"
#import "SmartSlider.h"
#import "CarDistanceGame.h"
#import "PageContentViewController.h"
#import "UIView+Glow.h"
#import "Reachability.h"

@interface InputDataTableViewController () <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIImageView *litIcon;

@property (weak, nonatomic) IBOutlet UIImageView *smallDroplet;
@property (weak, nonatomic) IBOutlet UIImageView *bigDroplet;
@property (weak, nonatomic) IBOutlet UIImageView *smallDroplet2;
@property (weak, nonatomic) IBOutlet UIImageView *bigDroplet2;
@property (weak, nonatomic) IBOutlet UIImageView *smallTime;
@property (weak, nonatomic) IBOutlet UIImageView *bigTime;
@property (weak, nonatomic) IBOutlet UIImageView *smallTime2;
@property (weak, nonatomic) IBOutlet UIImageView *bigTime2;
@property (weak, nonatomic) IBOutlet UIImageView *smallThermometer;
@property (weak, nonatomic) IBOutlet UIImageView *bigThermometer;

@property (weak, nonatomic) IBOutlet UIImageView *smallOil;
@property (weak, nonatomic) IBOutlet UIImageView *smallMediumOil;
@property (weak, nonatomic) IBOutlet UIImageView *mediumOil;
@property (weak, nonatomic) IBOutlet UIImageView *mediumBigOil;
@property (weak, nonatomic) IBOutlet UIImageView *bigOil;

@property (weak, nonatomic) IBOutlet SmartSlider *methanolSlider;
@property (weak, nonatomic) IBOutlet SmartSlider *catalystSlider;
@property (weak, nonatomic) IBOutlet SmartSlider *temperatureSlider;
@property (weak, nonatomic) IBOutlet SmartSlider *settlingTimeSlider;
@property (weak, nonatomic) IBOutlet SmartSlider *mixingLengthSlider;
@property (strong, nonatomic) IBOutletCollection(SmartSlider) NSArray *sliders;


@property (weak, nonatomic) IBOutlet UIButton *startSimulationButton;

@property(nonatomic) BOOL oilAmountNotChosen;

@property(strong, nonatomic) NSArray *suggestedValues;

// oil value stored in a property due to not being stored in a slider
@property(nonatomic) CGFloat oil;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@property(strong, nonatomic) UIView *blurView;

@property(nonatomic) BOOL tutorialOn;

@end

@implementation InputDataTableViewController

#pragma mark - User Interface

- (IBAction)sliderTouched:(UIPanGestureRecognizer *)sender
{
    BOOL slidingLeft = YES;
    BOOL slidingRight = NO;
    SmartSlider *slider = (SmartSlider*)sender.view;
    
    if(slider.value < slider.previousValue)
    {
        slidingLeft = YES;
        slidingRight = NO;
    } else if(slider.value > slider.previousValue)
    {
        slidingRight = YES;
        slidingLeft = NO;
    } else
    {
        slidingRight = NO;
        slidingLeft = NO;
    }
    
    slider.previousValue = slider.value;
    
    self.litIcon.tintColor = [UIColor blackColor];
    [self makeViewNotGlow:self.litIcon];
    
    if(sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)
    {
        if(slider == self.methanolSlider)
        {
            if(slidingLeft)
            {
                self.litIcon = self.smallDroplet;
                
            } else if(slidingRight)
            {
                self.litIcon = self.bigDroplet;
            }
        } else if(slider == self.catalystSlider)
        {
            if(slidingLeft)
            {
                self.litIcon = self.smallDroplet2;
                
            } else if(slidingRight)
            {
                self.litIcon = self.bigDroplet2;
            }
        } else if(slider == self.temperatureSlider)
        {
            if(slidingLeft)
            {
                self.litIcon = self.smallThermometer;
                
            } else if(slidingRight)
            {
                self.litIcon = self.bigThermometer;
            }
        } else if(slider == self.settlingTimeSlider)
        {
            if(slidingLeft)
            {
                self.litIcon = self.smallTime2;
                
            } else if(slidingRight)
            {
                self.litIcon = self.bigTime2;
            }
        } else if(slider == self.mixingLengthSlider)
        {
            if(slidingLeft)
            {
                self.litIcon = self.smallTime;
                
            } else if(slidingRight)
            {
                self.litIcon = self.bigTime;
            }

        }
        self.litIcon.image = [self.litIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.litIcon setTintColor:self.view.tintColor];
        [self makeViewGlow:self.litIcon color:self.view.tintColor];
    } else if(sender.state == UIGestureRecognizerStateEnded)
    {
        self.litIcon.tintColor = [UIColor blackColor];
        self.litIcon = nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    if (section == 0){
        header = [NSString stringWithFormat:@"INITIAL METHANOL: %i MOLES", (int)self.methanolSlider.value];
    } else if(section == 1)
    {
        header = [NSString stringWithFormat:@"INITIAL TEMPERATURE: %i ˚C", (int)self.temperatureSlider.value];
    } else if(section == 2)
    {
        header = [NSString stringWithFormat:@"INITIAL CATALYST: %i MOLES", (int)self.catalystSlider.value];
    } else if(section == 3)
    {
        header = [NSString stringWithFormat:@"MIXING LENGTH: %i MINUTES", (int)self.mixingLengthSlider.value];
    } else if(section == 4)
    {
        header = [NSString stringWithFormat:@"SETTLING TIME: %i MINUTES", (int)self.settlingTimeSlider.value];
    } else if(section == 5 && !self.oilAmountNotChosen)
    {
        header = [NSString stringWithFormat:@"INITIAL OIL: %i MOLES", (int)self.oil];
    } else if(section == 5 && self.oilAmountNotChosen)
    {
        header = @"INITIAL OIL: ??? MOLES";
    }
    
    return header;
}



- (IBAction)sliderValueChanged:(UISlider *)sender
{
    if(sender == self.methanolSlider)
    {
        [self.tableView headerViewForSection:0].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:0];
    } else if(sender == self.catalystSlider)
    {
        [self.tableView headerViewForSection:2].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:2];
    } else if(sender == self.temperatureSlider)
    {
        [self.tableView headerViewForSection:1].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:1];
    } else if(sender == self.settlingTimeSlider)
    {
        [self.tableView headerViewForSection:4].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:4];
    } else if(sender == self.mixingLengthSlider)
    {
        [self.tableView headerViewForSection:3].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:3];
    }
}

- (IBAction)oilButtonPressed:(UITapGestureRecognizer *)sender
{
    [self enableAppropriateOilButtons];
    
    self.oilAmountNotChosen = NO;
    [self makeViewNotGlow:self.smallOil];
    [self makeViewNotGlow:self.smallMediumOil];
    [self makeViewNotGlow:self.mediumOil];
    [self makeViewNotGlow:self.mediumBigOil];
    [self makeViewNotGlow:self.bigOil];
    
    if(sender.view == self.smallOil)
    {
        self.oil = 5;
        self.smallOil.tintColor = self.view.tintColor;
    } else if(sender.view == self.smallMediumOil)
    {
        self.oil = 7.5;
        self.smallMediumOil.tintColor = self.view.tintColor;
    }
    else if(sender.view == self.mediumOil)
    {
        self.oil = 10;
        self.mediumOil.tintColor = self.view.tintColor;
    } else if(sender.view == self.mediumBigOil)
    {
        self.oil = 12.5;
        self.mediumBigOil.tintColor = self.view.tintColor;
    }
    else if(sender.view == self.bigOil)
    {
        self.oil = 15;
        self.bigOil.tintColor = self.view.tintColor;
    }
    
    NSArray *buttons = @[self.smallOil, self.smallMediumOil, self.mediumOil, self.mediumBigOil, self.bigOil];
    
    for(UIImageView *button in buttons)
    {
        [button stopGlowing];
    }
    
    [self makeViewGlow:sender.view color:self.view.tintColor];
    
    [self.tableView headerViewForSection:5].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:5];
}


- (void)enableAppropriateOilButtons
{
    int highestUnlockedLevel = [CarDistanceGame getHighestUnlockedLevel];
       
    self.bigOil.image = [self.bigOil.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.bigOil setTintColor:[UIColor lightGrayColor]];
    self.mediumBigOil.image = [self.mediumBigOil.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.mediumBigOil setTintColor:[UIColor lightGrayColor]];
    self.mediumOil.image = [self.mediumOil.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.mediumOil setTintColor:[UIColor lightGrayColor]];
    self.smallMediumOil.image = [self.smallMediumOil.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.smallMediumOil setTintColor:[UIColor lightGrayColor]];
    self.smallOil.image = [self.smallOil.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.smallOil setTintColor:[UIColor lightGrayColor]];
    
    self.bigOil.userInteractionEnabled = NO;
    self.mediumBigOil.userInteractionEnabled = NO;
    self.mediumOil.userInteractionEnabled = NO;
    self.smallMediumOil.userInteractionEnabled = NO;
    self.smallOil.userInteractionEnabled = NO;
    
    for(int i = highestUnlockedLevel; i > 0; i--)
    {
        switch(i)
        {
            case 5: self.bigOil.tintColor = [UIColor blackColor];
                self.bigOil.userInteractionEnabled = YES; break;
                
            case 4: self.mediumBigOil.tintColor = [UIColor blackColor];
                self.mediumBigOil.userInteractionEnabled = YES; break;
                
            case 3: self.mediumOil.tintColor = [UIColor blackColor];
                self.mediumOil.userInteractionEnabled = YES; break;
            
            case 2: self.smallMediumOil.tintColor = [UIColor blackColor];
                self.smallMediumOil.userInteractionEnabled = YES; break;
            
            case 1: self.smallOil.tintColor = [UIColor blackColor];
                self.smallOil.userInteractionEnabled = YES; break;
        }
    }
    
}

- (void)makeViewGlow:(UIView*)view color:(UIColor*)color
{
    view.layer.shadowColor = [color CGColor];
    view.layer.shadowRadius = 5.0f;
    view.layer.shadowOpacity = 0.9;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.masksToBounds = NO;
}

- (void)makeViewNotGlow:(UIView*)view
{
    UIColor *color = [UIColor clearColor];
    view.layer.shadowColor = [color CGColor];
    view.layer.shadowRadius = 5.0f;
    view.layer.shadowOpacity = 0.0;
    view.layer.shadowOffset = CGSizeZero;
}

- (void)playUnlockEffect:(int)oilToUnlock
{
    UIImageView *oilToGlow;
    
    switch(oilToUnlock)
    {
        case 1: oilToGlow = self.smallOil; break;
        case 2: oilToGlow = self.smallMediumOil; break;
        case 3: oilToGlow = self.mediumOil; break;
        case 4: oilToGlow = self.mediumBigOil; break;
        case 5: oilToGlow = self.bigOil; break;
    }
    
    [self makeViewGlow:oilToGlow color:[UIColor orangeColor]];
    [oilToGlow startGlowingWithColor:[UIColor orangeColor] intensity:2.0];
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"Just Unlocked Level"];
}

- (void)displayLevelUpMessage
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Congrats!" message:[NSString stringWithFormat:@"You unlocked a new level of gas!"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self playUnlockEffect:[CarDistanceGame getHighestUnlockedLevel]];
    }];
    
    [controller addAction:action];
    
    [self presentViewController:controller animated:NO completion: nil];
}

// The method called when the user hits an icon adjacent to a slider
- (IBAction)sliderIconTapped:(UITapGestureRecognizer *)sender
{
    UIImageView *tappedIcon;
    
    if(sender.view == self.smallDroplet)
    {
        self.methanolSlider.value -= 1;
        [self sliderValueChanged:self.methanolSlider];
      
        tappedIcon = self.smallDroplet;
    } else if(sender.view == self.bigDroplet)
    {
        self.methanolSlider.value += 1;
        [self sliderValueChanged:self.methanolSlider];
        
        tappedIcon = self.bigDroplet;
    } else if(sender.view == self.smallThermometer)
    {
        self.temperatureSlider.value -= 1;
        [self sliderValueChanged:self.temperatureSlider];
        
        tappedIcon = self.smallThermometer;
    } else if(sender.view == self.bigThermometer)
    {
        self.temperatureSlider.value += 1;
        [self sliderValueChanged:self.temperatureSlider];
        
        tappedIcon = self.bigThermometer;
    } else if(sender.view == self.smallDroplet2)
    {
        self.catalystSlider.value -= 1;
        [self sliderValueChanged:self.catalystSlider];
        
        tappedIcon = self.smallDroplet2;
    } else if(sender.view == self.bigDroplet2)
    {
        self.catalystSlider.value += 1;
        [self sliderValueChanged:self.catalystSlider];
        
        tappedIcon = self.bigDroplet2;
    } else if(sender.view == self.smallTime)
    {
        self.mixingLengthSlider.value -= 1;
        [self sliderValueChanged:self.mixingLengthSlider];
        
        tappedIcon = self.smallTime;
    } else if(sender.view == self.bigTime)
    {
        self.mixingLengthSlider.value += 1;
        [self sliderValueChanged:self.mixingLengthSlider];
        
        tappedIcon = self.bigTime;
    } else if(sender.view == self.smallTime2)
    {
        self.settlingTimeSlider.value -= 1;
        [self sliderValueChanged:self.settlingTimeSlider];
        
        tappedIcon = self.smallTime2;
    } else if(sender.view == self.bigTime2)
    {
        self.settlingTimeSlider.value += 1;
        [self sliderValueChanged:self.settlingTimeSlider];
        
        tappedIcon = self.bigTime2;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        tappedIcon.image = [tappedIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [tappedIcon setTintColor:[UIColor greenColor]];
        
        [self makeViewGlow:tappedIcon color:self.view.tintColor];
    } completion:^(BOOL finished) {
        tappedIcon.image = [tappedIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [tappedIcon setTintColor:[UIColor blackColor]];
        [self makeViewNotGlow:tappedIcon];
    }];
}

// Moves sliders to suggested value
- (IBAction)autoButtonHit:(UIBarButtonItem *)sender
{
    if(self.tutorialOn)
    {
        [self.blurView removeFromSuperview];
        [self.pageViewController.view removeFromSuperview];
        self.tableView.scrollEnabled = YES;
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"Faded In"];
        
        self.tutorialOn = NO;
        self.navigationItem.rightBarButtonItem.title = @"Auto";
        self.navigationItem.hidesBackButton = NO;
        
    } else
    {
        if([Reachability connectedToInternet])
        {
            
            NSURL *url = [NSURL URLWithString:@"http://cinnamon.cs.uwp.edu/biodiesel/suggestions/suggestionRequestor.php"];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            NSURLSessionTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                if(!error)
                {
                    NSString *strResult = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:location] encoding:NSUTF8StringEncoding];
                    NSArray *suggestions = [strResult componentsSeparatedByString:@","];
                    self.suggestedValues = suggestions;
                    
                    [self performSelectorOnMainThread:@selector(moveSlidersToSuggestedValues) withObject:self waitUntilDone:NO];
                }
            }];
            
            [task resume];
        } else
        {
            UIAlertController * alert = [Reachability noInternetAlert];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)moveSlidersToSuggestedValues
{
    [UIView animateWithDuration:1.0 animations:^{
        [self.methanolSlider setValue:[self.suggestedValues[1] integerValue] animated:YES];
    }];
    [self sliderValueChanged:self.methanolSlider];

    
    [UIView animateWithDuration:1.0 animations:^{
        [self.temperatureSlider setValue:[self.suggestedValues[2] integerValue] animated:YES];
    }];
    [self sliderValueChanged:self.temperatureSlider];

    
    int catalystValue = arc4random_uniform(10) + 1;
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.catalystSlider setValue:catalystValue animated:YES];
    }];
    [self sliderValueChanged:self.catalystSlider];

    
    [UIView animateWithDuration:1.0 animations:^{
        [self.mixingLengthSlider setValue:[self.suggestedValues[3] integerValue] animated:YES];
    }];
    [self sliderValueChanged:self.mixingLengthSlider];

    
    [UIView animateWithDuration:1.0 animations:^{
        [self.settlingTimeSlider setValue:[self.suggestedValues[4] integerValue] animated:YES];
    }];
    [self sliderValueChanged:self.settlingTimeSlider];
}

# pragma mark - MVC Lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView headerViewForSection:0].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    [self.tableView headerViewForSection:1].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    [self.tableView headerViewForSection:2].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    [self.tableView headerViewForSection:3].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    [self.tableView headerViewForSection:4].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    [self.tableView headerViewForSection:5].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    
    [self enableAppropriateOilButtons];
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"Faded In"];
    
    if([CarDistanceGame getHighestUnlockedLevel] == 2 && [[NSUserDefaults standardUserDefaults] valueForKey:@"Just Unlocked Level"])
    {
        [self displayLevelUpMessage];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"Just Unlocked Level"] && [CarDistanceGame getHighestUnlockedLevel] != 2)
    {
        [self playUnlockEffect:[CarDistanceGame getHighestUnlockedLevel]];
    }
    
    if(self.previousSimulationInputs)
    {
        [self loadPreviousInputs];
    }
    
    if(![[NSUserDefaults standardUserDefaults] integerForKey:@"Tutorial Done"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"Tutorial Done"];
        [self loadTutorial];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.oil = 5;
    self.oilAmountNotChosen = YES;
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"Just Unlocked Level"])
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:7];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - Tutorial

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 7)
    {
        if(indexPath.row == 0)
        {
            [self loadTutorial];
        }
    } else if(indexPath.section == 8)
    {
        [self performSegueWithIdentifier:@"Back To Login" sender:self];
    }
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)loadTutorial
{
    self.navigationItem.rightBarButtonItem.title = @"EXIT";
    self.tutorialOn = YES;
    self.navigationItem.hidesBackButton = YES;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    blurEffectView.alpha = 0.0;
    
    self.blurView = blurEffectView;
        
    [self.view addSubview:blurEffectView];
    
    [UIView animateWithDuration:1.5 animations:^{
        blurEffectView.alpha = 1;
    } completion:^(BOOL finished) {
        self.pageTitles =
  @[@"Welcome to Biodiesel Simulator! We have prepared a quick and handy tutorial to get you started. Swipe through to read!",
                            @"Biodiesel is a clean fuel produced from domestic, renewable resources. It's a promising alternative to normal diesel that could someday bring about a more earth-friendly future!",
                            @"Biodiesel is still costly. It's new, and the general public is uncertain about it. Overall it has a long way to go before it can truly replace normal diesel fuel. So we need help!",
                            @"We need you, the user, to help us find effecient ways to make biofuel. We need cheap ways to make quality biofuel, and this is most effectively done by humans.",
                            @"This app allows you to simulate the creation of biofuel, just like you're making it yourself! And we need you to use this capability to try and find the best ways to make biofuel.",
                            @"Here you will chose the chemical ingredients for your biofuel. Chose the methanol, catalyst, and oil amount, along with the cooking temperature, mixing, and settling length.",
                            @"Then, hit this button to start the simulation. After the simulation has finished, you see what the quality of your fuel was, and if it is cheap or not.",
                            @"Quality biodiesel fuel is fuel with a higher than 95% conversion rate. This is becuase you don't want more than 5% of waste products in your fuel.",
                            @"After your fuel has been created, the app demonstrates how high quality and cost effecient it is by filling up $50 worth of your fuel in a car and seeing how far it can go!",
                            @"Due to the formula for biodiesel creation, the amount of oil that you can use to make fuel is limited. You must level up in the game to unlock every amount of selectable oil.",
                            @"The Auto button will give you a helping hand and give you random ingredients that have a higher chance of being high quality, i.e. an above 95% conversion ratio. Try it out!",
                            @"Hit these buttons to get a quick definition of each of these items, like what the Current Level section means.",
                            @"And don't forget to check out our webclient at http://cinnamon.cs.uwp.edu/biodiesel/ You can review all your previous simulations here, and more!!",
                            @"Well, that's it. You can always hit the tutorial button to view this tutorial again. Now, go and make some excellent biodiesel! For science!"];
        
        self.pageImages = @[@"page1.jpg", @"page2.jpeg", @"page3.jpg", @"page4.jpg", @"page5.jpg", @"page6.jpg", @"page7.png", @"page8.jpg",
                            @"page9.jpg", @"page10.png", @"page11.jpg", @"page12.jpg", @"page13.jpg", @"page14.jpg"];
        
        // Create page view controller
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        self.pageViewController.dataSource = self;
        
        PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
//        // Change the size of page view controller
//        self.pageViewController.view.frame = CGRectMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y, self.tableView.contentOffset.x + self.tableView.bounds.size.width, self.tableView.contentOffset.y + self.tableView.bounds.size.height);
        
        self.pageViewController.view.frame = self.view.bounds;
        
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        self.tableView.scrollEnabled = NO;
    }];
}

#pragma mark - Simulation

- (NSDictionary*)gatherDataForSimulation
{
    NSDictionary *sliderValues = @{
                                   @"Initial Oil":[NSNumber numberWithFloat:self.oil],
                                         @"Initial Methanol":[NSNumber numberWithFloat:self.methanolSlider.value],
                                         @"Initial Catalyst":[NSNumber numberWithFloat:self.catalystSlider.value],
                                         @"Temperature":[NSNumber numberWithFloat:self.temperatureSlider.value],
                                         @"Settling Time":[NSNumber numberWithFloat:self.settlingTimeSlider.value],
                                         @"Mixing Length":[NSNumber numberWithFloat:self.mixingLengthSlider.value]};
    return sliderValues;
}

- (void)loadPreviousInputs
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.methanolSlider setValue:[self.previousSimulationInputs[@"Initial Methanol"] integerValue] animated:YES];
    }];
    [self sliderValueChanged:self.methanolSlider];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.temperatureSlider setValue:[self.previousSimulationInputs[@"Temperature"] integerValue] animated:YES];
    }];
    [self sliderValueChanged:self.temperatureSlider];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.catalystSlider setValue:[self.previousSimulationInputs[@"Initial Catalyst"] integerValue] animated:YES];
    }];
    [self sliderValueChanged:self.catalystSlider];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.mixingLengthSlider setValue:[self.previousSimulationInputs[@"Mixing Length"] integerValue] animated:YES];
    }];
    [self sliderValueChanged:self.mixingLengthSlider];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.settlingTimeSlider setValue:[self.previousSimulationInputs[@"Settling Time"] integerValue] animated:YES];
    }];
    [self sliderValueChanged:self.settlingTimeSlider];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"To Simulation"])
       {
           SimulationViewController *simulationViewController = segue.destinationViewController;
           simulationViewController.simulationData = [self gatherDataForSimulation];
       }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL should = YES;
    
    if([identifier isEqualToString:@"To Simulation"] && self.oilAmountNotChosen)
    {
        should = NO;
        
        NSArray *buttons = @[self.smallOil, self.smallMediumOil, self.mediumOil, self.mediumBigOil, self.bigOil];
        
        for(UIImageView *button in buttons)
        {
            [button startGlowingWithColor:[UIColor orangeColor] intensity:1.0];
        }
    }
    
    return should;
}

@end
