//
//  SNCAPIConnector.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/6/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCAPIConnector.h"

@implementation SNCAPIConnector


+ (SNCAPIConnector *)sharedInstance
{
    static SNCAPIConnector* sharedInstance = nil;
    if(sharedInstance == nil){
        sharedInstance = [[SNCAPIConnector alloc] initWithHostName:@"sonicraph.herokuapp.com/api"];
//        sharedInstance = [[SNCAPIConnector alloc] initWithHostName:@"localhost:3000/api"];
    }
    return sharedInstance;
}

- (MKNetworkOperation *) postRequestWithParams:(NSDictionary*) params
                  andOperation:(NSString*) opearation
            andCompletionBlock:(CompletionBlock) completionBlock
                 andErrorBlock:(ErrorBlock) errorBlock
{
    
    MKNetworkOperation* op = [self requestWithMethod:@"POST"
                         andParams:params
                      andOperation:opearation
                andCompletionBlock:completionBlock
                     andErrorBlock:errorBlock];
    [self enqueueOperation:op];
    return op;
    
}

- (MKNetworkOperation *)getRequestWithParams:(NSDictionary *)params
                                andOperation:(NSString *)opearation
                          andCompletionBlock:(CompletionBlock)completionBlock
                               andErrorBlock:(ErrorBlock)errorBlock
{
    MKNetworkOperation* op = [self requestWithMethod:@"GET"
                         andParams:params
                      andOperation:opearation
                andCompletionBlock:completionBlock
                     andErrorBlock:errorBlock];
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)uploadFileRequestWithParams:(NSDictionary *)params andFiles:(NSArray *)files andOperation:(NSString *)opearation andCompletionBlock:(CompletionBlock)completionBlock andErrorBlock:(ErrorBlock)errorBlock
{
    MKNetworkOperation* op = [self requestWithMethod:@"POST"
                                           andParams:params
                                        andOperation:opearation
                                  andCompletionBlock:completionBlock
                                       andErrorBlock:errorBlock];
    for (NSDictionary* fileDict in files) {
        if([fileDict objectForKey:@"mime"]){
            [op addFile:[fileDict objectForKey:@"file"] forKey:[fileDict objectForKey:@"key"] mimeType:[fileDict objectForKey:@"mime"]];
        } else {
            [op addFile:[fileDict objectForKey:@"file"] forKey:[fileDict objectForKey:@"key"]];
        }
    }
    [self enqueueOperation:op];
    return op;
}

- (MKNetworkOperation *)requestWithMethod:(NSString*)method
                                andParams:(NSDictionary*)params
                             andOperation:(NSString*)operation
                       andCompletionBlock:(CompletionBlock)completionBlock
                            andErrorBlock:(ErrorBlock)errorBlock
{
    operation = [operation stringByAppendingString:@".json"];
    MKNetworkOperation* op = [self operationWithPath:operation
                                              params:params
                                          httpMethod:method];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSLog(@"response string: %@",[completedOperation responseString]);
        NSDictionary *responseDictionary = [completedOperation responseJSON];
        
        if([[responseDictionary valueForKey:@"error"] boolValue] == true){
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:[[responseDictionary objectForKey:@"error_code"] intValue]
                                                userInfo:@{NSLocalizedDescriptionKey : [responseDictionary valueForKey:@"error_description"]}];
            if(errorBlock != nil)
                errorBlock(apiError);
        }
        else{
            completionBlock(responseDictionary);
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (error.domain == NSURLErrorDomain && error.code == -1009) {
            NSError *connectionError = [NSError errorWithDomain:@"ConnectionError"
                                                           code:-102
                                                       userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"CONNECTION_ERROR", nil)}];
            if(errorBlock != nil)
                errorBlock(connectionError);
        } else {
            if(errorBlock != nil)
                errorBlock(error);
        }
    }];
    
    return op;
}




@end
