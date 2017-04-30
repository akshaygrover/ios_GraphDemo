//
//  LCLineChartView.m
//  
//
//  Created by Marcel Ruegenberg on 02.08.13.
//
//

#import "LCLineChartView.h"
#import "LCLegendView.h"
#import "LCInfoView.h"

@interface LCLineChartDataItem ()

@property (readwrite) float x; // should be within the x range
@property (readwrite) float y; // should be within the y range
@property (readwrite) NSString *xLabel; // label to be shown on the x axis
@property (readwrite) NSString *dataLabel; // label to be shown directly at the data item

- (id)initWithhX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel;

@end

@implementation LCLineChartDataItem

- (id)initWithhX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel {
    if((self = [super init])) {
        self.x = x;
        self.y = y;
        self.xLabel = xLabel;
        self.dataLabel = dataLabel;
    }
    return self;
}

+ (LCLineChartDataItem *)dataItemWithX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel {
    return [[LCLineChartDataItem alloc] initWithhX:x y:y xLabel:xLabel dataLabel:dataLabel];
}

@end



@implementation LCLineChartData

@end



@interface LCLineChartView ()

@property LCLegendView *legendView;
@property LCInfoView *infoView;
@property UIView *currentPosView;
@property UILabel *xAxisLabel;

- (BOOL)drawsAnyData;

@end


#define X_AXIS_SPACE 15
#define PADDING 10


@implementation LCLineChartView
@synthesize data=_data;

- (void)setDefaultValues {
    self.currentPosView = [[UIView alloc] initWithFrame:CGRectMake(PADDING, PADDING, 1 / self.contentScaleFactor, 50)];
    self.currentPosView.backgroundColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];
    self.currentPosView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.currentPosView.alpha = 0.0;
   [self addSubview:self.currentPosView];
    
    self.legendView = [[LCLegendView alloc] init];
    self.legendView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.legendView.backgroundColor = [UIColor clearColor];
    //[self addSubview:self.legendView];
    
    self.axisLabelColor = [UIColor grayColor];
    
    self.xAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    self.xAxisLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.xAxisLabel.font = [UIFont boldSystemFontOfSize:10];
    self.xAxisLabel.textColor = self.axisLabelColor;
    self.xAxisLabel.textAlignment = NSTextAlignmentCenter;
    self.xAxisLabel.alpha = 1.0;
    self.xAxisLabel.backgroundColor = [UIColor blueColor];
    [self addSubview:self.xAxisLabel];
    
    
    self.backgroundColor = [UIColor whiteColor];
    self.scaleFont = [UIFont systemFontOfSize:10.0];
    
    self.autoresizesSubviews = YES;
    self.contentMode = UIViewContentModeRedraw;
    
    self.drawsDataPoints = YES;
    self.drawsDataLines  = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])) {
        [self setDefaultValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        [self setDefaultValues];
    }
    return self;
}

- (void)setAxisLabelColor:(UIColor *)axisLabelColor {
    if(axisLabelColor != _axisLabelColor) {
        [self willChangeValueForKey:@"axisLabelColor"];
        _axisLabelColor = axisLabelColor;
        self.xAxisLabel.textColor = axisLabelColor;
        [self didChangeValueForKey:@"axisLabelColor"];
    }
}

- (void)showLegend:(BOOL)show animated:(BOOL)animated {
    if(! animated) {
        self.legendView.alpha = show ? 1.0 : 0.0;
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.legendView.alpha = show ? 1.0 : 0.0;
    }];
}
                           
- (void)layoutSubviews {
    [self.legendView sizeToFit];
    CGRect r = self.legendView.frame;
    r.origin.x = self.bounds.size.width - self.legendView.frame.size.width - 3 - PADDING;
    r.origin.y = 3 + PADDING;
    self.legendView.frame = r;
    
    r = self.currentPosView.frame;
    CGFloat h = self.bounds.size.height;
    r.size.height = h - 2 * PADDING - X_AXIS_SPACE;
    self.currentPosView.frame = r;
    
    [self.xAxisLabel sizeToFit];
    r = self.xAxisLabel.frame;
    r.origin.y = self.bounds.size.height - X_AXIS_SPACE - PADDING + 2;
    self.xAxisLabel.frame = r;
    
    [self bringSubviewToFront:self.legendView];
}

- (void)setData:(NSArray *)data {
    if(data != _data) {
        NSMutableArray *titles = [NSMutableArray arrayWithCapacity:[data count]];
        NSMutableDictionary *colors = [NSMutableDictionary dictionaryWithCapacity:[data count]];
        for(LCLineChartData *dat in data) {
            NSString *key = dat.title;
            if(key == nil) key = @"";
            [titles addObject:key];
            [colors setObject:dat.color forKey:key];
        }
        self.legendView.titles = titles;
        self.legendView.colors = colors;
        
        _data = data;
        
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat availableHeight = self.bounds.size.height - 2 * PADDING - X_AXIS_SPACE;
    
    CGFloat availableWidth = self.bounds.size.width - 2 * PADDING - self.yAxisLabelsWidth-20;
    CGFloat xStart = PADDING + self.yAxisLabelsWidth;
    CGFloat yStart = PADDING;
    
    static CGFloat dashedPattern[] = {4,2};
    
    // draw scale and horizontal lines
    CGFloat heightPerStep = self.ySteps == nil || [self.ySteps count] == 0 ? availableHeight : (availableHeight / ([self.ySteps count] - 1));
    
    NSUInteger i = 0;
    CGContextSaveGState(c);
    CGContextSetLineWidth(c, 1.0);
    NSUInteger yCnt = [self.ySteps count];
    for(int index=0; index<[self.ySteps count];index++) {
        NSString *step=[self.ySteps objectAtIndex:index];
        NSString *step1=[self.yStepsRight objectAtIndex:index];
        [self.axisLabelColor set];
        CGFloat h = [self.scaleFont lineHeight];
        CGFloat y = yStart + heightPerStep * (yCnt - 1 - i);
        // TODO: replace with new text APIs in iOS 7 only version
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
       [step1 drawInRect:CGRectMake(self.frame.size.width-20, y - h / 2, self.yAxisLabelsWidth - 6, h) withFont:self.scaleFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentLeft];
        [step drawInRect:CGRectMake(yStart, y - h / 2, self.yAxisLabelsWidth - 6, h) withFont:self.scaleFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentRight];
#pragma clagn diagnostic pop
        
        [[UIColor colorWithWhite:0.9 alpha:1.0] set];
        CGContextSetLineDash(c, 0, dashedPattern, 2);
        CGContextMoveToPoint(c, xStart, round(y) + 0.5);
        CGContextAddLineToPoint(c, self.bounds.size.width - PADDING, round(y) + 0.5);
        CGContextStrokePath(c);
        
        i++;
    }//yStepsRight
    
    
    
    
    NSUInteger xCnt = self.xStepsCount;
    if(xCnt > 1) {
        CGFloat widthPerStep = availableWidth / (xCnt - 1);
        
        [[UIColor grayColor] set];
        for(NSUInteger i = 0; i < xCnt; ++i) {
            CGFloat x = xStart + widthPerStep * (xCnt - 1 - i);
            
            [[UIColor colorWithWhite:0.9 alpha:1.0] set];
            CGContextMoveToPoint(c, round(x) + 0.5, PADDING);
            CGContextAddLineToPoint(c, round(x) + 0.5, yStart + availableHeight);
            CGContextStrokePath(c);
        }
    }
    
    CGContextRestoreGState(c);


    if (!self.drawsAnyData) {
        NSLog(@"You configured LineChartView to draw neither lines nor data points. No data will be visible. This is most likely not what you wanted. (But we aren't judging you, so here's your chart background.)");
    } // warn if no data will be drawn
    
   
    
    
    
    CGFloat yRangeLen = self.yMax - self.yMin;
    if(yRangeLen == 0) yRangeLen = 1;
    
    for(int index=0;index<self.data.count;index++) {
        
        
        
        if (index!=0) {
            
            self.yMin2=self.yMin;
            self.yMax2=self.yMax;
            self.ySteps2=self.ySteps;
            
            self.yMin=self.yMinForGraph2;
            self.yMax=self.yMaxForGraph2;
            self.ySteps=self.yStepsRight;
            yRangeLen = self.yMax - self.yMin;
        }
        
        
        LCLineChartData *data =[self.data objectAtIndex:index];
        if (self.drawsDataLines) {
            float xRangeLen = data.xMax - data.xMin;
            if(xRangeLen == 0) xRangeLen = 1;
            if(data.itemCount >= 2) {
                LCLineChartDataItem *datItem = data.getData(0);
                CGMutablePathRef path = CGPathCreateMutable();
                CGFloat prevX = xStart + round(((datItem.x - data.xMin) / xRangeLen) * availableWidth);
                CGFloat prevY = yStart + round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);
                CGPathMoveToPoint(path, NULL, prevX, prevY);
                
                
                for(NSUInteger i = 1; i < data.itemCount; ++i) {
                    LCLineChartDataItem *datItem = data.getData(i);
                    CGFloat x = xStart + round(((datItem.x - data.xMin) / xRangeLen) * availableWidth);
                    CGFloat y = yStart + round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);
                    CGFloat xDiff = x - prevX;
                    CGFloat yDiff = y - prevY;
                    
                    if(xDiff != 0) {
                        CGFloat xSmoothing = self.smoothPlot ? MIN(30,xDiff) : 0;
                        CGFloat ySmoothing = 0.5;
                        CGFloat slope = yDiff / xDiff;
                        CGPoint controlPt1 = CGPointMake(prevX + xSmoothing, prevY + ySmoothing * slope * xSmoothing);
                        CGPoint controlPt2 = CGPointMake(x - xSmoothing, y - ySmoothing * slope * xSmoothing);
                        CGPathAddCurveToPoint(path, NULL, controlPt1.x, controlPt1.y, controlPt2.x, controlPt2.y, x, y);
                    }
                    else {
                        CGPathAddLineToPoint(path, NULL, x, y);
                    }
                    prevX = x;
                    prevY = y;
                }
                
                CGContextAddPath(c, path);
                CGContextSetStrokeColorWithColor(c, [self.backgroundColor CGColor]);
                CGContextSetLineWidth(c, 5);
                CGContextStrokePath(c);
                
                CGContextAddPath(c, path);
                CGContextSetStrokeColorWithColor(c, [data.color CGColor]);
                CGContextSetLineWidth(c, 2);
                CGContextStrokePath(c);
                
                CGPathRelease(path);
            }
        } // draw actual chart data
        
        
        
        if (self.drawsDataPoints) {
            float xRangeLen = data.xMax - data.xMin;
            if(xRangeLen == 0) xRangeLen = 1;
          //  float xval=xStart-25;
           
            for(NSUInteger i = 0; i < data.itemCount; ++i) {
                LCLineChartDataItem *datItem = data.getData(i);
                CGFloat xVal = xStart + round((xRangeLen == 0 ? 0.5 : ((datItem.x - data.xMin) / xRangeLen)) * availableWidth);
                CGFloat yVal = yStart + round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);
                [self.backgroundColor setFill];
                CGContextFillEllipseInRect(c, CGRectMake(xVal - 5.5, yVal - 5.5, 11, 11));
                [data.color setFill];
                CGContextFillEllipseInRect(c, CGRectMake(xVal - 4, yVal - 4, 8, 8));
                // NSString *step=[self.ySteps objectAtIndex:index];
//                if (index==1) {
//                    
//                    NSLog(@"%f",xval);
//                    
//                    [step drawInRect:CGRectMake(xval,self.frame.size.height-10,50,50) withFont:self.scaleFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentRight];
//                    int dist=availableWidth/data.itemCount;
//                    xval=xval+dist;
//                }
                
                {
                    CGFloat h,s,b,a;
                    if(CGColorGetNumberOfComponents([data.color CGColor]) < 3)
                        [data.color getWhite:&b alpha:&a];
                    else
                        [data.color getHue:&h saturation:&s brightness:&b alpha:&a];
                    if(b <= 0.5)
                        [[UIColor whiteColor] setFill];
                    else
                        [[UIColor blackColor] setFill];
                }
                CGContextFillEllipseInRect(c, CGRectMake(xVal - 2, yVal - 2, 4, 4));
            } // for
        } // draw data points
    }
    
    
    self.yMin=self.yMin2;
    self.yMax=self.yMax2;
    self.ySteps=self.ySteps2;
    
    
    
    
}

- (void)showIndicatorForTouch:(UITouch *)touch {
    
    
    if(! self.infoView) {
        self.infoView = [[LCInfoView alloc] init];
        [self addSubview:self.infoView];
    }
    
    CGPoint pos = [touch locationInView:self];
    CGFloat xStart = PADDING + self.yAxisLabelsWidth;
    CGFloat yStart = PADDING;
    CGFloat yRangeLen = self.yMax - self.yMin;
    if(yRangeLen == 0) yRangeLen = 1;
    CGFloat xPos = pos.x - xStart;
    CGFloat yPos = pos.y - yStart;
    CGFloat availableWidth = self.bounds.size.width - 2 * PADDING - self.yAxisLabelsWidth-20;
    CGFloat availableHeight = self.bounds.size.height - 2 * PADDING - X_AXIS_SPACE;
    
    LCLineChartDataItem *closest = nil;
    float minDist = FLT_MAX;
    float minDistY = FLT_MAX;
    CGPoint closestPos = CGPointZero;
    
    for(int index=0;index<self.data.count;index++) {
        
        if (index!=0) {
            
            self.yMin2=self.yMin;
            self.yMax2=self.yMax;
            self.ySteps2=self.ySteps;
            
            self.yMin=self.yMinForGraph2;
            self.yMax=self.yMaxForGraph2;
            self.ySteps=self.yStepsRight;
            yRangeLen = self.yMax - self.yMin;
        }
        
        LCLineChartData *data =[self.data objectAtIndex:index];
        float xRangeLen = data.xMax - data.xMin;
        for(NSUInteger i = 0; i < data.itemCount; ++i) {
            LCLineChartDataItem *datItem = data.getData(i);
            CGFloat xVal = round((xRangeLen == 0 ? 0.0 : ((datItem.x - data.xMin) / xRangeLen)) * availableWidth);
            CGFloat yVal = round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);
            
            float dist = fabsf(xVal - xPos);
            float distY = fabsf(yVal - yPos);
            if(dist < minDist || (dist == minDist && distY < minDistY)) {
                minDist = dist;
                minDistY = distY;
                closest = datItem;
                closestPos = CGPointMake(xStart + xVal - 3, yStart + yVal - 7);
            }
        }

        
        
    }
    
    self.yMin=self.yMin2;
    self.yMax=self.yMax2;
    self.ySteps=self.ySteps2;
    
    
    
    
    
    /*for(LCLineChartData *data in self.data) {
        
        float xRangeLen = data.xMax - data.xMin;
        for(NSUInteger i = 0; i < data.itemCount; ++i) {
            LCLineChartDataItem *datItem = data.getData(i);
            CGFloat xVal = round((xRangeLen == 0 ? 0.0 : ((datItem.x - data.xMin) / xRangeLen)) * availableWidth);
            CGFloat yVal = round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);
            
            float dist = fabsf(xVal - xPos);
            float distY = fabsf(yVal - yPos);
            if(dist < minDist || (dist == minDist && distY < minDistY)) {
                minDist = dist;
                minDistY = distY;
                closest = datItem;
                closestPos = CGPointMake(xStart + xVal - 3, yStart + yVal - 7);
            }
        }
    }*/
    
    self.infoView.infoLabel.text = closest.dataLabel;
    self.infoView.tapPoint = closestPos;
    [self.infoView sizeToFit];
    [self.infoView setNeedsLayout];
    [self.infoView setNeedsDisplay];
    
    if(self.currentPosView.alpha == 0.0) {
        CGRect r = self.currentPosView.frame;
        r.origin.x = closestPos.x + 3 - 1;
        self.currentPosView.frame = r;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self.infoView.alpha = 1.0;
        self.currentPosView.alpha = 1.0;
        self.xAxisLabel.alpha = 1.0;
        
        CGRect r = self.currentPosView.frame;
        r.origin.x = closestPos.x + 3 - 1;
        self.currentPosView.frame = r;
        
        self.xAxisLabel.text = closest.xLabel;
        if(self.xAxisLabel.text != nil) {
            [self.xAxisLabel sizeToFit];
            r = self.xAxisLabel.frame;
            r.origin.x = round(closestPos.x - r.size.width / 2);
            self.xAxisLabel.frame = r;
        }
    }];
}

- (void)hideIndicator {
    [UIView animateWithDuration:0.1 animations:^{
        self.infoView.alpha = 0.0;
        self.currentPosView.alpha = 0.0;
        self.xAxisLabel.alpha = 0.0;
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self showIndicatorForTouch:[touches anyObject]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self showIndicatorForTouch:[touches anyObject]];	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideIndicator];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideIndicator];
}


#pragma mark Helper methods

- (BOOL)drawsAnyData {
    return self.drawsDataPoints || self.drawsDataLines;
}

// TODO: This should really be a cached value. Invalidated iff ySteps changes.
- (CGFloat)yAxisLabelsWidth {
    float maxV = 0;
    for(NSString *label in self.ySteps) {
        CGSize labelSize = [label sizeWithFont:self.scaleFont];
        if(labelSize.width > maxV) maxV = labelSize.width;
    }
    return maxV + PADDING;
}



-(UIColor *) colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel,
                                                 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0
                                     green:pixel[1]/255.0 blue:pixel[2]/255.0
                                     alpha:pixel[3]/255.0];
    return color;
}


@end
