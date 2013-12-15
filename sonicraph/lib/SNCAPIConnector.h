//
//  SNCAPIConnector.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/6/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkKit.h"


typedef void (^CompletionBlock) (NSDictionary *responseDictionary);
typedef void (^Block) ();
typedef void (^ErrorBlock) (NSError *error);

@interface SNCAPIConnector : MKNetworkEngine

+ (SNCAPIConnector*) sharedInstance;


- (MKNetworkOperation *) postRequestWithParams:(NSDictionary*) params
                                  andOperation:(NSString*)opearation
                            andCompletionBlock:(CompletionBlock) completionBlock
                                 andErrorBlock:(ErrorBlock)errorBlock;

- (MKNetworkOperation*) getRequestWithParams:(NSDictionary*) params
                                andOperation:(NSString*)opearation
                          andCompletionBlock:(CompletionBlock) completionBlock
                               andErrorBlock:(ErrorBlock)errorBlock;

- (MKNetworkOperation*) uploadFileRequestWithParams:(NSDictionary*) params
                                           andFiles:(NSArray*) files
                                       andOperation:(NSString*)opearation
                                 andCompletionBlock:(CompletionBlock) completionBlock
                                      andErrorBlock:(ErrorBlock)errorBlock;


@end