
NSData *LoadImageFromFile(NSString* file_name,
						 int* out_width,
						 int* out_height,
						 int* out_channels);

NSData *CompressImage(NSMutableData*,
						 int width,
						 int height,
             int bytesPerPixel);

