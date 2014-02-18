//
//  SNCAPIManager.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/5/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCAPIManager.h"
#import "JSONKit.h"
#import "SonicData.h"
#import "TypeDefs.h"
#import "User.h"
#import "AuthenticationManager.h"
#import "UserPool.h"

id asClass(id object, Class class)
{
    return [object isKindOfClass:class] ? object : nil;
}

NSDate* dateFromServerString(NSString* dateString)
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    return [dateFormatter dateFromString:dateString];
}

SonicComment* sonicCommentFromServerDictionary(NSDictionary* dictionary)
{
    if(dictionary == nil || [dictionary isKindOfClass:[NSNull class]]){
        return nil;
    }
    SonicComment* sonicComment = [[SonicComment alloc] init];
    sonicComment.commentId = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"id"]];
    sonicComment.text = [dictionary objectForKey:@"text"];
    sonicComment.createdAt = dateFromServerString(asClass([dictionary objectForKey:@"created_at"], [NSString class]));
    sonicComment.user = userFromServerDictionary([dictionary objectForKey:@"user"]);
    return sonicComment;
}


User* userFromServerDictionary(NSDictionary* dictionary)
{
    if(dictionary == nil || [dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    User* user = [[User alloc] init];
    user.userId = [dictionary objectForKey:@"id"];
    user.isBeingFollowed = [[dictionary objectForKey:@"is_being_followed"] boolValue];
    user.username = asClass([dictionary objectForKey:@"username"], [NSString class]);
    user.fullName = asClass([dictionary objectForKey:@"fullname"], [NSString class]);
    user.profileImageUrl = asClass([dictionary objectForKey:@"profile_image"], [NSString class]);
    user.website = asClass([dictionary objectForKey:@"website"], [NSString class]);
    user.location = asClass([dictionary objectForKey:@"location"], [NSString class]);
    user.sonicCount = [asClass([dictionary objectForKey:@"sonic_count"], [NSNumber class]) integerValue];
    user.followerCount = [asClass([dictionary objectForKey:@"follower_count"], [NSNumber class]) integerValue];
    user.followingCount = [asClass([dictionary objectForKey:@"following_count"], [NSNumber class]) integerValue];
    return [[UserPool sharedPool] addOrUpdateUser:user];
    
}

Sonic* sonicFromServerDictionary(NSDictionary* sonicDict)
{
    if(sonicDict == nil || [sonicDict isKindOfClass:[NSNull class]]){
        return nil;
    }
    NSDictionary* userDict = [sonicDict objectForKey:@"user"];
    User* user = userFromServerDictionary(userDict);
    Sonic* sonic = [[Sonic alloc] init];
    sonic.sonicId = asClass([sonicDict objectForKey:@"id"], [NSString class]);
    sonic.sonicUrl = asClass([sonicDict objectForKey:@"sonic_data"], [NSString class]);
    sonic.tags = asClass([sonicDict objectForKey:@"tags"], [NSString class]);
    sonic.latitude = [asClass([sonicDict objectForKey:@"latitude"], [NSNumber class]) floatValue];
    sonic.longitude= [asClass([sonicDict objectForKey:@"longitude"],[NSNumber class]) floatValue];
    sonic.isPrivate = [asClass([sonicDict objectForKey:@"is_private" ], [NSNumber class]) boolValue];
    sonic.creationDate = dateFromServerString(asClass([sonicDict objectForKey:@"created_at"], [NSString class]));
    sonic.owner = user;
    sonic.likeCount = [asClass([sonicDict objectForKey:@"likes_count"], [NSNumber class]) integerValue];
    sonic.resonicCount = [asClass([sonicDict objectForKey:@"resonics_count"], [NSNumber class]) integerValue];
    sonic.commentCount = [asClass([sonicDict objectForKey:@"comments_count"], [NSNumber class]) integerValue];
    sonic.isLikedByMe = [asClass([sonicDict objectForKey:@"liked_by_me"], [NSNumber class]) boolValue];
    sonic.isResonicedByMe = [asClass([sonicDict objectForKey:@"resoniced_by_me"], [NSNumber class]) boolValue];
    sonic.isResonic = [asClass([sonicDict objectForKey:@"is_resonic"], [NSNumber class]) boolValue];
    if(sonic.isResonic){
        sonic.originalSonic = sonicFromServerDictionary([sonicDict objectForKey:@"original_sonic"]);
    }
    return sonic;
}
Notification* notificationFromServerDictionary(NSDictionary* dict)
{
    Notification* notification = [[Notification alloc] init];
    notification.notificationId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    notification.notificationType = notificationTypeFromString([dict objectForKey:@"notification_type"]);
    notification.isRead = [asClass([dict objectForKey:@"is_read" ], [NSNumber class]) boolValue];
    notification.createdAt = dateFromServerString(asClass([dict objectForKey:@"created_at"], [NSString class]));
    notification.byUser = userFromServerDictionary([dict objectForKey:@"by_user"]);
    notification.toSonic = sonicFromServerDictionary([dict objectForKey:@"to_sonic"]);
    notification.sonicComment = sonicCommentFromServerDictionary([dict objectForKey:@"comment"]);
    return notification;
}

@implementation SNCAPIManager

 + (MKNetworkOperation *)editProfileWithFields:(NSDictionary *)fields withCompletionBlock:(CompletionUserBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    return nil;
}

+ (MKNetworkOperation *)getNotificationsWithCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    return [[SNCAPIConnector sharedInstance] getRequestWithParams:@{} useToken:YES andOperation:@"noitifications/get_last_notifications" andCompletionBlock:^(NSDictionary *responseDictionary) {
        NSMutableArray* notifications = [NSMutableArray new];
        [[responseDictionary objectForKey:@"notifications"] enumerateObjectsUsingBlock:^(NSDictionary* dict, NSUInteger idx, BOOL *stop) {
            [notifications addObject:notificationFromServerDictionary(dict)];
       }];
        if(completionBlock){
            completionBlock(notifications);
        }
    } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getSonicsWithSearchQuery:(NSString *)query withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"query": query};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/search"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* sonics = [NSMutableArray new];
                [[responseDictionary objectForKey:@"sonics"] enumerateObjectsUsingBlock:^(NSDictionary* sonicDict, NSUInteger idx, BOOL *stop) {
                    Sonic* sonic = sonicFromServerDictionary(sonicDict);
                    [sonics addObject:sonic];
                }];
                if(completionBlock){
                    completionBlock(sonics);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getUsersWithSearchQuery:(NSString *)query withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"query": query};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"user/search"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* users = [NSMutableArray new];
                [[responseDictionary objectForKey:@"users"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
                    User* user = userFromServerDictionary(userDict);
                    [users addObject:user];
                }];
                if(completionBlock){
                    completionBlock(users);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)followUser:(User *)user withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"user": user.userId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"user/follow"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                userFromServerDictionary([responseDictionary objectForKey:@"authenticated_user"]);
                if(completionBlock){
                    completionBlock(YES);
                }
            } andErrorBlock:errorBlock];
}
+ (MKNetworkOperation *)unfollowUser:(User *)user withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"user": user.userId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"user/unfollow"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                userFromServerDictionary([responseDictionary objectForKey:@"authenticated_user"]);
                if(completionBlock){
                    completionBlock(YES);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getFollowingsOfUser:(User *)user withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"user" : user.userId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"user/followings"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* users = [[NSMutableArray alloc] init];
                [[responseDictionary objectForKey:@"followings"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
                    [users addObject:userFromServerDictionary(userDict)];
                }];
                if(completionBlock){
                    completionBlock(users);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getFollowersOfUser:(User *)user withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"user" : user.userId};
    return  [[SNCAPIConnector sharedInstance]
             getRequestWithParams:params
             useToken:YES
             andOperation:@"user/followers"
             andCompletionBlock:^(NSDictionary *responseDictionary) {
                 NSMutableArray* users = [[NSMutableArray alloc] init];
                 [[responseDictionary objectForKey:@"followers"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
                     [users addObject:userFromServerDictionary(userDict)];
                 }];
                 if(completionBlock){
                     completionBlock(users);
                 }
             } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getCommentsOfSonic:(Sonic *)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/comments"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* comments = [NSMutableArray new];
                [[responseDictionary objectForKey:@"comments"] enumerateObjectsUsingBlock:^(NSDictionary* commentDict, NSUInteger idx, BOOL *stop) {
                    SonicComment* comment = sonicCommentFromServerDictionary(commentDict);
                    comment.sonic = sonic;
                    [comments addObject:comment];
                }];
                if(completionBlock){
                    completionBlock(comments);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)writeCommentToSonic:(Sonic *)sonic withText:(NSString *)text withCompletionBlock:(CompletionIdBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId,
                             @"text": text};
    return [[SNCAPIConnector sharedInstance]
            postRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/write_comment"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                SonicComment* sonicComment = sonicCommentFromServerDictionary([responseDictionary objectForKey:@"comment"]);
                sonicComment.sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
                sonicComment.user = [[AuthenticationManager sharedInstance] authenticatedUser];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:NotificationUpdateSonic
                 object:sonicComment.sonic];
                if(completionBlock){
                    completionBlock(sonicComment);
                }
            }
            andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)deleteComment:(SonicComment *)sonicComment withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"comment": sonicComment.commentId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/delete_comment"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:NotificationCommentDeleted
                 object:sonicComment];
                if(completionBlock){
                    completionBlock(YES);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*) deleteSonic:(Sonic*)sonic withCompletionBlock:(CompletionBoolBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/delete_sonic"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSonicDeleted object:sonic];
                if(completionBlock){
                    completionBlock(YES);
                }
    } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*) likeSonic:(Sonic*)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/like_sonic"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdateSonic object:sonic];
                if(completionBlock){
                    completionBlock(sonic);
                }
    } andErrorBlock:errorBlock];
}
+ (MKNetworkOperation*) dislikeSonic:(Sonic*)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/dislike_sonic"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdateSonic object:sonic];
                if(completionBlock){
                    completionBlock(sonic);
                }
    } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)resonicSonic:(Sonic *)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic":sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params useToken:YES andOperation:@"sonic/resonic" andCompletionBlock:^(NSDictionary *responseDictionary) {
                Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
                if(completionBlock){
                    completionBlock(sonic);
                }
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)deleteResonic:(Sonic *)sonic withCompletionBlock:(CompletionSonicBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic": sonic.sonicId};
    return  [[SNCAPIConnector sharedInstance]
             getRequestWithParams:params useToken:YES andOperation:@"sonic/delete_resonic" andCompletionBlock:^(NSDictionary *responseDictionary) {
                 Sonic* sonic = sonicFromServerDictionary([responseDictionary objectForKey:@"sonic"]);
                 if(completionBlock){
                     completionBlock(sonic);
                 }
                 
             } andErrorBlock:errorBlock];
}
+(MKNetworkOperation *)createSonic:(SonicData *)sonic withTags:(NSString *)tags withCompletionBlock:(CompletionSonicBlock)completionBlock
{
    NSString* sonicData = [[sonic dictionaryFromSonicData] JSONString];
    NSString* tempFile = [SonicData filePathWithId:@"temp_sonic"];
    NSError* error;
    [sonicData writeToFile:tempFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSString* operation = @"sonic/create_sonic";
    return [[SNCAPIConnector sharedInstance]
            uploadFileRequestWithParams:@{@"tags":tags,
                                          @"latitude":[NSNumber numberWithFloat:sonic.latitude],
                                          @"longitude":[NSNumber numberWithFloat:sonic.longitude]}
            useToken:YES
            andFiles:@[@{@"file":tempFile,@"key":@"sonic_data"}]
            andOperation:operation
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSDictionary* sonicDict = [responseDictionary objectForKey:@"sonic"];
                Sonic* sonic = sonicFromServerDictionary(sonicDict);
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:NotificationNewSonicCreated
                 object:sonic];
                if(completionBlock){
                    completionBlock(sonic);
                }
            }
            andErrorBlock:^(NSError *error) {
                
            }];
}

+ (void) getUserSonics:(User*)user saveToDatabase:(BOOL)saveToDatabase withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSNumber* count = [NSNumber numberWithInt:20];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if(user != nil){
        [params setObject:user.userId forKey:@"of_user"];
    }
    [params setObject:count forKey:@"count"];
    [SNCAPIManager getSonicsWithParams:params
                   withCompletionBlock:completionBlock
                         andErrorBlock:errorBlock];
}
//
//+ (void) getSonicsBefore:(Sonic*)sonic withCompletionBlock:(Block)completionBlock
//{
//    NSNumber* count = [NSNumber numberWithInt:20];
//    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
//    [params setObject:token forKey:@"token"];
//    if(sonic != nil){
//        [params setObject:sonic.sonicId forKey:@"before_sonic"];
//    }
//    [params setObject:count forKey:@"count"];
//    [SNCAPIManager getSonicsWithParams:params saveToDatabase:YES withCompletionBlock:completionBlock andErrorBlock:nil];
//}
//

+ (MKNetworkOperation *)getSonicsILikedwithCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"me_liked"];
    return [SNCAPIManager getSonicsWithParams:params
                          withCompletionBlock:completionBlock
                                andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*) getSonicsAfter:(Sonic*)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSNumber* count = [NSNumber numberWithInt:20];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if(sonic != nil){
        [params setObject:sonic.sonicId forKey:@"after_sonic"];
    }
    [params setObject:count forKey:@"count"];
    
    return [SNCAPIManager getSonicsWithParams:params
                          withCompletionBlock:completionBlock
                                andErrorBlock:errorBlock];
}

+ (MKNetworkOperation*)getSonicsWithParams:(NSMutableDictionary *)params
                       withCompletionBlock:(CompletionArrayBlock)completionBlock
                             andErrorBlock:(ErrorBlock)errorBlock
{
    NSString* operation = @"sonic/get_sonics";
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:operation
            andCompletionBlock:^(NSDictionary *responseDictionary) {
             NSMutableArray* sonics = [[NSMutableArray alloc] init];
             for (NSDictionary* sonicDict in [responseDictionary objectForKey:@"sonics"]) {
                 [sonics addObject:sonicFromServerDictionary(sonicDict)];
             }
             if(completionBlock){
                 completionBlock(sonics);
             }
            }
            andErrorBlock:errorBlock];
}


+ (void) getImage:(NSURL*)imageUrl withCompletionBlock:(CompletionIdBlock)completionBlock
{
    NSString* localFileUrl = [[SNCAPIManager imageCacheDirectory] stringByAppendingPathComponent:imageUrl.lastPathComponent];
    Block dispatchBlock = ^ {
        @autoreleasepool {
            if(![[NSFileManager defaultManager] fileExistsAtPath:localFileUrl]){
                NSData* data = [NSData dataWithContentsOfURL:imageUrl];
                [data writeToFile:localFileUrl atomically:YES];
                data = nil;
            }
            NSData* data = [NSData dataWithContentsOfFile:localFileUrl];
            UIImage* image = [UIImage imageWithData:data];
            completionBlock(image);
            data = nil;
        
        }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),dispatchBlock);
}

+ (void) getSonic:(NSURL*)sonicUrl withSonicBlock:(SonicBlock)sonicBlock
{
    NSString* localFileUrl = [[SNCAPIManager sonicCacheDirectory] stringByAppendingPathComponent:sonicUrl.lastPathComponent];
    Block dispatchBlock = ^ {
        @autoreleasepool {
            if(![[NSFileManager defaultManager] fileExistsAtPath:localFileUrl]){
                [[NSString stringWithContentsOfURL:sonicUrl encoding:NSUTF8StringEncoding error:nil] writeToFile:localFileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            SonicData* sonic = [SonicData sonicDataFromFile:localFileUrl];
            sonic.remoteSonicDataFileUrl = sonicUrl;
            sonicBlock(sonic,nil);
         }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),dispatchBlock);
}

+ (NSString*) sonicCacheDirectory
{
    static NSString* cacheFolder = nil;
    if(cacheFolder == nil)
    {
        cacheFolder = [SNCAPIManager getAndcreateFolderAtApplicationDirectory:@"cached_sonics"];
    }
    return cacheFolder;
}

+ (NSString*) imageCacheDirectory
{
    static NSString* cacheFolder = nil;
    if(cacheFolder == nil)
    {
        cacheFolder = [SNCAPIManager getAndcreateFolderAtApplicationDirectory:@"cached_images"];
    }
    return cacheFolder;
}

+ (NSString*) getAndcreateFolderAtApplicationDirectory:(NSString*)folderName
{
    NSString* cacheFolder;
    NSError* error;
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    cacheFolder = [[dirs objectAtIndex:0] stringByAppendingPathComponent:folderName];
    [[NSFileManager defaultManager]
     createDirectoryAtPath:cacheFolder
     withIntermediateDirectories:YES
     attributes:nil
     error:&error];
    if(error)
    {
        NSLog(@"[SNCAPIManager.m %d] %@",__LINE__,error);
    }
    [[NSURL fileURLWithPath:cacheFolder]
     setResourceValue:[NSNumber numberWithBool:YES]
     forKey:NSURLIsExcludedFromBackupKey
     error:&error];
    if(error)
    {
        NSLog(@"[SNCAPIManager.m %d] %@",__LINE__,error);
    }
    return cacheFolder;
}

+ (MKNetworkOperation*) checkIsTokenValid:(NSString*)token withCompletionBlock:(CompletionUserBlock)block andErrorBlock:(ErrorBlock)errorBlock;
{
    return [[SNCAPIConnector sharedInstance]
     getRequestWithParams:@{@"token": token}
     useToken:NO
     andOperation:@"user/check_is_token_valid"
     andCompletionBlock:^(NSDictionary *responseDictionary) {
         User* user = userFromServerDictionary([responseDictionary objectForKey:@"user"]);
         if(block != nil){
             block(user,nil);
         }
     }
     andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *) loginWithUsername:(NSString*) username andPassword:(NSString*)password withCompletionBlock:(CompletionUserBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"username": username,
                             @"password": password};
    
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:NO
            andOperation:@"user/login"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSString* token = [responseDictionary objectForKey:@"token"];
                User* user = userFromServerDictionary([responseDictionary objectForKey:@"user"]);
                if(completionBlock != nil){
                    completionBlock(user,token);
                }
    } andErrorBlock:errorBlock];
}


+ (MKNetworkOperation *)registerWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password andCompletionBlock:(CompletionUserBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"username": username,
                             @"email":email,
                             @"password":password};
    return [[SNCAPIConnector sharedInstance]
            postRequestWithParams:params
            useToken:NO
            andOperation:@"user/register"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSString* token = [responseDictionary objectForKey:@"token"];
                User* user = userFromServerDictionary([responseDictionary objectForKey:@"user"]);
                if(completionBlock != nil){
                    completionBlock(user,token);
                }
            } andErrorBlock:errorBlock];
}



+ (MKNetworkOperation *)getLikesOfSonic:(Sonic *)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    
    NSDictionary* params = @{@"sonic":sonic.sonicId};
    
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/likes"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* users = [[NSMutableArray alloc] init];
                [[responseDictionary objectForKey:@"users"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
                    NSLog(@"%@",responseDictionary);
                    [users addObject:userFromServerDictionary(userDict)];
//                    [users addObject:[User userWithId:[userDict objectForKey:@"id"] andUsername:[userDict objectForKey:@"username"] andFullname:[userDict objectForKey:@"fullname"] andProfileImage:[userDict objectForKey:@"profile_image"]]];
                }];
                completionBlock(users);
            } andErrorBlock:errorBlock];
}

+ (MKNetworkOperation *)getResonicsOfSonic:(Sonic *)sonic withCompletionBlock:(CompletionArrayBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary* params = @{@"sonic":sonic.sonicId};
    return [[SNCAPIConnector sharedInstance]
            getRequestWithParams:params
            useToken:YES
            andOperation:@"sonic/resonics"
            andCompletionBlock:^(NSDictionary *responseDictionary) {
                NSMutableArray* users = [[NSMutableArray alloc] init];
                [[responseDictionary objectForKey:@"users"] enumerateObjectsUsingBlock:^(NSDictionary* userDict, NSUInteger idx, BOOL *stop) {
                    NSLog(@"%@",responseDictionary);
                    [users addObject:userFromServerDictionary(userDict)];
                    //                    [users addObject:[User userWithId:[userDict objectForKey:@"id"] andUsername:[userDict objectForKey:@"username"] andFullname:[userDict objectForKey:@"fullname"] andProfileImage:[userDict objectForKey:@"profile_image"]]];
                }];
                completionBlock(users);
            } andErrorBlock:errorBlock];

}


@end






