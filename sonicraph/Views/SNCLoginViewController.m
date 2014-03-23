//
//  SNCAuthenticationView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 12/9/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AuthenticationManager.h"
#import "TypeDefs.h"
#import "Configurations.h"
#import "SNCGoThroughViewController.h"


static SNCLoginViewController* sharedInstance = nil;

@implementation SNCLoginViewController

- (CGRect) titleLabelFrame
{
    return CGRectMake(0.0, 15.0, 320.0, 50.0);
}

- (CGRect) usernameFieldFrame
{
    return CGRectMake(0.0, 80.0, 320.0, 50.0);
}

- (CGRect) passwordFieldFrame
{
    return CGRectMake(0.0, 132.0, 320.0, 50.0);
}

- (CGRect) forgotPasswordFrame
{
    return CGRectMake(10.0, 200.0, 300.0, 50.0);
}

- (CGRect) loginButtonFrame
{
    return CGRectMake(10.0, 200.0, 300.0, 50.0);
}



+ (SNCLoginViewController *)sharedInstance
{
    if (sharedInstance == nil){
        sharedInstance = [[SNCLoginViewController alloc] init];
    }
    return sharedInstance;
}

- (void)viewDidLoad
{
//    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self.navigationController.navigationBar setHidden:NO];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:[self titleLabelFrame]];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel setText:@"Log in"];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:26.0]];
    
    self.usernameField = [[UITextField alloc] initWithFrame:[self usernameFieldFrame]];
    self.passwordField = [[UITextField alloc] initWithFrame:[self passwordFieldFrame]];
    
    [self.usernameField setPlaceholder:@"Username"];
    [self.passwordField setPlaceholder:@"Password"];
    
    [self.passwordField setSecureTextEntry:YES];
    
    [self.view addSubview:self.usernameField];
    for(UITextField* textField in @[self.usernameField,self.passwordField]){
        UIView* base = textFieldWithBaseAndLabel(textField);
        [textField setDelegate:self];
        [self.view addSubview:base];
    }
    
    [self.usernameField setPlaceholder:@"or e-mail"];
    
    [self.usernameField setReturnKeyType:UIReturnKeyNext];
    [self.passwordField setReturnKeyType:UIReturnKeyDone];
    
    self.forgotPassword = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotPassword setFrame:[self forgotPasswordFrame]];
    [self.forgotPassword setTitle:@"Forgot Password ? " forState:UIControlStateNormal];
    [self.view addSubview:self.forgotPassword];
    
    
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}


- (void) closeKeyboard
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameField)
    {
        [self.passwordField becomeFirstResponder];
    }
    else if(textField == self.passwordField)
    {
        [self.view endEditing:YES];
        [self login];
    }
    return YES;
}

 - (void) login
{
    [[AuthenticationManager sharedInstance]
     authenticateWithUsername:self.usernameField.text
     andPassword:self.passwordField.text
     shouldRemember:YES
     withCompletionBlock:^(User *user, NSString *token) {

     }
     andErrorBlock:^(NSError *error) {
         
     }];
}


@end
