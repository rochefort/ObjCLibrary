//
//  RRFileListViewController.m
//  RSSReader
//
//  Created by rochefort on 2013/10/27.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "RRFileListViewController.h"
#import "AFNetworking.h"
#import "RRDocumentCell.h"
#import "RRDetailViewController.h"

@interface RRFileListViewController ()
{
    NSArray *documentList;
    NSMutableArray *filterdDocumentList;
    RRDataManager *dataManager;
    UIRefreshControl *refreshControl;
}
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)searchButtonDidPush:(id)sender;
- (IBAction)segChanged:(id)sender;
@end

NSString *const kFeedRootKey = @"apple_developer_documents";

//NSString *const kJsonURL = @"http://localhost:9393/api/apple_developer_documents.json";
NSString *const kJsonURL = @"http://rochefort8.tk/api/apple_developer_documents.json";

@implementation RRFileListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    // searchBar
    [self hideSearchBar];
    self.searchDisplayController.searchBar.barTintColor = [self.view.tintColor colorWithAlphaComponent:0.2];
    
    // searchButton
    FAKFontAwesome *searchIcon = [FAKFontAwesome searchIconWithSize:16];
    [searchIcon addAttribute:NSForegroundColorAttributeName value:self.view.tintColor];
    [self.searchButton setAttributedTitle:[searchIcon attributedString] forState:UIControlStateNormal];
    self.searchButton.layer.borderColor = [self.view.tintColor CGColor];
    self.searchButton.layer.borderWidth = 1.f;
    self.searchButton.layer.cornerRadius = 5.f;
    
    // refreshControl
    refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    // segmentedControl
    // FIXME: storyboadで設定した値が表示されないため、ソースコードで設定しています。
    [self.segmentedControl setTitle:@"Unread" forSegmentAtIndex:0];
    [self.segmentedControl setTitle:@"Top Rated" forSegmentAtIndex:1];
    [self.segmentedControl setTitle:@"Recently" forSegmentAtIndex:2];
    [self.segmentedControl setTitle:@"All" forSegmentAtIndex:3];
    
    dataManager = [RRDataManager sharedManager];
    [self fetchFeeds];
    filterdDocumentList = [NSMutableArray arrayWithCapacity:[dataManager.documentList count]];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self displayData];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

#pragma mark - Rotate

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [filterdDocumentList count];
    } else {
        return [documentList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DocumentCell";
    RRDocumentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[RRDocumentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    DocumentEntity *document;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        document = filterdDocumentList[indexPath.row];
    } else {
        document = documentList[indexPath.row];
    }
    cell.titleJpLabel.text          = document.title_jp;
    cell.topicLabel.text            = document.topic;
    cell.revisionDateJaLabel.text   = document.revision_date_jp;
    cell.statusLabel.attributedText = [[self iconWithStatus:document.status size:10] attributedString];
    cell.identifier                 = document.identifier;
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = nil;
    } else {
        cell.backgroundColor = [UIColor colorWithRed:0.546 green:0.584 blue:1.000 alpha:0.050];
    }
    return cell;
}

- (FAKFontAwesome *)iconWithStatus:(NSNumber *)status size:(CGFloat)size
{
    FAKFontAwesome *icon;
    switch ((DocumentStatus)[status intValue]) {
        case DocumentStatusReading:
            icon = [FAKFontAwesome adjustIconWithSize:size];
            break;
        case DocumentStatusDone:
            icon = [FAKFontAwesome circleOIconWithSize:size];
            break;
        default:
            icon = [FAKFontAwesome circleIconWithSize:size];
            break;
    }
    [icon addAttribute:NSForegroundColorAttributeName value:self.view.tintColor];
    return icon;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RRDocumentCell *cell = (RRDocumentCell *)sender;
    RRDetailViewController *vc = segue.destinationViewController;
    vc.identifier = cell.identifier;
}

#pragma mark - RefreshControl

- (void)refresh:(id)sender
{
    [self fetchFeeds];
}

#pragma mark - Segumented Control

- (IBAction)segChanged:(id)sender {
    [self displayData];
}

- (void)displayData {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status != %d", DocumentStatusDone];
            documentList = [dataManager find:[DocumentEntity class] by:predicate];
        }
            break;
        case 1:
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rate >= %d", 4];
            documentList = [dataManager find:[DocumentEntity class] by:predicate];
        }
            break;
        case 2:
        {
            NSDate *halfYearAgo = [NSDate dateWithTimeIntervalSinceNow: -180 * 24 * 60 * 60];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy/MM/dd"];
            NSString *condition = [formatter stringFromDate:halfYearAgo];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"revision_date_jp >= %@", condition];
            NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"revision_date_jp" ascending:NO];
            documentList = [dataManager find:[DocumentEntity class] by:predicate order:sortNameDescriptor];
        }
            break;
        case 3:
        {
            documentList = [dataManager find:[DocumentEntity class]];
        }
            break;
        default:
            break;
    }
    [self.tableView reloadData];
    
    if (refreshControl.isRefreshing) {
        [refreshControl endRefreshing];
    }
}

#pragma mark - fetch

- (void)fetchFeeds
{
    self.segmentedControl.enabled = NO;
    __weak __typeof(self)weakSelf = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:kJsonURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf didFetch:responseObject];
        [weakSelf displayData];
        self.segmentedControl.enabled = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"getJsonData error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ネットワークエラー"
                                                        message:@"インターネットに接続してください"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];

        // 初回データ登録
        if ([dataManager.documentList count] == 0) {
            [weakSelf loadInitializeJson];
        }
        [weakSelf displayData];
        self.segmentedControl.enabled = YES;
    }];
}

- (void)loadInitializeJson
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"initial" ofType:@"json"];
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
    [self didFetch:jsonObject];
}

- (void)didFetch:(id)jsonData
{
    LOG_METHOD
    NSArray *feeds = jsonData[kFeedRootKey];
    if ([feeds count] == 0) {
        NSLog(@"No Feed Error");
    }
    [self replaceAllFeeds:feeds];
}

#pragma mark - CoreData

- (void)replaceAllFeeds:(NSArray *)feeds
{
    for (NSDictionary *feed in feeds) {
        [self replaceFeed:feed];
    }
}

- (void)replaceFeed:(NSDictionary *)feed
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
    [dataManager replace:[DocumentEntity class] dict:dict];
}

#pragma mark - Search

- (IBAction)searchButtonDidPush:(id)sender {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.searchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    [self.searchDisplayController.searchBar becomeFirstResponder];
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [filterdDocumentList removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title_jp contains[c] %@", searchText];
    filterdDocumentList = [NSMutableArray arrayWithArray:[documentList filteredArrayUsingPredicate:predicate]];
}

- (void)hideSearchBar {
    CGRect tvBounds = self.tableView.bounds;
    tvBounds.origin.y += self.searchDisplayController.searchBar.bounds.size.height;
    self.tableView.bounds = tvBounds;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self hideSearchBar];
}

#pragma mark - UISearchDisplayDelegate

// 検索結果のtableViewをsearchBar分下に縮める
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    LOG_METHOD
    CGRect frame = self.searchDisplayController.searchResultsTableView.frame;
    frame.origin.y = self.searchDisplayController.searchBar.frame.size.height + 5;
    frame.size.height -= self.searchDisplayController.searchBar.frame.size.height - 5;
    self.searchDisplayController.searchResultsTableView.frame = frame;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

@end
