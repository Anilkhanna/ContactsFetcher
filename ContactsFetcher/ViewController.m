//
//  ViewController.m
//  ContactsFetcher
//
//  Created by Anil Khanna on 11/12/14.
//  Copyright (c) 2014 Anil Khanna. All rights reserved.
//

#import "ViewController.h"
#import "ContactsFetcher.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [ContactsFetcher fetchContactsWithOptions:FetchAllInfo WithCompletion:^(NSArray *contacts) {
        NSLog(@"%@",contacts);
        
    } failure:^(NSError *error) {
        
        NSLog(@"%@",error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
