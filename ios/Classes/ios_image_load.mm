#import <Flutter/Flutter.h>
#include "ios_image_load.h"

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>

#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>

NSData *LoadImageFromFile(NSString* file_name,
                                     int* out_width, int* out_height,
                                     int* out_channels) {
  CGDataProviderRef image_provider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:file_name]);
  CGImageRef image;
  if ([file_name hasSuffix:@".png"]) {
    image = CGImageCreateWithPNGDataProvider(image_provider, NULL, true,
                                             kCGRenderingIntentDefault);
  } else if ([file_name hasSuffix:@".jpg"] || [file_name hasSuffix:@".jpeg"]) {
    image = CGImageCreateWithJPEGDataProvider(image_provider, NULL, true,
                                              kCGRenderingIntentDefault);
  } else {
    CFRelease(image_provider);
    out_width = 0;
    out_height = 0;
    *out_channels = 0;
    return NULL;
  }
  
  int width = (int)CGImageGetWidth(image);
  int height = (int)CGImageGetHeight(image);
  const int channels = 4;
  CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
  const int bytes_per_row = (width * channels);
  const int bytes_in_image = (bytes_per_row * height);
  const int bits_per_component = 8;

  CGContextRef context = CGBitmapContextCreate(NULL, width, height,
                                               bits_per_component, bytes_per_row, color_space,
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(color_space);
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
  NSData* result =  [[NSData alloc] initWithBytes:CGBitmapContextGetData(context) length:bytes_in_image];
  CGContextRelease(context);
  CFRelease(image);
  CFRelease(image_provider);
  
  *out_width = width;
  *out_height = height;
  *out_channels = channels;
  return result;
}

NSData *CompressImage(NSMutableData *image, int width, int height, int bytesPerPixel) {
  const int channels = 4;
  CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate([image mutableBytes], width, height,
                                               bytesPerPixel*8, width*channels*bytesPerPixel, color_space,
                                               kCGImageAlphaPremultipliedLast | (bytesPerPixel == 4 ? kCGBitmapFloatComponents : kCGBitmapByteOrder32Big));
  CGColorSpaceRelease(color_space);
  if (context == nil) return nil;

  CGImageRef imgRef = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  if (imgRef == nil) return nil;

  UIImage* img = [UIImage imageWithCGImage:imgRef];
  CGImageRelease(imgRef);
  if (img == nil) return nil;

  return UIImagePNGRepresentation(img);
}
