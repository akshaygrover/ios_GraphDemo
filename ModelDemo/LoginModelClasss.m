//
//  LoginModelClasss.m
//  ModelDemo
//
//  Created by Vinay Devdikar on 5/26/14.
//  Copyright (c) 2014 Vinay Devdikar. All rights reserved.
//

#import "LoginModelClasss.h"

@implementation LoginModelClasss

-(id)init{
    
    _userNameStr=[[NSString alloc]init];
    _LastloginStr=[[NSString alloc]init];
    _EmailAddressStr=[[NSString alloc]init];
    _LoginStatusStr=[[NSString alloc]init];
    
    return self;
}

-(void)dealloc{
    
    
    _userNameStr=nil;
    _LastloginStr=nil;
    _EmailAddressStr=nil;
    _LoginStatusStr=nil;
}

@end
