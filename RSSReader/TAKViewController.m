//
//  TAKViewController.m
//  RSSReader
//
//  Created by Onion on 15-1-25.
//  Copyright (c) 2015年 tak. All rights reserved.
//

#import "TAKViewController.h"
#import "XMLParser.h"

#define NewsFeed @"http://cn.reuters.com/rssFeed/CNAnalysesNews/"


@interface TAKViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *arrNewsData;
@property (nonatomic, strong) NSString *dataFilePath;
-(void) refreshData;
-(void) performNewFetchedDataActionWithDataArray:(NSArray *) dataArray;
@end

@implementation TAKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //1.设置tableView的委托和数据源
    [self.tblNews setDelegate:self];
    [self.tblNews setDataSource:self];
    //2.设置指定文件的存储path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [path objectAtIndex:0];
    self.dataFilePath = [docDirectory stringByAppendingString:@"newsdata"];
    //3.初始化刷新控制器
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tblNews addSubview:self.refreshControl];
//    [self refreshData];
    //加载本地数据
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataFilePath]) {
        self.arrNewsData = [[NSMutableArray alloc] initWithContentsOfFile:self.dataFilePath];
        [self.tblNews reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)removeDataFile:(id)sender {
}
-(void) refreshData
{
    XMLParser *xmlParser = [[XMLParser alloc] initWithXMLURLString:NewsFeed];
    [xmlParser startParsingWithCompletionHandler:^(BOOL success, NSArray *dataArray, NSError *error) {
        if (success) {
            [self performNewFetchedDataActionWithDataArray:dataArray];
            [self.refreshControl endRefreshing];
        }
        else{
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}
-(void) performNewFetchedDataActionWithDataArray:(NSArray *)dataArray
{
    //1.初始化数据通过穿过来的dataArray
    if (self.arrNewsData != nil) {
        self.arrNewsData = nil;
    }
    //2.加载数据到tableView
    self.arrNewsData = [[NSArray alloc] initWithArray:dataArray];
    [self.tblNews reloadData];
    //3.保存数据到文件
    if (! [self.arrNewsData writeToFile:self.dataFilePath atomically:YES]) {
        NSLog(@"Couldn't save data.");
    }
}

#pragma mark - UItableView delegate method implemention
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrNewsData.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellNewsTitle"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    NSDictionary *dict = [self.arrNewsData objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"title"];
    cell.detailTextLabel.text = [dict objectForKey:@"pubDate"];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.arrNewsData objectAtIndex:indexPath.row];
    NSString *newsLink = [dict objectForKey:@"link"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newsLink ]];
}
@end
