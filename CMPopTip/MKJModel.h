//
//  MKJModel.h
//  CMPopTip
//
//  Created by 宓珂璟 on 16/6/22.
//  Copyright © 2016年 宓珂璟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubGroupList : NSObject

@property (nonatomic,strong) NSArray *list;
@property (nonatomic,strong) NSArray *role;

@end


@interface GroupList : NSObject

@property (nonatomic,strong) SubGroupList *data;
@property (nonatomic,strong) NSString *errcode;

@end


@interface DetailList : NSObject
@property (nonatomic,copy) NSString *group;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *pic;

@end
