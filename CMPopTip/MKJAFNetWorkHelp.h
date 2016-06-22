//
//  MKJAFNetWorkHelp.h
//  Higo专题页面
//
//  Created by 宓珂璟 on 16/6/17.
//  Copyright © 2016年 宓珂璟. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completionBlock)(NSError *err,id obj);

@interface MKJAFNetWorkHelp : NSObject

+ (MKJAFNetWorkHelp *)shareRequest;

// 网络请求
- (void)MKJGETRequest:(NSString *)requestURL page:(NSInteger)page parameters:(NSDictionary *)parameters succeed:(completionBlock)succeedBlock failure:(completionBlock)failureBlock;


@end
