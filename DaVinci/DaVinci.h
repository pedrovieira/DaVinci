//
// DaVinci.h
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

#import <Foundation/Foundation.h>

@interface DaVinci : NSObject

/**
 Generates a new PNG image (as a NSData object) that has the string, given in the parameters, embedded insite it.
 
 @param str The string that will be used to generate the PNG image data.
 
 @return A NSData object that contains the newly created PNG data with the string embedded inside it.
 */
+ (NSData *)generatePNGDataFromString:(NSString *)str;

/**
 Retrieves the original string that was embedded inside a PNG image.
 
 @param data A valid NSData that comes from a PNG image that was originally created via DaVinci (otherwise it'll return @c nil or a totally random string).
 
 @return A NSString that has the original string that was embedded inside the PNG image.
 */
+ (NSString *)retrieveStringFromPNGData:(NSData *)data;

@end