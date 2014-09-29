
//
//  ContactTableViewController.m
//  PhoneBook
//
//  Created by paradigm creatives on 9/29/14.
//  Copyright (c) 2014 Paradigm Creatives. All rights reserved.
//

#import "ContactTableViewController.h"
#import "AddContactViewController.h"
#import "Contacts.h"

@interface ContactTableViewController ()

@end

@implementation ContactTableViewController
NSArray *section_Data;
NSMutableArray *searchResults;
NSMutableArray *data;

NSMutableArray *obj_array;
Contacts *con;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    data=[[NSMutableArray alloc]init];
    
    obj_array=[[NSMutableArray alloc]init];
    searchResults=[[NSMutableArray alloc]init];
    
    con=[[Contacts alloc]init];
    [self CopyDbFiles];
    
    [self firstview];
}
-(NSString*)getDbFileFromDocumentDirectory
{
    NSArray *arr=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *str=[arr objectAtIndex:0];
    str=[str stringByAppendingPathComponent:@"ContactsDB.sqlite"];
    return str;
    
}
-(NSString*)getDbFileFromProject
{
    NSString *sqliteFilePath = [[NSBundle mainBundle] bundlePath];
    sqliteFilePath = [sqliteFilePath stringByAppendingPathComponent:@"ContactsDB.sqlite"];
    return sqliteFilePath;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    }
    else{
       
    // Return the number of rows in the section.
       return [obj_array count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Contacts *contacts=[obj_array objectAtIndex:indexPath.row];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
    }
    else{
        // Configure the cell...
    cell.textLabel.text=contacts.name;
    NSNumber *num=[NSNumber numberWithDouble:contacts.number];
    cell.detailTextLabel.text=[num stringValue];
    }
    
    return cell;
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
   
    [searchResults removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    searchResults = [NSMutableArray arrayWithArray:[data filteredArrayUsingPredicate:predicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}
-(void) firstview{
    NSString *filepath=[self getDbFileFromDocumentDirectory];
    const char *utfstring=[filepath UTF8String];
    if((sqlite3_open(utfstring, &dataBase)==SQLITE_OK))
       {
           NSString *selectQuery = [NSString stringWithFormat:@"select * from  Contacts"];
           const char *queryUtf8 = [selectQuery UTF8String];
           sqlite3_stmt *statment;
           if (sqlite3_prepare(dataBase, queryUtf8, -1, &statment, NULL)==SQLITE_OK )
           {
               while (sqlite3_step(statment)==SQLITE_ROW)
               {
                   
                   //Student *studentObj = [[Student alloc] init];
                   Contacts *conObj=[[Contacts alloc]init];
                   
                   conObj.name=[NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statment, 0)];
                   conObj.number=(double)sqlite3_column_double(statment, 1);
                   
                   [obj_array addObject:conObj];
                   [data addObject:conObj.name];
                   
                   NSLog(@"objecta rray---%@",obj_array);
                   NSLog(@"data rray---%@",data);

                   
               }
           }
           sqlite3_finalize(statment);
       }
       sqlite3_close(dataBase);
       
       [self.tableView reloadData];
  
}
-(void)getDetails:(Contacts *)con_obj{
           [obj_array addObject:con_obj];
    [data addObject:con_obj.name];
     [self.tableView reloadData];
           
       }

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
  return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.indexPathToBeDeleted = indexPath;
        
        Contacts *tempObject=[obj_array objectAtIndex:indexPath.row];
        idval=tempObject.number;
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
        [alert show];
        
       // [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // This method is invoked in response to the user's action. The altert view is about to disappear (or has been disappeard already - I am not sure)
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"NO"])
    {
        NSLog(@"Nothing to do here");
    }
    else if([title isEqualToString:@"YES"])
    {
        NSLog(@"Delete the cell");
        
        [obj_array removeObjectAtIndex:[self.indexPathToBeDeleted row]];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathToBeDeleted] withRowAnimation:UITableViewRowAnimationFade];
        [self deleteRow];
        
        
    }
}

-(void)deleteRow
{
    NSString *dbFilePath =[self getDbFileFromDocumentDirectory];
    const char *dbUtfString = [dbFilePath UTF8String];
    if (sqlite3_open(dbUtfString, &dataBase)==SQLITE_OK)
    {
        NSString *selectQuery = [NSString stringWithFormat:@"delete from Contacts where number=%f",idval];
        const char *queryUtf8 = [selectQuery UTF8String];
        sqlite3_stmt *statment;
        if (sqlite3_prepare(dataBase, queryUtf8, -1, &statment, NULL)==SQLITE_OK )
        {
            if(sqlite3_step(statment) == SQLITE_DONE){
                NSLog(@"deleted");
            }
        }
        sqlite3_finalize(statment);
    }
    sqlite3_close(dataBase);
}


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

-(void)CopyDbFiles
{
    NSString *appDbPath = [self getDbFileFromProject];
    NSString *documentDbPath = [self getDbFileFromDocumentDirectory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:documentDbPath])
    {
        NSError *error=nil;
        BOOL isSucess = [fileManager copyItemAtPath:appDbPath toPath:documentDbPath error:&error];
        if (isSucess) {
            
            NSLog(@"Copied Sucess");
            
        }
        else{
            NSLog(@"Copied Failure: %@",[error localizedDescription]);
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"phonebook"])
    {
        AddContactViewController *seg=[segue destinationViewController];
        seg.deleagate=self;
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
