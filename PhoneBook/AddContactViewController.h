//
//  AddContactViewController.h
//  PhoneBook
//
//  Created by paradigm creatives on 9/29/14.
//  Copyright (c) 2014 Paradigm Creatives. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"
#import <sqlite3.h>

@protocol contacts<NSObject>
@required
-(void) getDetails:(Contacts *)con_obj;


@end
@interface AddContactViewController : UIViewController

{
    id deleagate;
    sqlite3 *dataBase;

    
}
@property(nonatomic,weak) id<contacts> deleagate;

-(NSString*)getDbFileFromProject;
-(NSString*)getDbFileFromDocumentDirectory;
-(void)CopyDbFiles;

-(IBAction)DoneClicked:(id)sender;
@end
