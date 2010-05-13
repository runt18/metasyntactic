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

@interface Person : AbstractData<NSCopying, NSCoding> {
@private
  NSString* identifier;
  NSString* name;
  NSString* biography;
  NSString* website;
  NSDictionary* additionalFields;
}

@property (readonly, copy) NSString* identifier;
@property (readonly, copy) NSString* name;
@property (readonly, copy) NSString* biography;
@property (readonly, copy) NSString* website;
@property (readonly, retain) NSDictionary* additionalFields;

+ (Person*) personWithIdentifier:(NSString*) identifier
                            name:(NSString*) name
                       biography:(NSString*) biography
                         website:(NSString*) website
                additionalFields:(NSDictionary*) additionalFields;

@end
