//
//  MKJAFNetWorkHelp.m
//  Higo专题页面
//
//  Created by 宓珂璟 on 16/6/17.
//  Copyright © 2016年 宓珂璟. All rights reserved.
//

#import "MKJAFNetWorkHelp.h"
#import <AFNetworking.h>
#import <AFHTTPSessionManager.h>
#import <MJExtension.h>
#import "MKJModel.h"


@implementation MKJAFNetWorkHelp

+ (MKJAFNetWorkHelp *)shareRequest
{
    static MKJAFNetWorkHelp *mkjNet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mkjNet = [[MKJAFNetWorkHelp alloc] init];
    });
    return mkjNet;
}

- (void)MKJGETRequest:(NSString *)requestURL page:(NSInteger)page parameters:(NSDictionary *)parameters succeed:(completionBlock)succeedBlock failure:(completionBlock)failureBlock
{
    AFHTTPSessionManager *man = [AFHTTPSessionManager manager];
    man.responseSerializer = [AFJSONResponseSerializer serializer];
    man.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [man GET:requestURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [SubGroupList mj_setupObjectClassInArray:^NSDictionary *{
            return @{@"list" : @"DetailList",@"role":@"DetailList"};
        }];
        
        GroupList *list = [GroupList mj_objectWithKeyValues:responseObject];
        
        
        if (succeedBlock) {
            succeedBlock(nil,list);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error,nil);
        }
        
    }];
    
    
}


@end
