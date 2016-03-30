//
//  MSSegmentedControl.m
//
//  Created by team on 16/3/30.
//  Copyright © 2016年 EveTime. All rights reserved.
//

#import "MSSegmentedControl.h"

@interface MSSegmentedControl () {
  NSMutableArray *titleBadgeArray;
}
@end

@implementation MSSegmentedControl

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  if (!titleBadgeArray) {
    titleBadgeArray = [NSMutableArray new];
    
    CGFloat segmentWidth = self.frame.size.width / [self.sectionTitles count];
    
    [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
      CGFloat stringWidth  = 0;
      CGFloat stringHeight = 0;
      CGSize size          = [self measureTitleAtIndex:idx];
      stringWidth          = size.width;
      stringHeight         = size.height;
      
      // Text inside the CATextLayer will appear blurry unless the rect values are rounded
      BOOL locationUp = (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp);
      BOOL selectionStyleNotBox = (self.selectionStyle != HMSegmentedControlSelectionStyleBox);
      
      CGFloat y = roundf((CGRectGetHeight(self.frame) - selectionStyleNotBox * self.selectionIndicatorHeight) / 2 - stringHeight / 2 + self.selectionIndicatorHeight * locationUp);
      CGRect rect;
      if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
        rect = CGRectMake((segmentWidth * idx) + (segmentWidth - stringWidth) / 2, y, stringWidth, stringHeight);
      }
      
      // Fix rect position/size to avoid blurry labels
      rect = CGRectMake(ceilf(rect.origin.x), ceilf(rect.origin.y), ceilf(rect.size.width), ceilf(rect.size.height));
      
      CGFloat badgeW                      = 30.0;

      UILabel *titleBadgeLabel            = [[UILabel alloc] init];
      titleBadgeLabel.frame               = CGRectMake((rect.origin.x + rect.size.width + 5), (rect.origin.y - ((badgeW - rect.size.height) / 2)), badgeW, badgeW);
      titleBadgeLabel.backgroundColor     = [UIColor redColor];
      titleBadgeLabel.layer.cornerRadius  = badgeW / 2;
      titleBadgeLabel.layer.masksToBounds = YES;
      titleBadgeLabel.textColor           = [UIColor whiteColor];
      titleBadgeLabel.textAlignment       = NSTextAlignmentCenter;

      [self addSubview:titleBadgeLabel];
      titleBadgeLabel.hidden              = YES;
      
      [titleBadgeArray addObject:titleBadgeLabel];
    }];
  }

}

- (void)setTitleBadgeValue:(int)value index:(int)index {
  UILabel *label   = [titleBadgeArray objectAtIndex:index];
  label.hidden     = NO;
  label.text       = [NSString stringWithFormat:@"%d", value];
  if (value >= 100) {
    label.font     = [UIFont systemFontOfSize:15.0];
  }
  else {
    label.font     = [UIFont systemFontOfSize:17.0];
  }
}

#pragma mark - Drawing
- (CGSize)measureTitleAtIndex:(NSUInteger)index {
  id title      = self.sectionTitles[index];
  CGSize size   = CGSizeZero;
  BOOL selected = (index == self.selectedSegmentIndex) ? YES : NO;
  if ([title isKindOfClass:[NSString class]] && !self.titleFormatter) {
    NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
    size = [(NSString *)title sizeWithAttributes:titleAttrs];
  } else if ([title isKindOfClass:[NSString class]] && self.titleFormatter) {
    size = [self.titleFormatter(self, title, index, selected) size];
  } else if ([title isKindOfClass:[NSAttributedString class]]) {
    size = [(NSAttributedString *)title size];
  } else {
    NSAssert(title == nil, @"Unexpected type of segment title: %@", [title class]);
    size = CGSizeZero;
  }
  return CGRectIntegral((CGRect){CGPointZero, size}).size;
}

#pragma mark - Styling Support

- (NSDictionary *)resultingTitleTextAttributes {
  NSDictionary *defaults = @{
                             NSFontAttributeName : [UIFont systemFontOfSize:19.0f],
                             NSForegroundColorAttributeName : [UIColor blackColor],
                             };
  
  NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:defaults];
  
  if (self.titleTextAttributes) {
    [resultingAttrs addEntriesFromDictionary:self.titleTextAttributes];
  }
  
  return [resultingAttrs copy];
}

- (NSDictionary *)resultingSelectedTitleTextAttributes {
  NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:[self resultingTitleTextAttributes]];
  
  if (self.selectedTitleTextAttributes) {
    [resultingAttrs addEntriesFromDictionary:self.selectedTitleTextAttributes];
  }
  
  return [resultingAttrs copy];
}

@end
