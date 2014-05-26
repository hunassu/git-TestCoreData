//
//  ViewController.m
//  TestCoreData
//
//  Created by 麻生秀久 on 2014/05/26.
//  Copyright (c) 2014年 麻生秀久. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    NSManagedObjectContext *moc;
    NSArray *data;
    UITableView *tv;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    data = nil;
    
    //データモデル
    
    NSBundle *bd = [NSBundle mainBundle];
    NSString *rpath = [bd pathForResource:@"ProductModel" ofType:@"momd"];
    NSURL *rurl = [NSURL fileURLWithPath:rpath];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:rurl];
    
    //データベース
    
    BOOL isFile = NO;
    NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fpath = [NSString stringWithFormat:@"%@/Product.sqlite",dir];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fpath]) {
        isFile = YES;
    }
    NSURL *furl = [NSURL fileURLWithPath:fpath];
    
    NSError *err = nil;
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:mom];
    [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:furl options:nil error:&err];
    
    if (err != nil) {
        NSLog(@"Error.");
        abort();
    }
    
    moc = [[NSManagedObjectContext alloc]init];
    [moc setPersistentStoreCoordinator:psc];
    
    if (isFile == NO) {
        NSManagedObject *mo1 = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:moc];
        [mo1 setValue:@"鉛筆" forKeyPath:@"name"];
        [mo1 setValue:[[NSNumber alloc]initWithInt:70] forKeyPath:@"price"];
        
        err = nil;
        [moc save:&err];
        if (err != nil) {
            NSLog(@"Error.");
            abort();
        }
    }
    
    //取り出し
    NSFetchRequest *fr = [[NSFetchRequest alloc]init];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:moc];
    fr.entity = ed;
    
    err = nil;
    data = [moc executeFetchRequest:fr error:&err];
    if(err != nil){
        NSLog(@"Error.");
        abort();
    }
    
    tv = [[UITableView alloc]init];
    tv.frame = CGRectMake(0, 30, 1130, 320);
    
    tv.delegate = self;
    tv.dataSource = self;
    
    [self.view addSubview:tv];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSManagedObject *mo = [data objectAtIndex:indexPath.row];
    NSString *nm = [mo valueForKeyPath:@"name"];
    NSNumber *pr = [mo valueForKeyPath:@"price"];
    
    NSString *prstr = [NSString stringWithFormat:@"%@円",[pr stringValue]];
    cell.textLabel.text = nm;
    cell.detailTextLabel.text = prstr;
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end












