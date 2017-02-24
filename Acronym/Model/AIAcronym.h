//
//  AIAcronym.h
//  Acronym
//
//  Created by Eshwar Chaitanya Govindaraju on 02/23/17.
//  Copyright (c) 2017 Eshwar Chaitanya Govindaraju All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIAcronym : NSObject

@property (nonatomic,copy) NSString *shortForm;
@property (nonatomic,strong) NSMutableArray *meanings;
@end
