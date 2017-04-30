//
//  LoginParsingClass.h
//  ModelDemo
//
//  Created by Vinay Devdikar on 5/26/14.
//  Copyright (c) 2014 Vinay Devdikar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginModelClasss.h"

@protocol LoginParsingClassDelegate <NSObject>

@required

-(void)DataParsedSucssfully:(LoginModelClasss *)_loginObj;

-(void)DataParseFailed:(LoginModelClasss *)_loginObj;

@end


@interface LoginParsingClass : NSObject

@property(nonatomic,strong)id <LoginParsingClassDelegate> delegate;

- (void)GetAllDataFromWs;


@end
