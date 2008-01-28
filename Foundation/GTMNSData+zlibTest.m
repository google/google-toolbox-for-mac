//
//  GTMNSData+zlibTest.m
//
//  Copyright 2007-2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GTMNSData+zlib.h"
#import <stdlib.h> // for randiom/srandomdev
#import <zlib.h>

#import <SenTestingKit/SenTestingKit.h>

@interface GTMNSData_zlibTest : SenTestCase
@end

  
static void FillWithRandom(char *data, unsigned long len) {
  char *max = data + len;
  for ( ; data < max ; ++data) {
    *data = random() & 0xFF;
  }
}

static BOOL HasGzipHeader(NSData *data) {
  // very simple check
  if ([data length] > 2) {
    const unsigned char *bytes = [data bytes];
    return (bytes[0] == 0x1f) && (bytes[1] == 0x8b);
  }
  return NO;
}


@implementation GTMNSData_zlibTest

- (void)setUp {
  // seed random from /dev/random
  srandomdev();
}

- (void)testInflateDeflate {
  // generate a range of sizes w/ random content
  for (int n = 0 ; n < 2 ; ++n) {
    for (int x = 1 ; x < 128 ; ++x) {
      NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
      STAssertNotNil(localPool, @"failed to alloc local pool");

      NSMutableData *data = [NSMutableData data];
      STAssertNotNil(data, @"failed to alloc data block");

      // first pass small blocks, second pass, larger ones, but second pass
      // avoid making them multimples of 128.
      [data setLength:((n*x*128) + x)];
      FillWithRandom([data mutableBytes], [data length]);

      // w/ *Bytes apis, default level
      NSData *deflated = [NSData gtm_dataByDeflatingBytes:[data bytes] length:[data length]];
      STAssertNotNil(deflated, @"failed to deflate data block");
      STAssertTrue([deflated length] > 0, @"failed to deflate data block");
      STAssertFalse(HasGzipHeader(deflated), @"has gzip header on zlib data");
      NSData *dataPrime = [NSData gtm_dataByInflatingBytes:[deflated bytes] length:[deflated length]];
      STAssertNotNil(dataPrime, @"failed to inflate data block");
      STAssertTrue([dataPrime length] > 0, @"failed to inflate data block");
      STAssertEqualObjects(data, dataPrime, @"failed to round trip via *Bytes apis");

      // w/ *Data apis, default level
      deflated = [NSData gtm_dataByDeflatingData:data];
      STAssertNotNil(deflated, @"failed to deflate data block");
      STAssertTrue([deflated length] > 0, @"failed to deflate data block");
      STAssertFalse(HasGzipHeader(deflated), @"has gzip header on zlib data");
      dataPrime = [NSData gtm_dataByInflatingData:deflated];
      STAssertNotNil(dataPrime, @"failed to inflate data block");
      STAssertTrue([dataPrime length] > 0, @"failed to inflate data block");
      STAssertEqualObjects(data, dataPrime, @"failed to round trip via *Data apis");

      // loop over the compression levels
      for (int level = 1 ; level < 9 ; ++level) {
        // w/ *Bytes apis, using our level
        deflated = [NSData gtm_dataByDeflatingBytes:[data bytes]
                                             length:[data length]
                                   compressionLevel:level];
        STAssertNotNil(deflated, @"failed to deflate data block");
        STAssertTrue([deflated length] > 0, @"failed to deflate data block");
        STAssertFalse(HasGzipHeader(deflated), @"has gzip header on zlib data");
        dataPrime = [NSData gtm_dataByInflatingBytes:[deflated bytes] length:[deflated length]];
        STAssertNotNil(dataPrime, @"failed to inflate data block");
        STAssertTrue([dataPrime length] > 0, @"failed to inflate data block");
        STAssertEqualObjects(data, dataPrime, @"failed to round trip via *Bytes apis");

        // w/ *Data apis, using our level
        deflated = [NSData gtm_dataByDeflatingData:data compressionLevel:level];
        STAssertNotNil(deflated, @"failed to deflate data block");
        STAssertTrue([deflated length] > 0, @"failed to deflate data block");
        STAssertFalse(HasGzipHeader(deflated), @"has gzip header on zlib data");
        dataPrime = [NSData gtm_dataByInflatingData:deflated];
        STAssertNotNil(dataPrime, @"failed to inflate data block");
        STAssertTrue([dataPrime length] > 0, @"failed to inflate data block");
        STAssertEqualObjects(data, dataPrime, @"failed to round trip via *Data apis");
      }

      [localPool release];
    }
  }
}

- (void)testInflateGzip {
  // generate a range of sizes w/ random content
  for (int n = 0 ; n < 2 ; ++n) {
    for (int x = 1 ; x < 128 ; ++x) {
      NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
      STAssertNotNil(localPool, @"failed to alloc local pool");

      NSMutableData *data = [NSMutableData data];
      STAssertNotNil(data, @"failed to alloc data block");

      // first pass small blocks, second pass, larger ones, but second pass
      // avoid making them multimples of 128.
      [data setLength:((n*x*128) + x)];
      FillWithRandom([data mutableBytes], [data length]);

      // w/ *Bytes apis, default level
      NSData *gzipped = [NSData gtm_dataByGzippingBytes:[data bytes] length:[data length]];
      STAssertNotNil(gzipped, @"failed to gzip data block");
      STAssertTrue([gzipped length] > 0, @"failed to gzip data block");
      STAssertTrue(HasGzipHeader(gzipped), @"doesn't have gzip header on gzipped data");
      NSData *dataPrime = [NSData gtm_dataByInflatingBytes:[gzipped bytes] length:[gzipped length]];
      STAssertNotNil(dataPrime, @"failed to inflate data block");
      STAssertTrue([dataPrime length] > 0, @"failed to inflate data block");
      STAssertEqualObjects(data, dataPrime, @"failed to round trip via *Bytes apis");

      // w/ *Data apis, default level
      gzipped = [NSData gtm_dataByGzippingData:data];
      STAssertNotNil(gzipped, @"failed to gzip data block");
      STAssertTrue([gzipped length] > 0, @"failed to gzip data block");
      STAssertTrue(HasGzipHeader(gzipped), @"doesn't have gzip header on gzipped data");
      dataPrime = [NSData gtm_dataByInflatingData:gzipped];
      STAssertNotNil(dataPrime, @"failed to inflate data block");
      STAssertTrue([dataPrime length] > 0, @"failed to inflate data block");
      STAssertEqualObjects(data, dataPrime, @"failed to round trip via *Data apis");

      // loop over the compression levels
      for (int level = 1 ; level < 9 ; ++level) {
        // w/ *Bytes apis, using our level
        gzipped = [NSData gtm_dataByGzippingBytes:[data bytes]
                                           length:[data length]
                                 compressionLevel:level];
        STAssertNotNil(gzipped, @"failed to gzip data block");
        STAssertTrue([gzipped length] > 0, @"failed to gzip data block");
        STAssertTrue(HasGzipHeader(gzipped), @"doesn't have gzip header on gzipped data");
        dataPrime = [NSData gtm_dataByInflatingBytes:[gzipped bytes] length:[gzipped length]];
        STAssertNotNil(dataPrime, @"failed to inflate data block");
        STAssertTrue([dataPrime length] > 0, @"failed to inflate data block");
        STAssertEqualObjects(data, dataPrime, @"failed to round trip via *Bytes apis");

        // w/ *Data apis, using our level
        gzipped = [NSData gtm_dataByGzippingData:data compressionLevel:level];
        STAssertNotNil(gzipped, @"failed to gzip data block");
        STAssertTrue([gzipped length] > 0, @"failed to gzip data block");
        STAssertTrue(HasGzipHeader(gzipped), @"doesn't have gzip header on gzipped data");
        dataPrime = [NSData gtm_dataByInflatingData:gzipped];
        STAssertNotNil(dataPrime, @"failed to inflate data block");
        STAssertTrue([dataPrime length] > 0, @"failed to inflate data block");
        STAssertEqualObjects(data, dataPrime, @"failed to round trip via *Data apis");
      }

      [localPool release];
    }
  }
}

@end
