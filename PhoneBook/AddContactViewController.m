//
//  AddContactViewController.m
//  PhoneBook
//
//  Created by paradigm creatives on 9/29/14.
//  Copyright (c) 2014 Paradigm Creatives. All rights reserved.
//

#import "AddContactViewController.h"
#import "ContactTableViewController.h"
#import "Contacts.h"

@interface AddContactViewController ()
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
- (IBAction)addContact:(id)sender;

@end

@implementation AddContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.nameField becomeFirstResponder];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString*)getDbFileFromProject
{
    NSString *sqliteFilePath = [[NSBundle mainBundle] bundlePath];
    sqliteFilePath = [sqliteFilePath stringByAppendingPathComponent:@"ContactsDB.sqlite"];
    return sqliteFilePath;
}
-(NSString*)getDbFileFromDocumentDirectory
{
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *dbPath = [arr objectAtIndex:0];
    dbPath = [dbPath stringByAppendingPathComponent:@"ContactsDB.sqlite"];
    return dbPath;
}
-(void)CopyDbFiles
{
    NSString *appDbPath = [self getDbFileFromProject];
    NSString *documentDbPath = [self getDbFileFromDocumentDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:documentDbPath])
    {
        BOOL isSucess = [fileManager copyItemAtPath:appDbPath toPath:documentDbPath error:nil];
        if (isSucess) {
            
            NSLog(@"Copied Sucess");
            
        }
        else{
            NSLog(@"Copied Failure");
        }
    }
}

-(void)insert:(Contacts *)conobj{
    NSString *dbFilePath =[self getDbFileFromDocumentDirectory];
    const char *dbUtfString = [dbFilePath UTF8String];
    NSString *name = conobj.name;
    //NSString *section = studentObj.section;
    double num=conobj.number;
    if (sqlite3_open(dbUtfString, &dataBase)==SQLITE_OK)
    {
      
        NSLog(@"name and number are %@,%f",name,num);
        
        NSString *insertQuery = [NSString stringWithFormat:@"Insert Into Contacts Values('%@',%f)",name,num];
        const char *queryUtf8 = [insertQuery UTF8String];
        sqlite3_stmt *statment;
        if (sqlite3_prepare(dataBase, queryUtf8, -1, &statment, NULL)==SQLITE_OK )
        {
            if (sqlite3_step(statment)==SQLITE_DONE)
            {
                NSLog(@"Inserted Scussessfully");
            }
            else{
                NSAssert1(0, @"Error Description", sqlite3_errmsg(dataBase));
            }
        }
        sqlite3_finalize(statment);
        
    }
    sqlite3_close(dataBase);
    NSLog(@"ccccccc");
    
    
   }

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




-(IBAction)DoneClicked:(id)sender{


    Contacts *conObj=[[Contacts alloc]init];
    conObj.name=_nameField.text;;
    conObj.number=[_numberField.text doubleValue];
    [self CopyDbFiles];
    [self insert:conObj];
    //[self.numberField resignFirstResponder];
    [self.deleagate getDetails:conObj];
    [self.navigationController popToRootViewControllerAnimated:YES];

}

@end
