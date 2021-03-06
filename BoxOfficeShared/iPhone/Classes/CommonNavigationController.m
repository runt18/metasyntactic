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

#import "CommonNavigationController.h"

#import "Application.h"
#import "Model.h"
#import "MovieDetailsViewController.h"
#import "NowPlayingSettingsViewController.h"
#import "PersonDetailsViewController.h"
#import "PostersViewController.h"
#import "ReviewsViewController.h"
#import "ShowtimesViewController.h"
#import "Theater.h"
#import "TheaterDetailsViewController.h"

@implementation CommonNavigationController

- (Movie*) movieForTitle:(NSString*) canonicalTitle {
  for (Movie* movie in [Model model].movies) {
    if ([movie.canonicalTitle isEqual:canonicalTitle]) {
      return movie;
    }
  }

  return nil;
}


- (Theater*) theaterForName:(NSString*) name {
  for (Theater* theater in [Model model].theaters) {
    if ([theater.name isEqual:name]) {
      return theater;
    }
  }

  return nil;
}


- (void) navigateToLastViewedPage {
  NSArray* types = [Model model].navigationStackTypes;
  NSArray* values = [Model model].navigationStackValues;

  [[Model model] clearNavigationStack];
  if (![AbstractApplication shutdownCleanly]) {
    return;
  }

  for (NSInteger i = 0; i < types.count; i++) {
    NSInteger type = [[types objectAtIndex:i] integerValue];
    id value = [values objectAtIndex:i];

    if (type == MovieDetails) {
      Movie* movie = [self movieForTitle:value];
      [self pushMovieDetails:movie animated:NO];
    } else if (type == TheaterDetails) {
      Theater* theater = [self theaterForName:value];
      [self pushTheaterDetails:theater animated:NO];
    } else if (type == Reviews) {
      Movie* movie = [self movieForTitle:value];
      [self pushReviews:movie animated:NO];
    } else if (type == Tickets) {
      Movie* movie = [self movieForTitle:[value objectAtIndex:0]];
      Theater* theater = [self theaterForName:[value objectAtIndex:1]];
      NSString* title = [value objectAtIndex:2];

      [self pushTicketsView:movie theater:theater title:title animated:NO];
    }
  }
}


- (void) pushReviews:(Movie*) movie animated:(BOOL) animated {
  ReviewsViewController* controller = [[[ReviewsViewController alloc] initWithMovie:movie] autorelease];

  [self pushViewController:controller animated:animated];
}


- (void) pushMovieDetails:(Movie*) movie
                 animated:(BOOL) animated {
  if (movie == nil) {
    return;
  }

  UIViewController* viewController = [[[MovieDetailsViewController alloc] initWithMovie:movie] autorelease];
  [self pushViewController:viewController animated:animated];
}


- (void) pushPersonDetails:(Person*) person animated:(BOOL) animated {
  if (person == nil) {
    return;
  }

  UIViewController* viewController = [[[PersonDetailsViewController alloc] initWithPerson:person] autorelease];
  [self pushViewController:viewController animated:animated];
}


- (void) pushTheaterDetails:(Theater*) theater animated:(BOOL) animated {
  if (theater == nil) {
    return;
  }

  UIViewController* viewController = [[[TheaterDetailsViewController alloc] initWithTheater:theater] autorelease];
  [self pushViewController:viewController animated:animated];
}


- (void) pushTicketsView:(Movie*) movie
                 theater:(Theater*) theater
                   title:(NSString*) title
                animated:(BOOL) animated {
  if (movie == nil || theater == nil) {
    return;
  }

  UIViewController* viewController = [[[ShowtimesViewController alloc] initWithTheater:theater
                                                                               movie:movie
                                                                               title:title] autorelease];

  [self pushViewController:viewController animated:animated];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
  [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
  if (interfaceOrientation == UIInterfaceOrientationPortrait) {
    return YES;
  }

  return
    [MetasyntacticSharedApplication shouldAutorotateToInterfaceOrientation:interfaceOrientation] &&
    fullScreenImageListController == nil;
}


- (void) showPostersView:(Movie*) movie posterCount:(NSInteger) posterCount {

  PostersViewController* controller =
  [[[PostersViewController alloc] initWithMovie:movie
                                    posterCount:posterCount] autorelease];

  [super pushFullScreenImageList:controller];
}


- (void) pushInfoControllerAnimated:(BOOL) animated {
  UIViewController* controller = [[[NowPlayingSettingsViewController alloc] init] autorelease];

  UINavigationController* navigationController = [[[AbstractNavigationController alloc] initWithRootViewController:controller] autorelease];
  if (![DeviceUtilities isIPhone3G]) {
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
  }
  [self presentModalViewController:navigationController animated:animated];
}


- (void) onTabBarItemSelected {
  for (id controller in self.viewControllers) {
    if ([controller respondsToSelector:@selector(onTabBarItemSelected)]) {
      [controller onTabBarItemSelected];
    }
  }
}

@end
