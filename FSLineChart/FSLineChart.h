//
//  FSLineChart.h
//  FSLineChart
//
//  Created by JalynnXi on 8/9/16.
//  Copyright © 2016年 JalynnXi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSLineChart : UIView

// Block definition for getting a label for a set index (use case: date, units,...)
typedef NSString *(^FSLabelForIndexGetter)(NSUInteger index);

// Same as above, but for the value (for adding a currency, or a unit symbol for example)
typedef NSString *(^FSLabelForValueGetter)(CGFloat value);

typedef NS_ENUM(NSInteger, ValueLabelPositionType) {
    ValueLabelLeft,
    ValueLabelRight,
    ValueLabelLeftMirrored
};

// Index label properties
@property (copy) FSLabelForIndexGetter labelForIndex;
@property (nonatomic, strong) UIFont* indexLabelFont;
@property (nonatomic) UIColor* indexLabelTextColor;
@property (nonatomic) UIColor* indexLabelBackgroundColor;

// Value label properties
@property (copy) FSLabelForValueGetter labelForValue;
@property (nonatomic, strong) UIFont* valueLabelFont;
@property (nonatomic) UIColor* valueLabelTextColor;
@property (nonatomic) UIColor* valueLabelBackgroundColor;
@property (nonatomic) ValueLabelPositionType valueLabelPosition;

// Number of visible step in the chart
@property (nonatomic) int gridStep;
@property (nonatomic) int verticalGridStep;
@property (nonatomic) int horizontalGridStep;

// Margin of the chart
@property (nonatomic) CGFloat margin;

@property (nonatomic) CGFloat axisWidth;
@property (nonatomic) CGFloat axisHeight;

// Decoration parameters, let you pick the color of the line as well as the color of the axis
@property (nonatomic, strong) UIColor* axisColor;
@property (nonatomic) CGFloat axisLineWidth;

// Chart parameters
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic) CGFloat lineWidth;

// Data points
@property (nonatomic) BOOL displayDataPoint;
@property (nonatomic, strong) UIColor* dataPointColor;
@property (nonatomic, strong) UIColor* dataPointBackgroundColor;
@property (nonatomic) CGFloat dataPointRadius;

// Grid parameters
@property (nonatomic) BOOL drawInnerGrid;
@property (nonatomic, strong) UIColor* innerGridColor;
@property (nonatomic) CGFloat innerGridLineWidth;

// Smoothing
@property (nonatomic) BOOL bezierSmoothing;
@property (nonatomic) CGFloat bezierSmoothingTension;

// Animations
@property (nonatomic) CGFloat animationDuration;

// Set the actual data for the chart, and then render it to the view.
- (void)setChartData:(NSArray *)chartData;

// Clear all rendered data from the view.
- (void)clearChartData;

// Get the bounds of the chart
- (CGFloat)minVerticalBound;
- (CGFloat)maxVerticalBound;


@end
