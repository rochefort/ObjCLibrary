//
//  RRDetailViewController.h
//  RSSReader
//
//  Created by rochefort on 2013/10/29.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRPlaceholderTextView.h"

@interface RRDetailViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>

@property NSString *identifier;
@end
