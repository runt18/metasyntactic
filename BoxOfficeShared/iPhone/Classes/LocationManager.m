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

#import "LocationManager.h"

#import "BoxOfficeStockImages.h"
#import "Controller.h"
#import "Model.h"
#import "UserLocationCache.h"

@interface LocationManager()
@property (retain) CLLocationManager* locationManager;
@property (retain) NSLock* gate;
@property (retain) UINavigationItem* navigationItem;
@property (retain) UIBarButtonItem* buttonItem;
@property BOOL running;
@property BOOL userInvoked;
@end


@implementation LocationManager

static LocationManager* manager;

+ (void) initialize {
  if (self == [LocationManager class]) {
    manager = [[LocationManager alloc] init];
  }
}

@synthesize locationManager;
@synthesize gate;
@synthesize navigationItem;
@synthesize buttonItem;
@synthesize running;
@synthesize userInvoked;

- (void) dealloc {
  self.locationManager = nil;
  self.gate = nil;
  self.navigationItem = nil;
  self.buttonItem = nil;
  self.running = NO;
  self.userInvoked = NO;

  [super dealloc];
}


- (id) init {
  if ((self = [super init])) {
    self.gate = [[[NSRecursiveLock alloc] init] autorelease];

    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.distanceFilter = kCLDistanceFilterNone;

    self.buttonItem = [[[UIBarButtonItem alloc] initWithImage:BoxOfficeStockImage(@"CurrentPosition.png")
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(onButtonTapped:)] autorelease];

    [self autoUpdateLocation];
  }

  return self;
}


+ (LocationManager*) manager {
  return manager;
}


- (void) updateSpinnerImage:(NSNumber*) number {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  if (running == NO) {
    return;
  }

  NSInteger i = number.integerValue;
  buttonItem.image =
  BoxOfficeStockImage([NSString stringWithFormat:@"Spinner%d.png", i]);

  [self performSelector:@selector(updateSpinnerImage:)
             withObject:[NSNumber numberWithInteger:((i + 1) % 10)]
             afterDelay:0.1];
}


- (void) startUpdatingSpinner:(BOOL) wasUserInvoked {
  self.userInvoked = wasUserInvoked;
  buttonItem.style = UIBarButtonItemStyleDone;
  [self updateSpinnerImage:[NSNumber numberWithInteger:1]];
}


- (void) stopUpdatingSpinner {
  self.userInvoked = NO;
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  buttonItem.style = UIBarButtonItemStylePlain;
  buttonItem.image = BoxOfficeStockImage(@"CurrentPosition.png");
}


- (void) startUpdatingLocation:(BOOL) wasUserInvoked {
  if (running) {
    // the user may have stopped the spinner, and then started it up
    // again while the current request is still running.
    [self startUpdatingSpinner:wasUserInvoked];
    return;
  }
  self.running = YES;
  [self startUpdatingSpinner:wasUserInvoked];

  [locationManager startUpdatingLocation];
}


- (void) autoUpdateLocation {
  if ([Model model].autoUpdateLocation) {
    [self startUpdatingLocation:NO];
  }
}


- (void) enqueueUpdateRequest:(NSTimeInterval) delay {
  [self performSelector:@selector(autoUpdateLocation)
             withObject:nil
             afterDelay:delay];
}


- (void) stopAll {
  self.running = NO;
  [locationManager stopUpdatingLocation];
  [self stopUpdatingSpinner];
}


- (void) locationManager:(CLLocationManager*) manager
        didFailWithError:(NSError*) error {
  BOOL userDenied = error.domain == kCLErrorDomain && error.code == kCLErrorDenied;
  if (userInvoked) {
    if (userDenied) {
      [AlertUtilities showOkAlert:LocalizedString(@"Could not find location.\nUser denied use of the location service.", nil)];
    } else {
      [AlertUtilities showOkAlert:LocalizedString(@"Could not find location.", nil)];
    }
  }

  [self stopAll];

  [self enqueueUpdateRequest:ONE_MINUTE];

  if (userDenied && [Model model].autoUpdateLocation) {
    [[Controller controller] setAutoUpdateLocation:NO];
  }
}


- (void) locationManager:(CLLocationManager*) manager
     didUpdateToLocation:(CLLocation*) newLocation
            fromLocation:(CLLocation*) oldLocation {
  NSLog(@"Location found! Timestamp: %@. Accuracy: %f", newLocation.timestamp, newLocation.horizontalAccuracy);
  if (newLocation != nil) {
    //[[Beacon shared] setBeaconLocation:newLocation];

    if (ABS(newLocation.timestamp.timeIntervalSinceNow) < ONE_MINUTE) {
      [locationManager stopUpdatingLocation];
      [[OperationQueue operationQueue] performSelector:@selector(findLocationBackgroundEntryPoint:)
                                              onTarget:self
                                            withObject:newLocation
                                                  gate:gate
                                              priority:Now];
    }
  }
}


- (void) findLocationBackgroundEntryPoint:(CLLocation*) location {
  Location* userLocation;

  NSString* notification = [LocalizedString(@"Location", nil) lowercaseString];
  [NotificationCenter addNotification:notification];
  {
    userLocation = [LocationUtilities findLocation:location];
  }
  [NotificationCenter removeNotification:notification];

  [self performSelectorOnMainThread:@selector(reportFoundUserLocation:) withObject:userLocation waitUntilDone:NO];
}


- (void) reportFoundUserLocation:(Location*) userLocation {
  NSAssert([NSThread isMainThread], nil);
  [self stopAll];

  if (userLocation == nil) {
    [self enqueueUpdateRequest:ONE_MINUTE];
  } else {
    [self enqueueUpdateRequest:5 * ONE_MINUTE];
  }

  if (userLocation == nil) {
    return;
  }

  NSString* displayString = userLocation.fullDisplayString;
  displayString = [displayString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

  [[UserLocationCache cache] setLocation:userLocation forUserAddress:displayString];
  [[Controller controller] setUserAddress:displayString];
}


- (void) onButtonTapped:(id) sender {
  if (running) {
    // just stop the spinner.  we'll continue doing whatever
    // it was that we were doign.
    [self stopUpdatingSpinner];
  } else {
    // start up the whole shebang.
    [self startUpdatingLocation:YES];
  }
}


- (void) addLocationSpinner:(UINavigationItem*) item {
  self.navigationItem = item;
  navigationItem.rightBarButtonItem = buttonItem;
}

@end
