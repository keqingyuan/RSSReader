//
//  TAKViewController.h
//  RSSReader
//
//  Created by Onion on 15-1-25.
//  Copyright (c) 2015年 tak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAKViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblNews;
- (IBAction)removeDataFile:(id)sender;

@end
