//
//  SNCAPIManager.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/5/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SonicData.h"
#import "SNCAPIConnector.h"

typedef void (^CompletionArrayBlock) (NSArray *sonics);
typedef void (^CompletionUserBlock) (User *user,NSString* token);
typedef void (^CompletionBoolBlock) (BOOL successful);
typedef void (^CompletionSonicBlock) (Sonic* sonic);


@interface SNCAPIManager : NSObject

+ (void) createSonic:(SonicData *)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock;

+ (void) getUserSonics:(User*)user saveToDatabase:(BOOL)saveToDatabase withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock;

+ (void) getSonicsBefore:(SonicManagedObject*)sonicManagedObject withCompletionBlock:(Block)completionBlock;

+ (void) getSonicsAfter:(SonicManagedObject*)sonicManagedObject withCompletionBlock:(Block)completionBlock;

+ (void)getSonicsWithParams:(NSMutableDictionary *)params saveToDatabase:(BOOL)saveToDatabase withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock;

+ (void) getSonic:(NSURL*)sonicUrl withSonicBlock:(SonicBlock)sonicBlock;

+ (void) checkIsTokenValid:(NSString*)token withCompletionBlock:(CompletionUserBlock)block andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation *) registerWithUsername:(NSString*)username
                                        email:(NSString*)email
                                     password:(NSString*)password
                           andCompletionBlock:(CompletionBlock)completionBlock
                                andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation *) loginWithUsername:(NSString*) username
                               andPassword:(NSString*)password
                       withCompletionBlock:(CompletionUserBlock)completionBlock
                             andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation *) validateWithEmail:(NSString*)email
                         andValidationCode:(NSString*)validationCode
                       withCompletionBlock:(CompletionBoolBlock)completionBlock
                             andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) likeSonic:(Sonic*)sonic
              withCompletionBlock:(CompletionSonicBlock)completionBlock
                    andErrorBlock:(ErrorBlock)errorBlock;

+ (MKNetworkOperation*) dislikeSonic:(Sonic*)sonic
                 withCompletionBlock:(CompletionSonicBlock)completionBlock
                       andErrorBlock:(ErrorBlock)errorBlock;

@end