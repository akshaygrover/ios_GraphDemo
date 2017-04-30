//
//  LoginParsingClass.m
//  ModelDemo
//
//  Created by Vinay Devdikar on 5/26/14.
//  Copyright (c) 2014 Vinay Devdikar. All rights reserved.
//

#import "LoginParsingClass.h"


@implementation LoginParsingClass


-(void)GetAllDataFromWs{
    
    
    //Call Your WS From This Method
    [self performSelector:@selector(GetAllDataSucessfully) withObject:self afterDelay:1.5];
    
    
}


-(void)GetAllDataSucessfully{
    
    NSLog(@"Get All Data From Server");
    LoginModelClasss *ModelObj=[[LoginModelClasss alloc]init];
    ModelObj.userNameStr=@"vinayvdevdikar";
    ModelObj.EmailAddressStr=@"vinayvdevdikar@gmail.com";
    ModelObj.LoginStatusStr=@"Passed";
    ModelObj.LastloginStr=@"Today, 12;30PM";
    [_delegate DataParsedSucssfully:ModelObj];
    
}


-(void)UnabLeToGetAllData{
    
    NSLog(@"Data Failed");
    LoginModelClasss *ModelObj=[[LoginModelClasss alloc]init];
    ModelObj.LoginStatusStr=@"Failed";
    [_delegate DataParseFailed:ModelObj];
    
}


@end
