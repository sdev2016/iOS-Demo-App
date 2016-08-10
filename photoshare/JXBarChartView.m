// 
// JXBarChartView.m
// JXBarChartViewExample
// 
// Created by jianpx on 7/18/13.
// Copyright (c) 2013 PS. All rights reserved.
// 

#import "JXBarChartView.h"

@interface JXBarChartView()
{
    CGRect screenFrame;
}
@property (nonatomic) CGContextRef context;
@property (nonatomic, strong) NSMutableArray *textIndicatorsLabels;
@property (nonatomic, strong) NSMutableArray *digitIndicatorsLabels;
@end

@implementation JXBarChartView
@synthesize values = _values;
@synthesize maxValue = _maxValue;
@synthesize textIndicators = _textIndicators;
@synthesize textColor = _textColor;
@synthesize barHeight = _barHeight;
@synthesize barMaxWidth = _barMaxWidth;
@synthesize startPoint = _startPoint;
@synthesize gradient = _gradient;


- (id)initWithFrame:(CGRect)frame
         startPoint:(CGPoint)startPoint
             values:(NSMutableArray *)values
           maxValue:(float)maxValue
     textIndicators:(NSMutableArray *)textIndicators
          textColor:(UIColor *)textColor
          barHeight:(float)barHeight
        barMaxWidth:(float)barMaxWidth
           gradient:(CGGradientRef)gradient
{
    self = [super initWithFrame:frame];
    if (self) {
        screenFrame =frame;
        _values = values;
        _maxValue = maxValue;
        _textIndicatorsLabels = [[NSMutableArray alloc] initWithCapacity:[values count]];
        _digitIndicatorsLabels = [[NSMutableArray alloc] initWithCapacity:[values count]];
        _textIndicators = textIndicators;
        _startPoint = startPoint;
        _textColor = textColor ? textColor : [UIColor orangeColor];
        _barHeight = barHeight;
        _barMaxWidth = barMaxWidth;
        if (gradient) {
            _gradient = gradient;
        } else {
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            // blue gradient
            CGFloat locations[] = {0.0, 0.5, 1.0};
            CGFloat colorComponents[] = {
                0.254, 0.599, 0.82, 1.0, // red, green, blue, alpha
                0.192, 0.525, 0.75, 1.0,
                0.096, 0.415, 0.686, 1.0
            };
            size_t count = 3;
            CGGradientRef defaultGradient = CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, count);
            _gradient = defaultGradient;
            CGColorSpaceRelease(colorSpace);
        }
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)setLabelDefaults:(UILabel *)label
{
    label.textColor = [UIColor colorWithRed:0.125 green:0.514 blue:0.769 alpha:1];
    label.font = [UIFont systemFontOfSize:13.5];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        label.font = [UIFont systemFontOfSize:30.0];
    }
    [label setTextAlignment:NSTextAlignmentLeft];
    label.adjustsFontSizeToFitWidth = YES;
    label.backgroundColor = [UIColor clearColor];
}

- (void)drawRectangle:(CGRect)rect context:(CGContextRef)context
{
    CGContextSaveGState(self.context);
    CGContextAddRect(self.context, rect);
    CGContextClipToRect(self.context, rect);
    CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint endPoint = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    CGContextDrawLinearGradient(self.context, self.gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(self.context);
}

- (void)drawRect:(CGRect)rect
{
    self.context = UIGraphicsGetCurrentContext();
    int count = (int)[self.values count];
    float startx = self.startPoint.x;
    float starty = self.startPoint.y;
    float barMargin = 22;
    float marginOfTextAndBar = 8;
    float textWidth = 50;
    int poundBar;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        poundBar = 660;
        barMargin = 40;
    }
    else
    {
        poundBar = 240;
    }
    for (int i = 0; i < count; i++) {
        // handle and setting textlabel
        float textMargin_y = (i * (self.barHeight + barMargin)) + starty;
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(startx, textMargin_y, textWidth, self.barHeight)];
        textLabel.text = self.textIndicators[i];
        [self setLabelDefaults:textLabel];
        @try {
            UILabel *originalTextLabel = self.textIndicatorsLabels[i];
            if (originalTextLabel) {
                [originalTextLabel removeFromSuperview];
            }
        }
        @catch (NSException *exception) {
            [self.textIndicatorsLabels insertObject:textLabel atIndex:i];
        }
        [self addSubview:textLabel];
        
        // handle and setting bar
        float barMargin_y = (i * (self.barHeight + barMargin)) + starty;
        float v = [self.values[i] floatValue] <= self.maxValue ? [self.values[i] floatValue]: self.maxValue;
        float rate = v / self.maxValue;
        float barWidth = rate * self.barMaxWidth;
        CGRect barFrame = CGRectMake(startx + textWidth + marginOfTextAndBar, barMargin_y, barWidth, self.barHeight);
        [self drawRectangle:barFrame context:self.context];
        
        // handle and setting textlabel
        UILabel *textLabelValue = [[UILabel alloc] initWithFrame:CGRectMake(poundBar, textMargin_y, textWidth, self.barHeight)];
        
        NSNumber *def =self.values[i];
        NSString *cob = [NSString stringWithFormat:@"%@",def];
        NSString *realDigit = [@"£" stringByAppendingString:cob];
        textLabelValue.text = realDigit;
        [self setLabelValues:textLabelValue];
        [self addSubview:textLabelValue];
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];        
    }
}

- (void)setLabelValues:(UILabel *)label
{
    label.textColor = [UIColor colorWithRed:0.125 green:0.514 blue:0.769 alpha:1];
    if(screenFrame.size.height < 458)
    {
        label.font = [UIFont systemFontOfSize:19.0];
    }
    else if(screenFrame.size.height == 568)
    {
        label.font = [UIFont systemFontOfSize:23.0];
    }
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        label.font = [UIFont systemFontOfSize:30.0];
    }
    
    [label setTextAlignment:NSTextAlignmentRight];
    label.adjustsFontSizeToFitWidth = YES;
    label.backgroundColor = [UIColor clearColor];
}

- (void)setValues:(NSMutableArray *)values
{
    for (int i = 0; i < [values count]; i++) {
        _values[i] = values[i];
    }
    [self setNeedsDisplay];
}

@end
