//
//  SNCHomeViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/12/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCHomeViewController.h"
#import "TypeDefs.h"
#import "Sonic.h"
#import "Configurations.h"
#import "SNCAPIManager.h"
#import "SNCSonicViewController.h"
#import "SonicArray.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SNCAppDelegate.h"
#import "SNCSplashView.h"

@interface SNCHomeViewController ()

@property SonicArray* sonics;

@property UIActivityIndicatorView* bottomActivityIndicator;
@property UIActivityIndicatorView* centerActivityIndicator;
@property UILabel* oops;

@end

@implementation SNCHomeViewController
{
    SNCHomeTableCell* cellWiningTheCenter;
    NSInteger indexOfCellToBeIncreased;
    Sonic* sonicToBeViewed;
    User* userToBeOpen;
    SonicViewControllerInitiationType sonicViewControllerInitiationType;
    BOOL isLoadingFromServer;
}

- (CGRect) tableFooterViewRect
{
    return CGRectMake(0.0, 0.0, 320.0, 11.0);
}

- (CGRect) oopsFrame
{
    return CGRectMake(0.0, self.view.frame.size.height*0.5 - 160.0, 320.0, 160.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SNCSplashView splash];
    indexOfCellToBeIncreased = -1;
    [self initTableView];
    [self initOops];
    [self initializeActivityIndicator];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_bar_logo.png"]];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(newSonicArrived:)
     name:NotificationNewSonicCreated
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(removeSonic:)
     name:NotificationSonicDeleted
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(userLoggedOut:)
     name:NotificationUserLoggedOut
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshFromServer)
     name:NotificationUserLoggedIn
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reachabilityChangedHandler:)
     name:kReachabilityChangedNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(scrollToTop)
     name:NotificationTabbarItemReSelected
     object:[NSNumber numberWithInt:0]];
    
    [self initRefreshController];
    [self refreshFromServer];
    

}

- (void) reachabilityChangedHandler:(NSNotification*)notification
{
//    Reachability* reachability = notification.object;
    
//    if(reachability.currentReachabilityStatus)
}

- (void) initTableView
{
    self.tableView.contentInset = [self edgeInsetsForScrollContent];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setScrollsToTop:YES];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[SNCHomeTableCell class] forCellReuseIdentifier:HomeTableCellIdentifier];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:[self tableFooterViewRect]]];
    [self.tableView setTableHeaderView:[UIView new]];
}

- (void) initOops
{
    self.oops = [[UILabel alloc] initWithFrame:[self oopsFrame]];
    self.oops.textColor = [UIColor lightGrayColor];
    self.oops.textAlignment = NSTextAlignmentCenter;
    self.oops.font = [UIFont boldSystemFontOfSize:15.0];
    self.oops.numberOfLines = 0;
    [self.oops setHidden:YES];
    self.oops.text = @"Oops!\n\nYou don't have any Sonic yet\n\n Follow and get followers\nit's fun with friends";
    [self.view addSubview:self.oops];
    
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc ] initWithString:self.oops.text];
    // for those calls we don't specify a range so it affects the whole string
    
    [attrStr setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]} range:NSMakeRange(0, 5)];
    // now we only change the color of "Hello"
    
    
    self.oops.attributedText = attrStr;
}

- (void) initializeActivityIndicator
{
    self.centerActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.centerActivityIndicator setColor:MainThemeColor];
    self.centerActivityIndicator.frame = CGRectMake(0.0, 0.0, 320.0, self.tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height - 33.0);
    [self.tableView addSubview:self.centerActivityIndicator];
    UILabel* label = [[UILabel alloc] init];
    [label setText:@"Loading sonics..."];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont boldSystemFontOfSize:14.0]];
    [label setTextColor:self.centerActivityIndicator.color];
    [label setFrame:CGRectMake(0.0, self.centerActivityIndicator.frame.size.height * 0.5 + 22.0, 320.0, 33.0)];
    [self.centerActivityIndicator addSubview:label];
    
    self.bottomActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.bottomActivityIndicator.frame = [self tableFooterViewRect];
    self.bottomActivityIndicator.color = MainThemeColor;
    [self.tableView.tableFooterView addSubview:self.bottomActivityIndicator];
}

- (void) initRefreshController
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = MainThemeColor;
    [self.refreshControl addTarget:self action:@selector(refreshFromServer) forControlEvents:UIControlEventValueChanged];
}

- (void) removeSonic:(NSNotification*)notification
{
    Sonic* sonic = notification.object;
    if([self.sonics deleteSonicWithId:sonic.sonicId]){
        [self refresh];
    }
}

- (void) scrollToTop
{
    [self.tableView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}

- (void) userLoggedOut:(NSNotification*)notification
{
    self.sonics = nil;
    [self.oops setHidden:YES];
    [self refresh];
}

- (void) newSonicArrived:(NSNotification*)notification
{
    [self.sonics addObject:notification.object];
    [self refresh];
    [self.oops setHidden:YES];
}

- (void) refreshFromServer
{
    isLoadingFromServer = YES;
    if(self.sonics == nil)
    {
        [self.centerActivityIndicator startAnimating];
    }
    [SNCAPIManager getSonicsAfter:nil withCompletionBlock:^(NSArray *sonics) {
//        sonics = @[];
        self.sonics = [[SonicArray alloc] init];
        [self.sonics importSonicsWithArray:sonics];
        [self.oops setHidden:(self.sonics.count > 0)];
        [self refresh];
        [self.refreshControl endRefreshing];
        isLoadingFromServer = NO;
        [self.centerActivityIndicator stopAnimating];
    } andErrorBlock:^(NSError *error) {
        [self.refreshControl endRefreshing];
        isLoadingFromServer = NO;
        [self.centerActivityIndicator stopAnimating];
    }];
}

- (void)sonic:(Sonic *)sonic actionFired:(SNCHomeTableCellActionType)actionType
{
    sonicToBeViewed = sonic;
    switch (actionType) {
        case SNCHomeTableCellActionTypeComment:
            sonicViewControllerInitiationType = SonicViewControllerInitiationTypeCommentWrite;
            break;
        case SNCHomeTableCellActionTypeOpenComments:
            sonicViewControllerInitiationType = SonicViewControllerInitiationTypeCommentRead;
            break;
        case SNCHomeTableCellActionTypeOpenLikes:
            sonicViewControllerInitiationType = SonicViewControllerInitiationTypeLikeRead;
            break;
        case SNCHomeTableCellActionTypeOpenResonics:
            sonicViewControllerInitiationType = SonicViewControllerInitiationTypeResonicRead;
            break;
        default:
            break;
    }
    [self performSegueWithIdentifier:ViewSonicSegue sender:self];
}

- (void) refresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopPlaying];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.sonics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = HomeTableCellIdentifier;
    SNCHomeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Sonic* sonic = [self.sonics objectAtIndex:indexPath.row];
    if(sonic != cell.sonic){
        [cell setSonic:[self.sonics objectAtIndex:indexPath.row]];
        cell.delegate = self;
    }
    return cell;
}

- (void) stopPlaying
{
    for(SNCHomeTableCell* cell in [self.tableView visibleCells])
    {
        [cell cellLostCenterOfTableView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self stopPlaying];
    if(!isLoadingFromServer && self.sonics.count > 0 && scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.frame.size.height) < 20.0)
    {
        isLoadingFromServer = YES;
        [self.bottomActivityIndicator startAnimating];
        [SNCAPIManager getSonicsBefore:self.sonics.lastObject withCompletionBlock:^(NSArray *sonics) {
            [self.sonics importSonicsWithArray:sonics];
            [self.bottomActivityIndicator stopAnimating];
            if(sonics.count > 0)
            {
                isLoadingFromServer = NO;
            }
            [self refresh];
        } andErrorBlock:^(NSError *error) {
            [self.bottomActivityIndicator stopAnimating];
            isLoadingFromServer = NO;
            [self refresh];
        }];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == indexOfCellToBeIncreased){
        return HeightForHomeCell + 44.0;
    }
    return HeightForHomeCell;
}

- (void) openProfileForUser:(User *)user
{
    userToBeOpen = user;
    [self performSegueWithIdentifier:ViewUserSegue sender:self];
}
- (void)openSonicDetails:(Sonic *)sonic
{
    sonicToBeViewed = sonic;
    sonicViewControllerInitiationType = SonicViewControllerInitiationTypeNone;
    [self performSegueWithIdentifier:ViewSonicSegue sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:ViewSonicSegue]){
        SNCSonicViewController* sonicViewController =  segue.destinationViewController;
        [sonicViewController setSonic:sonicToBeViewed];
        [sonicViewController initiateFor:sonicViewControllerInitiationType];
    }
    else if([segue.identifier isEqualToString:ViewUserSegue]){
        SNCProfileViewController* profile = segue.destinationViewController;
        [profile setUser:userToBeOpen];
    }
}


@end
