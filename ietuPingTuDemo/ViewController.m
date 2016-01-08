//
//  ViewController.m
//  ietuPingTuDemo
//
//  Created by jiangtd on 16/1/8.
//  Copyright © 2016年 jiangtd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *imgArr;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
    
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"截图" style:UIBarButtonItemStylePlain target:self action:@selector(screenShot:)];
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"拼图" style:UIBarButtonItemStylePlain target:self action:@selector(combinImg:)];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
}

#pragma mark ============TableView Delegate=============

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identyId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identyId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identyId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"内容%ld",(long)indexPath.row];
    return cell;
    
}

#pragma mark ====================Action=================

-(void)screenShot:(id)sender
{
   
    CGFloat contentHight = self.tableView.contentInset.top + self.tableView.contentSize.height;
    CGFloat imgHight = self.tableView.frame.size.height;
    NSInteger imgCount =(NSInteger)((contentHight / imgHight) + 0.99999);
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    [self.imgArr removeAllObjects];
    
    for (int i = 0; i<imgCount; i++) {
        UIGraphicsBeginImageContext(self.view.bounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if ([[UIDevice currentDevice].systemVersion integerValue] > 8.0) {
            [self.tableView drawViewHierarchyInRect:CGRectMake(0, 0, self.view.bounds.size.width, imgHight) afterScreenUpdates:YES];
        }
        else
        {
            [self.tableView.layer renderInContext:context];
        }
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        [self.imgArr addObject:img];
        UIGraphicsEndImageContext();
        
        NSData *imgData = UIImagePNGRepresentation(img);
       
        NSString* path = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"img%d.png",i]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //异步写到文件中可打开文件查看
            [imgData writeToFile:path atomically:YES];

        });
        NSLog(@"path:%@",path);
        self.tableView.contentOffset = CGPointMake(0,self.tableView.contentOffset.y + self.tableView.frame.size.height);
    }
}

-(void)combinImg:(id)sender
{
    if (self.imgArr.count <=0 ) {
        return;
    }
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    CGFloat tatolHight = self.tableView.contentSize.height +  self.tableView.contentInset.top;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.tableView.frame.size.width, tatolHight), NO, 1);
    
    CGFloat orgy = 0;
    for(int i = 0; i < self.imgArr.count;i++)
    {
        UIImage *image = (UIImage*)self.imgArr[i];
        [image drawInRect:CGRectMake(0, orgy,image.size.width, image.size.height)];
        orgy += image.size.height;

    }
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.tableView.frame.size.height )];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.tableView.contentSize.height + 64);
    scrollView.backgroundColor = [UIColor brownColor];
    [self.view addSubview:scrollView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, scrollView.frame.size.width, self.tableView.contentSize.height)];
    imgView.backgroundColor = [UIColor purpleColor];
    imgView.image = img;
    [scrollView addSubview:imgView];
    //写到文件中可打开文件查看
    NSString *path = [rootPath stringByAppendingPathComponent:@"combin.png"];
    NSData *imgData = UIImagePNGRepresentation(img);
    [imgData writeToFile:path atomically:YES];
}

#pragma mark ===========GetMethod=============

-(NSMutableArray*)imgArr
{
    if (!_imgArr) {
        _imgArr = [NSMutableArray array];
    }
    return _imgArr;
}

@end















