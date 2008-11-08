// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "BlurayCache.h"

#import "Application.h"
#import "DVD.h"
#import "DateUtilities.h"
#import "FileUtilities.h"
#import "LargePosterCache.h"
#import "LinkedSet.h"
#import "Movie.h"
#import "NetworkUtilities.h"
#import "NowPlayingAppDelegate.h"
#import "NowPlayingModel.h"
#import "PointerSet.h"
#import "ThreadingUtilities.h"
#import "Utilities.h"
#import "XmlElement.h"

@implementation BlurayCache

- (void) dealloc {
    [super dealloc];
}


- (id) initWithModel:(NowPlayingModel*) model_ {
    if (self = [super initWithModel:model_]) {
    }

    return self;
}


+ (BlurayCache*) cacheWithModel:(NowPlayingModel*) model {
    return [[[BlurayCache alloc] initWithModel:model] autorelease];
}


- (NSString*) serverAddress {
    return [NSString stringWithFormat:@"http://%@.appspot.com/LookupDVDListings?q=bluray", [Application host]];
}


- (NSString*) directory {
    return [Application blurayDirectory];
}

@end