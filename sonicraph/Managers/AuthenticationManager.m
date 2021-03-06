//
//  AuthenticationManager.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/1/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "AuthenticationManager.h"
#import "SNCAppDelegate.h"
#import "SNCLoginViewController.h"
#import "TypeDefs.h"
#import "UserPool.h"
#import "SNCEditProfileViewController.h"
#import "SNCGoThroughViewController.h"
#import "SNCNavigationViewController.h"


#define AuthenticationManagerUserDefaultsTokenKey @"AuthenticationManagerUserDefaultsTokenKey"
#define AuthenticationManagerUserDefaultsUserKey @"AuthenticationManagerUserDefaultsUserKey"
static AuthenticationManager* sharedInstance = nil;

@implementation AuthenticationManager
{
    NSString* _token;
    User* _authenticatedUser;
    NSString* _password;
    UIViewController* goThrough;
}
+ (AuthenticationManager *)sharedInstance
{
    if(sharedInstance == nil){
        sharedInstance = [[AuthenticationManager alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(self = [super init]){
        if(self.token){
            _isUserAuthenticated = YES;
        }else {
            _isUserAuthenticated = NO;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:NotificationUpdateViewForUser object:self.authenticatedUser];
    }
    return self;
}

- (void) updateUser:(NSNotification*)notification
{
    User* user = notification.object;
    if([user.userId isEqualToString:self.authenticatedUser.userId])
    {
        [self setAuthenticatedUser:notification.object];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkUsernameAndFullname];
    });
}
- (void) initializeSessionWithToken:(NSString*)token andUser:(User*)user
{
    [self clearThirdPartyAppLogins];
    [SNCAPIConnector destorySharedInstance];
    self.token = token;
    self.authenticatedUser = user;
    _isUserAuthenticated = YES;
    [[SNCAppDelegate sharedInstance] updateDeviceToken];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUserLoggedIn object:user];
        [self displayApplicationView];
        
    });
    
}
- (void)registerUserWithEmail:(NSString *)email andPassword:(NSString *)password andCompletionBlock:(CompletionUserBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    [SNCAPIManager registerWithEmail:email password:password andCompletionBlock:^(User *user, NSString *token) {
        [self initializeSessionWithToken:token andUser:user];
        if(completionBlock){
            completionBlock(user,token);
        }
    } andErrorBlock:^(NSError *error) {
        if(error.code == 300){
            _isUserAuthenticated = NO;
        }
        if(errorBlock){
            errorBlock(error);
        }
    }];
}


- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                  shouldRemember:(BOOL)shouldRemember
             withCompletionBlock:(CompletionUserBlock)block
                   andErrorBlock:(ErrorBlock)errorBlock
{
    
    [SNCAPIManager loginWithUsername:username andPassword:password withCompletionBlock:^(User *user,NSString* token) {
        NSLog(@"%@",user);
        [self initializeSessionWithToken:token andUser:user];
        if(block){
            block( user, token );
        }
    } andErrorBlock:^(NSError *error) {
        if(error.code == 300){
            _isUserAuthenticated = NO;
        }
        if( errorBlock ){
            errorBlock( error );
        }
        NSLog(@"%@", error );
    }];
}



- (void)setToken:(NSString *)token
{
    _token = token;
    [self saveToUserDefaults:token forKey:AuthenticationManagerUserDefaultsTokenKey];

}

- (NSString *)token
{
    if(_token == nil){
        _token = [[NSUserDefaults standardUserDefaults] stringForKey:AuthenticationManagerUserDefaultsTokenKey];
    }
    return _token;
}


- (void)setAuthenticatedUser:(User *)authenticatedUser
{
    if(_authenticatedUser != authenticatedUser){
        _authenticatedUser = authenticatedUser;
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:_authenticatedUser];
        [self saveToUserDefaults:encodedObject forKey:AuthenticationManagerUserDefaultsUserKey];
    }
}

- (User *)authenticatedUser
{
    if(self.token == nil){
        return nil;
    }
    if(_authenticatedUser == nil){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:AuthenticationManagerUserDefaultsUserKey];
        _authenticatedUser = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        User* user = [[UserPool sharedPool] userForId:_authenticatedUser.userId];
        if(user){
            _authenticatedUser = user;
        } else {
            [[UserPool sharedPool] addOrUpdateUser:_authenticatedUser];
            [SNCAPIManager checkIsTokenValid:self.token withCompletionBlock:^(User *user, NSString *token) {
                
            } andErrorBlock:^(NSError *error) {
                
            }];
        }
    }
    
    return _authenticatedUser;
}

- (void) saveToUserDefaults:(id)value forKey:(NSString*)key
{
    if(value == nil)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) clearThirdPartyAppLogins
{
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    
}

- (void)logout
{
    [self setToken:nil];
    [self setAuthenticatedUser:nil];
//    [self checkAuthentication];
    [self displayAuthenticationView];
    [self clearThirdPartyAppLogins];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NotificationUserLoggedOut
     object:nil];
    [SNCAPIConnector destorySharedInstance];
    [SNCAPIManager destroyAuthenticationWithCompletionBlock:nil andErrorBlock:nil];
    
}

//- (void) checkAuthentication
//{
////    Actual Code
//    if(self.token == nil){
//        [self displayAuthenticationView];
//    }
//}

- (void) checkUsernameAndFullname
{
    if (self.authenticatedUser.username == nil || self.authenticatedUser.username.length == 0 || self.authenticatedUser.fullName == nil || self.authenticatedUser.fullName.length == 0)
    {
        [self editProfileView];
    }
}

- (void) editProfileView
{
    SNCNavigationViewController* navigationController = [[SNCNavigationViewController alloc] init];
    SNCEditProfileForRegistrationViewController* editProfile = [[SNCEditProfileForRegistrationViewController alloc] init];
    [navigationController pushViewController:editProfile animated:YES];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:navigationController animated:YES completion:nil];
}

- (void) displayApplicationView
{
    [goThrough dismissViewControllerAnimated:YES completion:^{
        [self checkUsernameAndFullname];
    }];
    UITabBarController* tabbar = (UITabBarController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [tabbar setSelectedIndex:0];
}

- (void) displayAuthenticationView
{
    goThrough = [SNCGoThroughViewController create];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:goThrough animated:YES completion:nil];
}

@end
