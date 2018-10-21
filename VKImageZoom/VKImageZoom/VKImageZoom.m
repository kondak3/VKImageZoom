//
//  VKImageZoom.m
//  VKImageZoom
//
//  Created by Kondaiah V on 9/6/18.
//  Copyright © 2018 Kondaiah Veeraboyina. All rights reserved.
//

#import "VKImageZoom.h"

@interface VKImageZoom () <UIScrollViewDelegate> {
    
    // default image width...
    float img_width;
    // default image height...
    float img_height;
    // image display scroll view...
    UIScrollView *img_scroll;
    // imageview for image...
    UIImageView *zoom_imgView;
    // dismiss button...
    UIButton *cancel_btn;
    // indicator...
    UIActivityIndicatorView *act_indicator;
}
@end


#define ZOOM_STEP 2.0
@implementation VKImageZoom

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // add components...
    self.view.backgroundColor = [UIColor blackColor];
    [self addView_components];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self addView_components];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)addView_components {
    
    img_width = self.view.frame.size.width;
    img_height = self.view.frame.size.height;
    float status_height = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    // create scroll view...
    if (img_scroll != nil) {
        [img_scroll removeFromSuperview];
    }
    img_scroll = [[UIScrollView alloc]init];
    img_scroll.frame = CGRectMake(0, status_height, img_width, img_height-(2*status_height));
    img_scroll.backgroundColor = [UIColor clearColor];
    img_scroll.bouncesZoom = YES;
    img_scroll.delegate = self;
    img_scroll.clipsToBounds = YES;
    img_scroll.maximumZoomScale = 4.0;
    img_scroll.minimumZoomScale = 1.0;
    img_scroll.zoomScale = 1.0;
    [self.view addSubview:img_scroll];
    
    // create zoom image view...
    zoom_imgView = [[UIImageView alloc] init];
    zoom_imgView.userInteractionEnabled = YES;
    zoom_imgView.backgroundColor = [UIColor clearColor];
    zoom_imgView.frame = CGRectMake(0, status_height, img_width, img_height-(2*status_height));
    zoom_imgView.center = img_scroll.center;
    [img_scroll addSubview:zoom_imgView];
    
    // create cancel button...
    if (cancel_btn != nil) {
        [cancel_btn removeFromSuperview];
    }
    cancel_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancel_btn.frame = CGRectMake((img_width-36), (status_height+6), 30, 30);
    cancel_btn.backgroundColor = [UIColor clearColor];
    [cancel_btn setTitle:@"X" forState:UIControlStateNormal];
    cancel_btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [cancel_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel_btn addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancel_btn];
    
    // corner radius...
    cancel_btn.layer.cornerRadius = 30/2;
    cancel_btn.layer.borderWidth = 2.0f;
    cancel_btn.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // create indicator...
    if (act_indicator != nil) {
        [act_indicator removeFromSuperview];
    }
    act_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    act_indicator.center = self.view.center;
    [act_indicator stopAnimating];
    [self.view addSubview:act_indicator];
    
    
    // loading images...
    [self loadingImages];
    
    // add double tab gesture to images...
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [zoom_imgView addGestureRecognizer:doubleTap];
    
    // Set zoom value Max = 2.0 & Min = 1.0
    img_scroll.contentSize = CGSizeMake(zoom_imgView.bounds.size.width, zoom_imgView.bounds.size.height);
    img_scroll.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (void)cancelButtonClicked:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    UIImageView *loImgView = (UIImageView *)gestureRecognizer.view;
    UIScrollView *loZoomView = (UIScrollView *)[loImgView superview];
    
    // zoom in
    float newScale = [loZoomView zoomScale] * ZOOM_STEP;
    if (newScale > loZoomView.maximumZoomScale) {
        
        newScale = loZoomView.minimumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view] sendImgView:loImgView];
        [loZoomView zoomToRect:zoomRect animated:YES];
    }
    else {
        
        newScale = loZoomView.maximumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view] sendImgView:loImgView];
        [loZoomView zoomToRect:zoomRect animated:YES];
    }
}


#pragma mark -
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center sendImgView:(UIImageView*)loZoomView {
    
    CGRect zoomRect = CGRectZero;
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [loZoomView frame].size.height / scale;
    zoomRect.size.width  = [loZoomView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (void)loadingImages {
    
    // static image zooming...
    if (self.image != nil) {
        
        // adding images...
        zoom_imgView.image = self.image;
        
        // image width and height calculations...
        CGSize imageSize = [self imageWidth_height:zoom_imgView.image];
        zoom_imgView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        zoom_imgView.center = img_scroll.center;
    }
    else if (self.image_url != nil) { // image loading with url...
        
        [act_indicator startAnimating];
        
        // downloading images...
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:self.image_url
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                                                            [self->act_indicator stopAnimating];
                                                            // error...
                                                            if (error != nil) {
                                                                NSLog(@"%@", error);
                                                                return;
                                                            }
                                                            
                                                            // adding images...
                                                            self->zoom_imgView.image = [UIImage imageWithData:data];
                                                            
                                                            // image width and height calculations...
                                                            CGSize imageSize = [self imageWidth_height:self->zoom_imgView.image];
                                                            self->zoom_imgView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
                                                            self->zoom_imgView.center = self->img_scroll.center;
                                                        });
                                                    }];
        [dataTask resume];
    }
    else {
        NSLog(@"No image allocated...");
    }
}

- (CGSize)imageWidth_height:(UIImage *)image {
    
    // image height & weight...
    float imgWidth = image.size.width;
    float imgHeight = image.size.height;
    
    if (imgWidth >= imgHeight) {
        
        // width ratio calculating...
        float widthRatio = imgWidth/img_width;
        float finalHeight = imgHeight/widthRatio;
        
        imgWidth = img_width;
        imgHeight = finalHeight;
    }
    else {
        
        // height ratio calculating...
        float heightRatio = imgHeight/img_height;
        float finalWidth = imgWidth/heightRatio;
        
        imgWidth = finalWidth;
        imgHeight = img_height;
    }
    return CGSizeMake(imgWidth, imgHeight);
}


#pragma mark -
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat offset_X = (scrollView.bounds.size.width > scrollView.contentSize.width)? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offset_Y = (scrollView.bounds.size.height > scrollView.contentSize.height)? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    for (int i=0; i<[scrollView subviews].count; i++) {
        if ([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[UIImageView class]]) {
            
            UIImageView *loimage = (UIImageView*)[[scrollView subviews] objectAtIndex:i];
            loimage.center = CGPointMake(scrollView.contentSize.width * 0.5 + offset_X, scrollView.contentSize.height * 0.5 + offset_Y);
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    UIImageView *loimage = nil;
    for (int i=0; i<[scrollView subviews].count; i++) {
        if ([[[scrollView subviews] objectAtIndex:i] isKindOfClass:[UIImageView class]]) {
            
            loimage = (UIImageView*)[[scrollView subviews] objectAtIndex:i];
            break;
        }
    }
    return loimage;
}

@end



