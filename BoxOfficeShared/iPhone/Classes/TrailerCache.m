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

#import "TrailerCache.h"

#import "Application.h"
#import "Model.h"

@interface TrailerCache()
@property (retain) PersistentDictionaryThreadsafeValue*/*NSDictionary*/ indexData;
@property (retain) ThreadsafeValue*/*NSArray*/ indexKeysData;
@property BOOL updated;
@end


@implementation TrailerCache

static TrailerCache* cache;

+ (void) initialize {
  if (self == [TrailerCache class]) {
    cache = [[TrailerCache alloc] init];
  }
}


+ (TrailerCache*) cache {
  return cache;
}

@synthesize indexData;
@synthesize indexKeysData;
@synthesize updated;

- (void) dealloc {
  self.indexData = nil;
  self.indexKeysData = nil;
  self.updated = NO;

  [super dealloc];
}


- (NSString*) indexFile {
  return [[Application trailersDirectory] stringByAppendingPathComponent:@"Index.plist"];
}


- (id) init {
  if ((self = [super init])) {
    self.indexData = [PersistentDictionaryThreadsafeValue valueWithGate:dataGate file:self.indexFile];
    self.indexKeysData = [ThreadsafeValue valueWithGate:dataGate delegate:self loadSelector:@selector(loadIndexKeys)];
  }

  return self;
}


- (NSDictionary*) index {
  return indexData.value;
}


- (NSArray*) indexKeys {
  return indexKeysData.value;
}


- (NSArray*) loadIndexKeys {
  NSArray* result = self.index.allKeys;
  if (result.count == 0) {
    return [NSArray array];
  }

  return result;
}


- (NSString*) trailerFile:(Movie*) movie {
  NSString* name = [[FileUtilities sanitizeFileName:movie.canonicalTitle] stringByAppendingPathExtension:@"plist"];
  return [[Application trailersMoviesDirectory] stringByAppendingPathComponent:name];
}


+ (void) processIndex:(XmlElement*) element
             trailers:(NSMutableArray*) trailers {
  for (XmlElement* child in element.children) {
    [self processIndex:child trailers:trailers];
  }

  NSString* text = element.text;
  if ([text hasPrefix:@"http"] && [text hasSuffix:@".m4v"]) {
    [trailers addObject:text];
  }
}


+ (NSArray*) processIndex:(XmlElement*) element {
  NSMutableArray* trailers = [NSMutableArray array];
  [self processIndex:element trailers:trailers];
  return trailers;
}


+ (NSString*) xmlAddressForStudioKey:(NSString*) studioKey titleKey:(NSString*) titleKey {
  NSString* appleUrl =
  [NSString stringWithFormat:@"http://trailers.apple.com/moviesxml/s/%@/%@/index.xml",
   studioKey, titleKey];
  NSString* url = [NSString stringWithFormat:@"http://%@.appspot.com/LookupCachedResource%@?q=%@",
                   [Application apiHost], [Application apiVersion],
                   [StringUtilities stringByAddingPercentEscapes:appleUrl]];
  return url;
}


+ (NSString*) downloadXmlStringForStudioKey:(NSString*) studioKey titleKey:(NSString*) titleKey {
  NSString* url = [self xmlAddressForStudioKey:studioKey titleKey:titleKey];
  return [NetworkUtilities stringWithContentsOfAddress:url pause:NO];
}


+ (XmlElement*) downloadXmlElementForStudioKey:(NSString*) studioKey titleKey:(NSString*) titleKey {
  NSString* url = [self xmlAddressForStudioKey:studioKey titleKey:titleKey];
  return [NetworkUtilities xmlWithContentsOfAddress:url pause:NO];
}


+ (NSArray*) downloadTrailersForStudioKey:(NSString*) studioKey titleKey:(NSString*) titleKey {
  XmlElement* element = [self downloadXmlElementForStudioKey:studioKey titleKey:titleKey];

  if (element == nil) {
    // didn't get any data.  ignore this for now.
    return nil;
  }

  return [self processIndex:element];
}


- (void) updateMovieDetails:(Movie*) movie force:(BOOL) force {
  NSString* file = [self trailerFile:movie];

  NSDate* downloadDate = [FileUtilities modificationDate:file];
  if (downloadDate != nil) {
    if (ABS(downloadDate.timeIntervalSinceNow) < THREE_DAYS) {
      NSArray* values = [FileUtilities readObject:file];
      if (values.count > 0) {
        return;
      }

      if (!force) {
        return;
      }
    }
  }

  DifferenceEngine* engine = [DifferenceEngine engine];
  NSInteger arrayIndex = [engine findClosestMatchIndex:movie.canonicalTitle.lowercaseString
                                               inArray:self.indexKeys];
  if (arrayIndex == NSNotFound) {
    // no trailer for this movie.  we'll try again later
    return;
  }

  NSArray* studioAndTitleKey = [self.index objectForKey:[self.indexKeys objectAtIndex:arrayIndex]];

  NSString* studioKey = [studioAndTitleKey objectAtIndex:0];
  NSString* titleKey = [studioAndTitleKey objectAtIndex:1];

  NSArray* trailers = [TrailerCache downloadTrailersForStudioKey:studioKey titleKey:titleKey];

  if (trailers == nil) {
    // didn't get any data.  ignore this for now.
    return;
  }

  [FileUtilities writeObject:trailers toFile:[self trailerFile:movie]];

  if (trailers.count > 0) {
    [MetasyntacticSharedApplication minorRefresh];
  }
}


+ (void) processIndexItem:(id) itemElement result:(NSMutableDictionary*) result {
  if (![itemElement isKindOfClass:[NSDictionary class]]) {
    return;
  }

  NSDictionary* child = itemElement;
  id fullTitle = [child objectForKey:@"title"];
  id location = [child objectForKey:@"location"];

  if (![fullTitle isKindOfClass:[NSString class]] ||
      ![location isKindOfClass:[NSString class]]) {
    return;
  }

  NSArray* components = [location componentsSeparatedByString:@"/"];

  if (components.count < 4) {
    return;
  }

  id studioKey = [components objectAtIndex:2];
  id titleKey = [components objectAtIndex:3];

  if (![studioKey isKindOfClass:[NSString class]] ||
      ![titleKey isKindOfClass:[NSString class]]) {
    return;
  }

  if ([fullTitle length] == 0 || [studioKey length] == 0 || [titleKey length] == 0) {
    return;
  }

  [result setObject:[NSArray arrayWithObjects:studioKey, titleKey, nil]
             forKey:[fullTitle lowercaseString]];
}


+ (NSDictionary*) processJSONIndex:(id) jsonElement {
  NSMutableDictionary* result = [NSMutableDictionary dictionary];
  if ([jsonElement isKindOfClass:[NSArray class]]) {
    for (id itemElement in jsonElement) {
      NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
      {
        [self processIndexItem:itemElement result:result];
      }
      [pool release];
    }
  }
  return result;
}


+ (NSString*) downloadIndexString {
  NSString* appleUrl = @"http://trailers.apple.com/trailers/home/feeds/studios.json";
  NSString* url = [NSString stringWithFormat:@"http://%@.appspot.com/LookupCachedResource%@?q=%@",
                   [Application apiHost], [Application apiVersion],
                   [StringUtilities stringByAddingPercentEscapes:appleUrl]];
  NSString* contents = [NetworkUtilities stringWithContentsOfAddress:url pause:NO];
  return contents;
}


+ (id) downloadJSONIndex {
  NSString* indexString = [self downloadIndexString];
  id jsonValue = [indexString JSONValue];
  return jsonValue;
}


- (NSArray*) trailersForMovie:(Movie*) movie {
  NSArray* trailers = [FileUtilities readObject:[self trailerFile:movie]];
  if (trailers == nil) {
    return [NSArray array];
  }
  return trailers;
}


- (BOOL) tooSoon {
  NSDate* lastLookupDate = [FileUtilities modificationDate:self.indexFile];
  return lastLookupDate != nil &&
  (ABS(lastLookupDate.timeIntervalSinceNow) < THREE_DAYS);
}


- (void) updateIndexBackgroundEntryPoint {
  if ([self tooSoon]) {
    return;
  }

  id jsonIndex = [TrailerCache downloadJSONIndex];
  NSDictionary* dictionary = [TrailerCache processJSONIndex:jsonIndex];

  if (dictionary.count > 0) {
    indexData.value = dictionary;
    indexKeysData.value = dictionary.allKeys;
    [self clearUpdatedMovies];
    [MetasyntacticSharedApplication minorRefresh];
  }
}


- (void) update {
  if (![[Model model] trailerCacheEnabled]) {
    return;
  }

  if (updated) {
    return;
  }
  self.updated = YES;

  [[OperationQueue operationQueue] performSelector:@selector(updateIndexBackgroundEntryPoint)
                                          onTarget:self
                                              gate:nil
                                          priority:Priority];
}

@end
