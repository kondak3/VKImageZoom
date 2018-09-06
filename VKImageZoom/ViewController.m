//
//  ViewController.m
//  VKImageZoom
//
//  Created by Kondaiah V on 9/6/18.
//  Copyright © 2018 Kondaiah Veeraboyina. All rights reserved.
//

#import "ViewController.h"
#import "VKImageZoom.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addImage_buttonClicked:(UIButton *)sender {
    
    // image zooming...
    VKImageZoom *imgZoom = [[VKImageZoom alloc] initWithNibName:nil bundle:nil];
    imgZoom.image = [UIImage imageNamed:@"rose_victor.jpg"];
    [self presentViewController:imgZoom animated:YES completion:nil];
    
    // rose_victor.jpg //rose.jpeg //dahlia_blossom.jpeg
}

- (IBAction)addImageUrl_buttonClicked:(UIButton *)sender {
    
    // image zooming...
    VKImageZoom *imgZoom = [[VKImageZoom alloc] initWithNibName:nil bundle:nil];
    imgZoom.image_url = [[NSURL alloc] initWithString:@"http://cdn.playbuzz.com/cdn/38402fff-32a3-4e78-a532-41f3a54d04b9/cc513a85-8765-48a5-8481-98740cc6ccdc.jpg"];
    [self presentViewController:imgZoom animated:YES completion:nil];
    
    // http://i.imgur.com/w5rkSIj.jpg
    // http://cdn.playbuzz.com/cdn/38402fff-32a3-4e78-a532-41f3a54d04b9/cc513a85-8765-48a5-8481-98740cc6ccdc.jpg
}

@end
