//
//  RRFileListViewController.h
//  RSSReader
//
//  Created by rochefort on 2013/10/27.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRFileListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
