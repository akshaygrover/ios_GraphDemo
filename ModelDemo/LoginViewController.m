//
//  LoginViewController.m
//  ModelDemo
//
//  Created by Vinay Devdikar on 5/26/14.
//  Copyright (c) 2014 Vinay Devdikar. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginParsingClass.h"
#import "LCLineChartView.h"
#import "LineChart.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LCLineChartView *chartView = [[LCLineChartView alloc] initWithFrame:CGRectMake(20, 100, 500, 180)];
    chartView.backgroundColor=[UIColor clearColor];
    chartView.yMin = 180;
    chartView.yMax = 220;
    chartView.yMinForGraph2=24.0;
    chartView.yMaxForGraph2=30.0;
    
    chartView.ySteps = @[@"180",
                         @"190",
                         @"200",
                         @"210",
                         @"220",];
    
    chartView.yStepsRight=@[@"24.0",
                            @"25.5",
                            @"27.0",
                            @"28.5",
                            @"30.0",];
    
    
    
    
    
    NSMutableArray *vals2;
        LCLineChartData *d1x = ({
            LCLineChartData *d1 = [LCLineChartData new];
            d1.xMin = 1;
            d1.xMax = 8;
            d1.title = @"Foobarbang";
            d1.color = [UIColor greenColor];
            d1.itemCount =  8;
            NSMutableArray *vals = [NSMutableArray new];
            vals2 = [[NSMutableArray alloc]initWithObjects:@"210",@"206",@"200",@"197",@"191",@"186",@"182",@"180", nil];
            
            for(NSUInteger i = 1; i <= d1.itemCount; ++i) {
                [vals addObject:@(i)];
            }

            [vals sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2];
            }];
            
            d1.getData = ^(NSUInteger item) {
                float x = [vals[item] floatValue];
                float y = [vals2[item] floatValue];
                NSString *label1 = [NSString stringWithFormat:@"%d", item];
                NSString *label2 = [NSString stringWithFormat:@"%.1f", y];
                return [LCLineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
            };
            
            d1;
        });
        
    
    
        LCLineChartData *d2x = ({
            LCLineChartData *d1 = [LCLineChartData new];
            d1.xMin = 1;
            d1.xMax = 8;
            d1.title = @"Bar";
            d1.color = [UIColor blueColor];
            d1.itemCount = 8;
            NSMutableArray *vals = [NSMutableArray new];
            NSMutableArray *vals3 = [[NSMutableArray alloc]initWithObjects:@"28.5",@"27.9",@"27.1",@"26.7",@"25.9",@"25.2",@"24.8",@"24.4", nil];
            
           
            
            for(NSUInteger i = 1; i <= d1.itemCount; ++i) {
                [vals addObject:@(i)];
            }
            
            [vals sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2];
            }];

            d1.getData = ^(NSUInteger item) {
                float x = [vals[item] floatValue];
                float y = [vals3[item] floatValue];
                NSString *label1 = [NSString stringWithFormat:@"%d", item];
                NSString *label2 = [NSString stringWithFormat:@"%.1f", y];
                return [LCLineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
            };
            
            d1;
        });

     chartView.xSteps=@[@"2/20",@"2/25",@"3/1",@"3/4",@"3/10",@"3/20",@"3/25",@"4/1"];
    
    
        chartView.data = @[d1x,d2x];

    
    NSMutableArray *vals1 = [[NSMutableArray alloc]initWithObjects:@"2/20",@"2/25",@"3/1",@"3/4",@"3/10",@"3/20",@"3/25",@"4/1", nil];
    //NSMutableArray *vals1 = [[NSMutableArray alloc]initWithObjects:@"2/20",@"2/25",@"3/1",@"3/4",@"3/10",@"3/20",@"3/25",@"4/1",@"4/17",@"4/24", nil];
    int x=38;
    for (int index=0; index<[vals1 count]; index++) {
        
        UILabel *xAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, chartView.frame.size.height, 30, 12)];
        xAxisLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        xAxisLabel.font = [UIFont boldSystemFontOfSize:10];
        xAxisLabel.textColor = [UIColor lightGrayColor];
        xAxisLabel.textAlignment = NSTextAlignmentCenter;
        xAxisLabel.alpha = 1.0;
        xAxisLabel.text=[vals1 objectAtIndex:index];
        xAxisLabel.backgroundColor = [UIColor clearColor];
        [chartView addSubview:xAxisLabel];
        int dist=chartView.frame.size.width-70;
        dist=dist/[vals1 count];
        x=x+dist;
        
    }
    
    
    
    
    [self.view addSubview:chartView];

    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)LoginButtonClick:(id)sender {
    
    LoginParsingClass *LoginObj=[[LoginParsingClass alloc]init];
    LoginObj.delegate=self;
    [LoginObj GetAllDataFromWs];
    
}


#pragma mark - Login WS Delegate

-(void)DataParsedSucssfully:(LoginModelClasss *)_loginObj{
    
    [[[UIAlertView alloc]initWithTitle:@"Demo" message:[NSString stringWithFormat:@"User Name:%@\n Email ID:%@\n Last Login:%@\n",_loginObj.userNameStr,_loginObj.EmailAddressStr,_loginObj.LastloginStr] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
    
    
    
}

-(void)DataParseFailed:(LoginModelClasss *)_loginObj{
    
     [[[UIAlertView alloc]initWithTitle:@"Demo" message:@"Unabel To Connect" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
}

@end
