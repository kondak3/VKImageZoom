# VKImageZoom

## Requirements:

- iOS 8 or higher

- Automatic Reference Counting (ARC)


## Usage:

- Drag and drop "VKImageZoom" folder into your resource

- import "VKImageZoom.h"

```
// if you have image use this below one...
VKImageZoom *imgZoom = [[VKImageZoom alloc] initWithNibName:nil bundle:nil];
imgZoom.image = [UIImage imageNamed:@"you image name"];
[self presentViewController:imgZoom animated:YES completion:nil];
```

```
// if you have image url use this below one...
VKImageZoom *imgZoom = [[VKImageZoom alloc] initWithNibName:nil bundle:nil];
imgZoom.image_url = [[NSURL alloc] initWithString:@"you image name"];
[self presentViewController:imgZoom animated:YES completion:nil];
```
