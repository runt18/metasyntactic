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

#import "Utilities.h"

#import "Model.h"

@implementation Utilities


+ (id) findSmallestElementInArray:(NSArray*) array
                    usingFunction:(NSInteger(*)(id, id, void*)) comparator
                          context:(void*) context {
    if (array.count == 0) {
        return nil;
    }

    id value = [array objectAtIndex:0];

    for (NSInteger i = 1; i < array.count; i++) {
        id current = [array objectAtIndex:i];

        NSComparisonResult result = comparator(value, current, context);
        if (result == NSOrderedDescending) {
            value = current;
        }
    }

    return value;
}


+ (id) findSmallestElementInArray:(NSArray*) array
                    usingFunction:(NSInteger(*)(id, id, void*, void*)) comparator
                         context1:(void*) context1
                         context2:(void*) context2 {
    if (array.count == 0) {
        return nil;
    }

    id value = [array objectAtIndex:0];

    for (NSInteger i = 1; i < array.count; i++) {
        id current = [array objectAtIndex:i];

        NSComparisonResult result = comparator(value, current, context1, context2);
        if (result == NSOrderedDescending) {
            value = current;
        }
    }

    return value;
}


+ (id) removeRandomElement:(NSMutableArray*) array {
    NSInteger index = rand() % array.count;
    id value = [array objectAtIndex:index];
    [array removeObjectAtIndex:index];

    return value;
}


+ (NSInteger) hashString:(NSString*) string {
    if (string.length == 0) {
        return 0;
    }

    int result = [string characterAtIndex:0];
    for (int i = 1; i < string.length; i++) {
        result = 31 * result + [string characterAtIndex:i];
    }

    return result;
}


+ (NSDictionary*) nonNilDictionary:(NSDictionary*) dictionary {
    if (dictionary == nil) {
        return [NSDictionary dictionary];
    }

    return dictionary;
}


+ (NSArray*) nonNilArray:(NSArray*) array {
    if (array == nil) {
        return [NSArray array];
    }

    return array;
}


+ (NSString*) nonNilString:(NSString*) string {
    if (string == nil) {
        return @"";
    }

    return string;
}


+ (NSString*)                      string:(NSString*) string
      byAddingPercentEscapesUsingEncoding:(NSStringEncoding) encoding {
    string = [string stringByAddingPercentEscapesUsingEncoding:encoding];
    string = [string stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];

    return string;
}


+ (NSString*) stringByAddingPercentEscapes:(NSString*) string {
    return [self string:string byAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


+ (NSString*) stripHtmlCodes:(NSString*) string {
    if (string == nil) {
        return @"";
    }

    NSArray* htmlCodes = [NSArray arrayWithObjects:@"a", @"em", @"p", @"b", @"i", @"br", nil];

    for (NSString* code in htmlCodes) {
        string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%@>", code] withString:@""];
        string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"</%@>", code] withString:@""];
    }

    return string;
}


+ (NSString*) asciiString:(NSString*) string {
    NSString* asciiString = [[[NSString alloc] initWithData:[string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                                                   encoding:NSASCIIStringEncoding] autorelease];
    return asciiString;
}


+ (NSString*) stringFromUnichar:(unichar) c {
    return [NSString stringWithCharacters:&c length:1];
}

@end