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

#import "AbstractNetflixFilterableViewController.h"

#import "CommonNavigationController.h"
#import "Model.h"
#import "NetflixCell.h"

@interface AbstractNetflixFilterableViewController()
@property (retain) NSArray* movies;
@property (retain) NSArray* filteredMovies;
@end


@implementation AbstractNetflixFilterableViewController

@synthesize movies;
@synthesize filteredMovies;

- (void) dealloc {
  self.movies = nil;
  self.filteredMovies = nil;

  [super dealloc];
}


- (UIView*) createHeaderView {
  NSArray* items = [NSArray arrayWithObjects:
                    LocalizedString(@"All", nil),
                    LocalizedString(@"DVD", nil),
                    LocalizedString(@"Blu-ray", nil),
                    LocalizedString(@"Instant", nil), nil];
  UISegmentedControl* segmentedControl = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
  segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
  segmentedControl.tintColor = [StyleSheet segmentedControlTintColor];
  segmentedControl.selectedSegmentIndex = [Model model].netflixFilterSelectedSegmentIndex;

  [segmentedControl addTarget:self
                       action:@selector(onFilterChanged:)
             forControlEvents:UIControlEventValueChanged];

  UINavigationBar* navBar = [[[UINavigationBar alloc] init] autorelease];
  navBar.tintColor = [StyleSheet navigationBarTintColor];

  UINavigationItem* item = [[[UINavigationItem alloc] init] autorelease];
  item.titleView = segmentedControl;
  [navBar setItems:[NSArray arrayWithObject:item]];

  [navBar sizeToFit];

  CGRect frame = segmentedControl.frame;
  frame.size.width = 310;
  segmentedControl.frame = frame;

  return navBar;
}


- (void) onFilterChanged:(UISegmentedControl*) control {
  [[Model model] setNetflixFilterSelectedSegmentIndex:control.selectedSegmentIndex];
  [self majorRefresh];
}


- (BOOL) filter:(NSInteger) filter movie:(Movie*) movie {
  if (filter == 0) {
    return YES;
  }

  if (filter == 1) {
    return [[NetflixCache cache] isDvd:movie];
  }

  if (filter == 2) {
    return [[NetflixCache cache] isBluray:movie];
  }

  if (filter == 3) {
    return [[NetflixCache cache] isInstantWatch:movie];
  }

  return NO;
}


- (NSArray*) determineMovies AbstractMethod;


- (void) onBeforeReloadTableViewData {
  [super onBeforeReloadTableViewData];

  self.tableView.tableHeaderView = [self createHeaderView];

  self.tableView.rowHeight = 100;

  NSArray* array = [self determineMovies];
  NSMutableArray* filteredArray = [NSMutableArray array];

  NSInteger filter = [Model model].netflixFilterSelectedSegmentIndex;
  for (Movie* movie in array) {
    if ([self filter:filter movie:movie]) {
      [filteredArray addObject:movie];
    }
  }

  self.movies = array;
  self.filteredMovies = filteredArray;
}


- (void) didReceiveMemoryWarningWorker {
  [super didReceiveMemoryWarningWorker];
  self.movies = [NSArray array];
  self.filteredMovies = [NSArray array];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
  return 1;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
  return filteredMovies.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell*) tableView:(UITableView*) tableView_
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
  static NSString* reuseIdentifier = @"reuseIdentifier";
  NetflixCell* cell = (id)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[[NetflixCell alloc] initWithReuseIdentifier:reuseIdentifier
                                     tableViewController:self] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  Movie* movie = [filteredMovies objectAtIndex:indexPath.row];
  [cell setMovie:movie owner:self];

  return cell;
}


- (CommonNavigationController*) commonNavigationController {
  return (id) self.navigationController;
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
  Movie* movie = [filteredMovies objectAtIndex:indexPath.row];
  [self.commonNavigationController pushMovieDetails:movie animated:YES];
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
  if (filteredMovies.count == 0) {
    if (movies.count == 0) {
      return [NetflixCache noInformationFound];
    } else {
      return LocalizedString(@"No information found", nil);
    }
  }

  return nil;
}

@end
