//
//  RRTableViewController.m
//  RSSReader
//
//  Created by trsw on 2013/10/26.
//  Copyright (c) 2013年 trsw. All rights reserved.
//

#import "RRTableViewController.h"
#import "AFNetworking.h"
#import "RRDataManager.h"
#import "RRDocumentCell.h"
#import "DocumentEntity.h"

@interface RRTableViewController ()
@property (nonatomic)RRDataManager *datamanager;
@end

@implementation RRTableViewController

NSString *const kFeedRootKey = @"apple_developer_documents";
NSString *const kURL = @"http://localhost:9393/api/apple_developer_documents.json";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.datamanager = [RRDataManager sharedManager];
    [self fetchFeeds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LOG(@"%ld", [self.datamanager.documentList count]);
    return [self.datamanager.documentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_METHOD
    static NSString *CellIdentifier = @"DocumentCell";
    RRDocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[RRDocumentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    DocumentEntity *document = self.datamanager.documentList[indexPath.row];
    cell.titleJaLabel.text        = document.title_jp;
    cell.topicLabel.text          = document.topic;
    cell.revisionDateJaLabel.text = document.revision_date_jp;
    cell.statusLabel.text = @"済み"; // TODO:
    
    return cell;
}

#pragma mark -

- (void)fetchFeeds
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:kURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self didFetch:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"getJsonData error: %@", error);
    }];
}

- (void)didFetch:(id)jsonData
{
    LOG_METHOD
    NSArray *feeds = jsonData[kFeedRootKey];
    // TODO: ない場合どうする？
    if ([feeds count] < 1) {
        NSLog(@"No Feed Error");
    }
    [self insertAllFeeds:feeds];
    LOG(@"%@", self.datamanager.documentList);
    [self.tableView reloadData];
}

- (void)insertAllFeeds:(NSArray *)feeds
{
    for (NSDictionary *feed in feeds) {
        [self insertFeed:feed];
    }
}

- (void)insertFeed:(NSDictionary *)feed
{
    NSDictionary *dict = @{@"title_en":         feed[@"title_en"],
                           @"title_jp":         feed[@"title_jp"],
                           @"framework":        feed[@"framework"],
                           @"title_en":         feed[@"link_en"],
                           @"link_jp":          feed[@"link_jp"],
                           @"revision_date_en": feed[@"revision_date_en"],
                           @"revision_date_jp": feed[@"revision_date_jp"],
                           @"topic":            feed[@"topic"],
                           @"sub_topic":        feed[@"sub_topic"]
                           };
    RRDataManager *manager = [RRDataManager sharedManager];
    [manager replce:[DocumentEntity class] dict:dict];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
