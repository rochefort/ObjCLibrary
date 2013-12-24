//
//  RRPlaceholderTextView.h
//  RSSReader
//
//  Created by rochefort on 2013/11/12.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRPlaceholderTextView : UITextView
@property (nonatomic) NSString *placeholder;
@property (nonatomic) UIColor *placeholderColor;

- (void)textChanged:(NSNotification *)notification;

@end
