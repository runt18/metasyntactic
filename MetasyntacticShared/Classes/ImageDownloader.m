// Copyright 2010 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import "ImageDownloader.h"

#import "AbstractApplication.h"
#import "AutoreleasingMutableArray.h"
#import "FileUtilities.h"
#import "ImageCache.h"
#import "MetasyntacticSharedApplication.h"
#import "NetworkUtilities.h"
#import "ThreadingUtilities.h"

@interface ImageDownloader()
@property (retain) NSCondition* downloadImagesCondition;
@property (retain) AutoreleasingMutableArray* imagesToDownload;
@property (retain) AutoreleasingMutableArray* priorityImagesToDownload;
@end


@implementation ImageDownloader

static ImageDownloader* downloader;

+ (void) initialize {
  if (self == [ImageDownloader class]) {
    downloader = [[ImageDownloader alloc] init];
  }
}


+ (ImageDownloader*) downloader {
  return downloader;
}

@synthesize downloadImagesCondition;
@synthesize imagesToDownload;
@synthesize priorityImagesToDownload;

- (void) dealloc {
  self.downloadImagesCondition = nil;
  self.imagesToDownload = nil;
  self.priorityImagesToDownload = nil;

  [super dealloc];
}


- (id) init {
  if ((self = [super init])) {
    self.downloadImagesCondition = [[[NSCondition alloc] init] autorelease];
    self.imagesToDownload = [AutoreleasingMutableArray array];
    self.priorityImagesToDownload = [AutoreleasingMutableArray array];

    [ThreadingUtilities backgroundSelector:@selector(downloadImagesBackgroundEntryPoint)
                                  onTarget:self
                                      gate:nil
                                    daemon:YES];
  }

  return self;
}


- (NSString*) imagePath:(NSString*) address {
  return [[AbstractApplication imagesDirectory] stringByAppendingPathComponent:[FileUtilities sanitizeFileName:address]];
}


- (UIImage*) imageForAddress:(NSString*) address loadFromDisk:(BOOL) loadFromDisk {
  return [[ImageCache cache] imageForPath:[self imagePath:address] loadFromDisk:loadFromDisk];
}


- (UIImage*) imageForAddress:(NSString*) address {
  return [self imageForAddress:address loadFromDisk:YES];
}


- (void) downloadImage:(NSString*) address {
  if (address.length == 0) {
    return;
  }

  NSString* localPath = [self imagePath:address];

  if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
    return;
  }

  NSData* data = [NetworkUtilities dataWithContentsOfAddress:address pause:NO];
  if (data != nil) {
    [data writeToFile:localPath atomically:YES];
    [MetasyntacticSharedApplication minorRefresh];
  }
}


- (void) downloadImagesBackgroundEntryPoint {
  while (YES) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    {
      NSString* address = nil;
      [downloadImagesCondition lock];
      {
        while (imagesToDownload.count == 0 && priorityImagesToDownload.count == 0) {
          [downloadImagesCondition wait];
        }

        if (priorityImagesToDownload.count > 0) {
          address = priorityImagesToDownload.lastObject;
          [priorityImagesToDownload removeLastObject];
        } else {
          address = imagesToDownload.lastObject;
          [imagesToDownload removeLastObject];
        }
      }
      [downloadImagesCondition unlock];

      [self downloadImage:address];
    }
    [pool release];
  }
}


- (void) addAddressesToDownload:(NSArray*) addresses {
  [downloadImagesCondition lock];
  {
    for (NSInteger i = addresses.count - 1; i >= 0; i--) {
      NSString* address = [addresses objectAtIndex:i];
      if (address.length > 0) {
        [imagesToDownload addObject:[addresses objectAtIndex:i]];
      }
    }
    [downloadImagesCondition broadcast];
  }
  [downloadImagesCondition unlock];
}


- (void) addAddressToDownload:(NSString*) address
                     priority:(BOOL) priority {
  if (address.length == 0) {
    return;
  }

  [downloadImagesCondition lock];
  {
    if (priority) {
      [priorityImagesToDownload addObject:address];
    } else {
      [imagesToDownload addObject:address];
    }
    [downloadImagesCondition broadcast];
  }
  [downloadImagesCondition unlock];
}


- (void) addAddressToDownload:(NSString*) address {
  [self addAddressToDownload:address priority:NO];
}

@end
