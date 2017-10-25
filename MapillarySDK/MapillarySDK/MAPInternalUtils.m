//
//  Utils.m
//  MapillarySDK
//
//  Created by Anders Mårtensson on 2017-08-25.
//  Copyright © 2017 Mapillary. All rights reserved.
//

#import "MAPInternalUtils.h"
#include <sys/xattr.h>

@implementation MAPInternalUtils

+ (NSString *)getTimeString:(NSDate*)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss_SSS";
    dateFormatter.AMSymbol = @"";
    dateFormatter.PMSymbol = @"";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    
    if (date == nil)
    {
        date = [NSDate date];
    }
    
    NSString* dateString = [[dateFormatter stringFromDate:date] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return dateString;
}

+ (NSString *)documentsDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

+ (NSString *)basePath
{
    return [NSString stringWithFormat:@"%@/%@", [self documentsDirectory], @"mapillary"];
}

+ (NSString *)sequenceDirectory
{
    return [NSString stringWithFormat:@"%@/%@", [self basePath], @"sequences"];
}


+ (BOOL)createSubfolderAtPath:(NSString *)path folder:(NSString *)folder
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *newFolderPath = [path stringByAppendingPathComponent:folder];
    
    if (![fm fileExistsAtPath:newFolderPath])
    {
        NSLog(@"Creating %@", newFolderPath);
        BOOL success = [fm createDirectoryAtPath:newFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        if (success)
        {
            [self addSkipBackupAttributeToItemAtPath:newFolderPath];
        }
        
        return success;
    }
    
    return NO;
}

+ (BOOL)createFolderAtPath:(NSString *)path
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:path])
    {
        BOOL success = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        
        if (success)
        {
            [self addSkipBackupAttributeToItemAtPath:path];
        }
        
        return success;
    }
    
    return NO;
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL* fileURL = [NSURL fileURLWithPath:filePathString];
    
    const char* filePath = [fileURL.path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

+ (NSDate*)dateFromFilePath:(NSString*)filePath
{
    NSString* fileName = [filePath lastPathComponent];
    NSString* strippedFileName = [fileName stringByDeletingPathExtension];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss_SSS";
    dateFormatter.AMSymbol = @"";
    dateFormatter.PMSymbol = @"";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    
    return [dateFormatter dateFromString:strippedFileName];
}

+ (NSString*)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


#pragma mark - Internal

+ (float)calculateFactorFromDates:(NSDate*)date date1:(NSDate*)date1 date2:(NSDate*)date2
{
    if (date1 == nil)
    {
        return 1;
    }
    
    if (date2 == nil)
    {
        return 0;
    }
    
    if ([date1 isEqualToDate:date2])
    {
        return 0;
    }
    
    return fabs([date1 timeIntervalSinceDate:date]/[date1 timeIntervalSinceDate:date2]);
}

+ (CLLocationCoordinate2D)interpolateCoords:(CLLocationCoordinate2D)location1 location2:(CLLocationCoordinate2D)location2 factor:(float)factor
{
    if (factor == 0)
    {
        return location1;
    }
    
    if (factor == 1)
    {
        return location2;
    }
    
    return CLLocationCoordinate2DMake((1-factor)*location1.latitude +factor*location2.latitude,
                                      (1-factor)*location1.longitude+factor*location2.longitude);
}

+ (double)calculateHeadingFromCoordA:(CLLocationCoordinate2D)A B:(CLLocationCoordinate2D)B
{
    double lat1 = A.latitude;
    double lon1 = A.longitude;
    double lat2 = B.latitude;
    double lon2 = B.longitude;
    
    // From http://www.movable-type.co.uk/scripts/latlong.html
    double phi1 = lat1*M_PI/180.0;
    double phi2 = lat2*M_PI/180.0;
    double d1 = (lon2-lon1)*M_PI/180.0;
    double y = sin(d1) * cos(phi2);
    double x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(d1);
    double heading = atan2(y, x)*180.0/M_PI;
    
    heading = (heading < 360) ? heading + 360 : heading; // 0 - 360
    heading = (heading > 360) ? heading - 360 : heading; // 0 - 360
    
    return heading;
}


@end
