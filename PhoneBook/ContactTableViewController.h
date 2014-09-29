//
//  ContactTableViewController.h
//  PhoneBook
//
//  Created by paradigm creatives on 9/29/14.
//  Copyright (c) 2014 Paradigm Creatives. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "AddContactViewController.h"

@interface ContactTableViewController : UITableViewController<contacts,UIAlertViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    sqlite3 *dataBase;
    double idval;
    
}
@property (strong, nonatomic) NSIndexPath *indexPathToBeDeleted;

-(NSString*)getDbFileFromProject;
-(void)CopyDbFiles;

@end