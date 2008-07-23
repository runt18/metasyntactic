//
//  Theater.h
//  BoxOfficeApplication
//
//  Created by Cyrus Najmabadi on 4/27/08.
//  Copyright 2008 Metasyntactic. All rights reserved.
//

#import "Movie.h"

@interface Theater : NSObject {
    NSString* identifier;
    NSString* name;
    NSString* address;
    NSString* phoneNumber;
    
    NSString* sellsTickets;
    
@private
    // title -> [ { showtime, showid } ]
    NSDictionary* movieToShowtimesMap;
}

@property (copy) NSString* identifier;
@property (copy) NSString* name;
@property (copy) NSString* address;
@property (copy) NSString* phoneNumber;
@property (copy) NSString* sellsTickets;
@property (retain) NSDictionary* movieToShowtimesMap;

+ (Theater*) theaterWithIdentifier:(NSString*) identifier
                              name:(NSString*) name
                           address:(NSString*) address
                       phoneNumber:(NSString*) phoneNumber
                      sellsTickets:(NSString*) sellsTickets
               movieToShowtimesMap:(NSDictionary*) movieToShowtimesMap;

+ (Theater*) theaterWithDictionary:(NSDictionary*) dictionary;

- (NSDictionary*) dictionary;

+ (NSString*) processShowtime:(NSString*) showtime;

- (NSArray*) movieTitles;
- (NSArray*) performances:(Movie*) movie;

@end
