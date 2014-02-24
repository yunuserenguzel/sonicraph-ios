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
#define AuthenticationManagerUserDefaultsTokenKey @"AuthenticationManagerUserDefaultsTokenKey"
#define AuthenticationManagerUserDefaultsUserKey @"AuthenticationManagerUserDefaultsUserKey"

static AuthenticationManager* sharedInstance = nil;

@implementation AuthenticationManager
{
    NSString* _token;
    User* _authenticatedUser;
    NSString* _password;
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
    }
    return self;
}


- (void)registerUserWithEmail:(NSString *)email andUsername:(NSString *)username andPassword:(NSString *)password andCompletionBlock:(CompletionUserBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    [SNCAPIManager registerWithUsername:username email:email password:password andCompletionBlock:^(User *user, NSString *token) {
        self.token = token;
        self.authenticatedUser = user;
        _isUserAuthenticated = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUserLoggedIn object:nil];
        });
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
        self.token = token;
        self.authenticatedUser = user;
        _isUserAuthenticated = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUserLoggedIn object:user];
        });
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
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)logout
{
    [SNCAPIManager destroyAuthenticationWithCompletionBlock:^(NSDictionary *responseDictionary) {
        [self setToken:nil];
        [self setAuthenticatedUser:nil];
        
        [self checkAuthentication];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:NotificationUserLoggedOut
         object:nil];
    } andErrorBlock:nil];
    
}

- (void) checkAuthentication
{
//    Actual Code
    if(self.token == nil){
        [self displayAuthenticationView];
    }
}

- (void) displayAuthenticationView
{
    UITabBarController* tabbarController = [[SNCAppDelegate sharedInstance] tabbarController];
    [[tabbarController viewControllers] enumerateObjectsUsingBlock:^(UINavigationController* navController, NSUInteger idx, BOOL *stop) {
        [navController popToRootViewControllerAnimated:NO];
    }];
    
    [tabbarController performSegueWithIdentifier:TabbarToLoginRegisterSegue sender:tabbarController];
}

@end
