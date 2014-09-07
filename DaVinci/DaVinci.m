//
// DaVinci.m
//
// Copyright (c) 2014 Pedro Vieira ( http://pedrovieira.me/ ).
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DaVinci.h"

#if TARGET_OS_IPHONE
#define DaVinciImage UIImage
#else
#define DaVinciImage NSImage
#endif


//Alpha Values
const int DaVinciAlphaComponentFullyOpaque = 255;
const int DaVinciAlphaComponentFullyTransparent = 0;

//Additional values
const int DaVinciNumberOfComponentsInRGB = 3;
const int DaVinciNumberOfComponentsInRGBA = 4;
const size_t DaVinciBitsPerRGBAComponent = 8;
const int DaVinciBytesPerPixel = 4;

@implementation DaVinci

+ (NSData *)generatePNGDataFromString:(NSString *)str {
    if (!str || str.length == 0) {
        return nil;
    }
    
    
    NSString *base64String;
    NSData *utf8StringData = [str dataUsingEncoding:NSUTF8StringEncoding];
    if ([utf8StringData respondsToSelector:@selector(base64EncodedDataWithOptions:)]) {
        base64String = [utf8StringData base64EncodedStringWithOptions:0];
    } else {
        base64String = [utf8StringData base64Encoding];
    }
    
    NSMutableArray *rgbArray = [NSMutableArray new];
    
    for (int i = 0; i < base64String.length; i++) {
        [rgbArray addObject:@([base64String characterAtIndex:i])];
    }
    
    CGSize imageFinalSize = [self calculateFinalImageSizeAndAddRGBComponentsToArrayIfNeeded:&rgbArray];
    
    const size_t width = imageFinalSize.width;
    const size_t height = imageFinalSize.height;
    const size_t area = width * height;
    
    uint8_t pixelData[area * DaVinciNumberOfComponentsInRGBA];
    for (int i = 0; i < area; i++) {
        int offset = i * DaVinciNumberOfComponentsInRGBA;
        int rgbOffset = i * 3;
        BOOL canBeTransparent = [self checkIfAlphaCanBeFullyTransparentWithRed:rgbArray[rgbOffset] green:rgbArray[rgbOffset+1] blue:rgbArray[rgbOffset+2]];
        
        pixelData[offset] = [rgbArray[rgbOffset++] intValue];       //Red
        pixelData[offset + 1] = [rgbArray[rgbOffset++] intValue];   //Green
        pixelData[offset + 2] = [rgbArray[rgbOffset++] intValue];   //Blue
        
        //Alpha
        //the Alpha value will be 255 (fully opaque) when the RGB components have data that it's needed
        //otherwise it'll be 0 and the RGB data will be discarded
        pixelData[offset + 3] = canBeTransparent ? DaVinciAlphaComponentFullyTransparent : DaVinciAlphaComponentFullyOpaque;
    }
    
    const size_t bytesPerRow = DaVinciBytesPerPixel * width;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(&pixelData, width, height, DaVinciBitsPerRGBAComponent, bytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGImageRef toCGImage = CGBitmapContextCreateImage(context);
    
    NSData *pngData;
#if TARGET_OS_IPHONE
    pngData = UIImagePNGRepresentation([UIImage imageWithCGImage:toCGImage]);
#else
    pngData = [[[NSBitmapImageRep alloc] initWithCGImage:toCGImage] representationUsingType:NSPNGFileType properties:nil];
#endif
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return pngData;
}

+ (BOOL)checkIfAlphaCanBeFullyTransparentWithRed:(NSNumber *)red green:(NSNumber *)green blue:(NSNumber *)blue {
    return red.intValue == 0 && green.intValue == 0 && blue.intValue == 0;
}

+ (CGSize)calculateFinalImageSizeAndAddRGBComponentsToArrayIfNeeded:(NSMutableArray **)array {
    NSMutableArray *rgbArray = *array;
    
    //first, we'll check if the rgb array is completed (which means the array has all groups of 3 values — R/G/B — completed)
    //if not, we'll add the missing components with a value of 0 to complete it
    while (rgbArray.count % DaVinciNumberOfComponentsInRGB != 0) {
        [rgbArray addObject:@(0)];
    }
    
    
    //right now, DaVinci is defined to create a square PNG image, which means it'll have the same width & height
    //so, the following code will make sure the square root of the total number of pixels (= nr of components in array / 3) in the image doesn't have any decimal cases
    //which means it's a perfect square
    float squareRoot = sqrtf(rgbArray.count / DaVinciNumberOfComponentsInRGB);
    while (squareRoot != (int)squareRoot) {
        [rgbArray addObject:@(0)];
        
        squareRoot = sqrtf(rgbArray.count / DaVinciNumberOfComponentsInRGB);
    }
    
    return CGSizeMake(squareRoot, squareRoot);
}

+ (NSString *)retrieveStringFromPNGData:(NSData *)data {
    DaVinciImage *realImage = [[DaVinciImage alloc] initWithData:data];
    if (!realImage) {
        return nil;
    }
    
    NSMutableString *str = [NSMutableString new];
    uint8_t *pixelData;
    NSInteger imgTotalArea;
    
#if TARGET_OS_IPHONE
    CGImageRef imageRef = [realImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    imgTotalArea = width * height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    pixelData = calloc(imgTotalArea * DaVinciNumberOfComponentsInRGBA, sizeof(uint8_t));
    
    NSUInteger bytesPerRow = DaVinciBytesPerPixel * width;
    CGContextRef context = CGBitmapContextCreate(pixelData, width, height, DaVinciBitsPerRGBAComponent, bytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
#else
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:data];
    pixelData = rep.bitmapData;
    
    imgTotalArea = rep.pixelsWide * rep.pixelsHigh;
#endif
    
    for (int i = 0; i < imgTotalArea; i++) {
        size_t offset = i * DaVinciNumberOfComponentsInRGBA;
        
        //Alpha
        if (pixelData[offset + 3] == DaVinciAlphaComponentFullyTransparent) {
            //if the Alpha value is 0 (fully transparent), we don't need to get more data because, from now on, all the real data is over
            break;
        }
        
        [str appendFormat:@"%c", pixelData[offset]];        //Red
        [str appendFormat:@"%c", pixelData[offset + 1]];    //Green
        [str appendFormat:@"%c", pixelData[offset + 2]];    //Blue
    }
    
    NSData *base64StringData;
    if ([NSData instancesRespondToSelector:@selector(initWithBase64EncodedString:options:)]) {
        base64StringData = [[NSData alloc] initWithBase64EncodedString:str options:0];
    } else {
        base64StringData = [[NSData alloc] initWithBase64Encoding:str];
    }
    NSString *originalString = [[NSString alloc] initWithData:base64StringData encoding:NSUTF8StringEncoding];
    
#if TARGET_OS_IPHONE
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(pixelData);
#endif
    
    return originalString;
}

@end