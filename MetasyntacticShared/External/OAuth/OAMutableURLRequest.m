//
//  OAMutableURLRequest.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "OAMutableURLRequest.h"

#import "NSMutableURLRequest+Parameters.h"
#import "NSString+URLEncoding.h"
#import "NSString+UUID.h"
#import "NSURL+Base.h"
#import "OAConsumer.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "OARequestParameter.h"
#import "OASignatureProviding.h"
#import "OAToken.h"

@interface OAMutableURLRequest()
@property (retain) OAConsumer* consumer;
@property (retain) OAToken* token;
@property (copy) NSString* realm;
@property (copy) NSString* signature;
@property (copy) NSString* nonce;
@property (copy) NSString* timestamp;
@end

@implementation OAMutableURLRequest

@synthesize consumer;
@synthesize token;
@synthesize realm;
@synthesize signature;
@synthesize nonce;
@synthesize timestamp;

- (void) dealloc {
  self.consumer = nil;
  self.token = nil;
  self.realm = nil;
  self.signature = nil;
  self.nonce = nil;
  self.timestamp = nil;
  
  [super dealloc];
}


- (id) initWithURL:(NSURL*) url_
          consumer:(OAConsumer*) consumer_
             token:(OAToken*) token_
             realm:(NSString*) realm_
         timestamp:(NSString*) timestamp_ {
  if ([super initWithURL:url_
             cachePolicy:NSURLRequestReloadIgnoringCacheData
         timeoutInterval:30.0]) {
    
    self.consumer = consumer_;
    self.token = token_;
    self.realm = realm_.length == 0 ? @"" : realm_;
    self.timestamp = timestamp_;    
    self.nonce = [NSString stringWithNewUUID];
    
    [self setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [self setValue:@"gzip" forHTTPHeaderField:@"User-Agent"];
  }
  
  return self;
}


+ (OAMutableURLRequest*) requestWithURL:(NSURL*) url
                               consumer:(OAConsumer*) consumer
                                  token:(OAToken*) token
                                  realm:(NSString*) realm 
                              timestamp:(NSString*) timestamp {
  return [[[OAMutableURLRequest alloc] initWithURL:url
                                          consumer:consumer 
                                             token:token
                                             realm:realm
                                         timestamp:timestamp] autorelease];
}


- (NSString*) signatureBaseString {
  // OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
  // build a sorted array of both request parameters and OAuth header parameters
  NSMutableArray* parameterPairs = [NSMutableArray array];
  
  [parameterPairs addObject:[[OARequestParameter parameterWithName:@"oauth_consumer_key" value:consumer.key] URLEncodedNameValuePair]];
  [parameterPairs addObject:[[OARequestParameter parameterWithName:@"oauth_signature_method" value:@"HMAC-SHA1"] URLEncodedNameValuePair]];
  [parameterPairs addObject:[[OARequestParameter parameterWithName:@"oauth_timestamp" value:timestamp] URLEncodedNameValuePair]];
  [parameterPairs addObject:[[OARequestParameter parameterWithName:@"oauth_nonce" value:nonce] URLEncodedNameValuePair]];
  [parameterPairs addObject:[[OARequestParameter parameterWithName:@"oauth_version" value:@"1.0"] URLEncodedNameValuePair]];
  
  if (token.key.length > 0) {
    [parameterPairs addObject:[[OARequestParameter parameterWithName:@"oauth_token" value:token.key] URLEncodedNameValuePair]];
  }
  
  for (OARequestParameter* param in [NSMutableURLRequestAdditions parametersForRequest:self]) {
    [parameterPairs addObject:param.URLEncodedNameValuePair];
  }
  
  NSArray* sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
  NSString* normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
  
  // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
  return [NSString stringWithFormat:@"%@&%@&%@",
          self.HTTPMethod,
          self.URL.URLStringWithoutQuery.encodedURLParameterString,
          normalizedRequestParameters.encodedURLString];
}


- (void) prepare {
  // sign
  NSString* baseString = [self signatureBaseString];
  NSString* tokenSecret = token.secret.length == 0 ? @"" : token.secret;
  self.signature =
  [OAHMAC_SHA1SignatureProvider signClearText:baseString
                                   withSecret:[NSString stringWithFormat:@"%@&%@", consumer.secret, tokenSecret]];
  
  // set OAuth headers
  NSString* oauthToken = @"";
  if (token.key.length > 0) {
    oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", ", token.key.encodedURLParameterString];
  }
  
  NSString* oauthHeader = [NSString stringWithFormat:@"OAuth realm=\"%@\", oauth_consumer_key=\"%@\", %@oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", oauth_version=\"1.0\"",
                           realm.encodedURLParameterString,
                           consumer.key.encodedURLParameterString,
                           oauthToken,
                           [@"HMAC-SHA1" encodedURLParameterString],
                           signature.encodedURLParameterString,
                           timestamp,
                           nonce];
  
  [self setValue:oauthHeader forHTTPHeaderField:@"Authorization"];
}

@end
