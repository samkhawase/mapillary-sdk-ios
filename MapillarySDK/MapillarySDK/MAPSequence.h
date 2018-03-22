//
//  MAPSequence.h
//  MapillarySDK
//
//  Created by Anders Mårtensson on 2017-08-24.
//  Copyright © 2017 Mapillary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAPLocation.h"
#import "MAPDevice.h"
#import "MAPImage.h"

@interface MAPSequence : NSObject

@property CLLocationDirection directionOffset; // (-1 = undefined, 0-360 = set),
@property NSTimeInterval timeOffset; // in milliseconds, +1 means the image date is increased by 1 ms. NSTimeIntervalSince1970 means not set
@property NSDate* sequenceDate;
@property NSString* path;
@property NSString* project;
@property NSString* sequenceKey;
@property MAPDevice* device;
@property NSUInteger imageCount;
@property NSUInteger sequenceSize;
@property int imageOrientation;

- (id)initWithDevice:(MAPDevice*)device;
- (id)initWithDevice:(MAPDevice*)device andProject:(NSString*)project;
- (id)initWithPath:(NSString*)path parseGpx:(BOOL)parseGpx;
    
- (void)addImageWithData:(NSData*)imageData date:(NSDate*)date location:(MAPLocation*)location;
- (void)addImageWithPath:(NSString*)imagePath date:(NSDate*)date location:(MAPLocation*)location;
- (void)addLocation:(MAPLocation*)location;
- (void)addGpx:(NSString*)path done:(void(^)(void))done;

- (void)processImage:(MAPImage*)image;
- (void)deleteImage:(MAPImage*)image;
- (void)deleteAllImages;

- (NSArray*)getImages;
- (void)getImagesAsync:(void(^)(NSArray* images))done;
- (void)getLocationsAsync:(void(^)(NSArray* locations))done;

- (MAPLocation*)locationForDate:(NSDate*)date;

- (BOOL)isLocked;

- (void)saveMetaChanges:(void(^)(void))done;

- (MAPImage*)getPreviewImage;

@end
