//
//  MAPFileManager.m
//  MapillarySDK
//
//  Created by Anders Mårtensson on 2017-08-24.
//  Copyright © 2017 Mapillary. All rights reserved.
//

#import "MAPFileManager.h"
#import "MAPInternalUtils.h"
#import "MAPGpxParser.h"

@implementation MAPFileManager

+ (void)listSequences:(void(^)(NSArray* sequences))result
{
    if (result == nil)
    {
        return;
    }
    
    NSMutableArray* sequences = [[NSMutableArray alloc] init];
    NSString* sequenceDirectory = [MAPInternalUtils sequenceDirectory];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError* error = nil;
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sequenceDirectory error:&error];
        
        if (!error)
        {
            for (NSString* path in contents)
            {
                MAPSequence* sequence = [[MAPSequence alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", sequenceDirectory, path]];
                [sequences addObject:sequence];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            result(sequences);
            
        });
        
    });
}

+ (void)deleteSequence:(MAPSequence*)sequence
{
    NSFileManager* fm = [NSFileManager defaultManager];

    // Delete folder
    [fm removeItemAtPath:sequence.path error:nil];
}

@end
