//
//  GTMNSData+zlib.m
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
#import <zlib.h>

#define kChunkSize 1024

@interface NSData (GTMZlibAdditionsPrivate)
+ (NSData *)gtm_dataByCompressingBytes:(const void *)bytes
                                length:(unsigned)length
                      compressionLevel:(int)level
                               useGzip:(BOOL)useGzip;
@end

@implementation NSData (GTMZlibAdditionsPrivate)
+ (NSData *)gtm_dataByCompressingBytes:(const void *)bytes
                                length:(unsigned)length
                      compressionLevel:(int)level
                               useGzip:(BOOL)useGzip {
  if (!bytes || !length) return nil;

  if (level < Z_BEST_SPEED)
    level = Z_BEST_SPEED;
  else if (level > Z_BEST_COMPRESSION)
    level = Z_BEST_COMPRESSION;

  z_stream strm;
  bzero(&strm, sizeof(z_stream));

  int windowBits = 15; // the default
  int memLevel = 8; // the default
  if (useGzip)
    windowBits += 16; // enable gzip header instead of zlib header
  int retCode;
  if ((retCode = deflateInit2(&strm, level, Z_DEFLATED, windowBits,
                              memLevel, Z_DEFAULT_STRATEGY)) != Z_OK) {
#ifdef DEBUG
    NSLog(@"Failed to init for deflate w/ level %d, error %d",
          level, retCode);
#endif
    return nil;
  }

  // hint the size at 1/4 the input size
  NSMutableData *result = [NSMutableData dataWithCapacity:(length/4)];
  unsigned char output[kChunkSize];

  // setup the input
  strm.avail_in = length;
  strm.next_in = (unsigned char*)bytes;

  // loop to collect the data
  do {
    // update what we're passing in
    strm.avail_out = kChunkSize;
    strm.next_out = output;
    retCode = deflate(&strm, Z_FINISH);
    if ((retCode != Z_OK) && (retCode != Z_STREAM_END)) {
#ifdef DEBUG
      NSLog(@"Error trying to deflate some of the payload, error %d",
            retCode);
#endif
      deflateEnd(&strm);
      return nil;
    }
    // collect what we got
    unsigned gotBack = kChunkSize - strm.avail_out;
    if (gotBack > 0) {
      [result appendBytes:output length:gotBack];
    }

  } while (retCode == Z_OK);

#ifdef DEBUG
  if (strm.avail_in != 0) {
    NSLog(@"thought we finished deflate w/o using all input, %u bytes left",
          strm.avail_in);
  }
  if (retCode != Z_STREAM_END) {
    NSLog(@"thought we finished deflate w/o getting a result of stream end, code %d",
          retCode);
  }
#endif

  // clean up
  deflateEnd(&strm);

  return result;
} // gtm_dataByCompressingBytes:length:compressionLevel:useGzip:
  

@end


@implementation NSData (GTMZLibAdditions)

+ (NSData *)gtm_dataByGzippingBytes:(const void *)bytes
                             length:(unsigned)length {
  return [self gtm_dataByCompressingBytes:bytes
                                   length:length
                         compressionLevel:Z_DEFAULT_COMPRESSION
                                  useGzip:YES];
} // gtm_dataByGzippingBytes:length:

+ (NSData *)gtm_dataByGzippingData:(NSData *)data {
  return [self gtm_dataByCompressingBytes:[data bytes]
                                   length:[data length]
                         compressionLevel:Z_DEFAULT_COMPRESSION
                                  useGzip:YES];
} // gtm_dataByGzippingData:

+ (NSData *)gtm_dataByGzippingBytes:(const void *)bytes
                             length:(unsigned)length
                   compressionLevel:(int)level {
  return [self gtm_dataByCompressingBytes:bytes
                                   length:length
                         compressionLevel:level
                                  useGzip:YES];
} // gtm_dataByGzippingBytes:length:level:

+ (NSData *)gtm_dataByGzippingData:(NSData *)data
                  compressionLevel:(int)level {
  return [self gtm_dataByCompressingBytes:[data bytes]
                                   length:[data length]
                         compressionLevel:level
                                  useGzip:YES];
} // gtm_dataByGzippingData:level:

+ (NSData *)gtm_dataByDeflatingBytes:(const void *)bytes
                              length:(unsigned)length {
  return [self gtm_dataByCompressingBytes:bytes
                                   length:length
                         compressionLevel:Z_DEFAULT_COMPRESSION
                                  useGzip:NO];
} // gtm_dataByDeflatingBytes:length:

+ (NSData *)gtm_dataByDeflatingData:(NSData *)data {
  return [self gtm_dataByCompressingBytes:[data bytes]
                                   length:[data length]
                         compressionLevel:Z_DEFAULT_COMPRESSION
                                  useGzip:NO];
} // gtm_dataByDeflatingData:

+ (NSData *)gtm_dataByDeflatingBytes:(const void *)bytes
                              length:(unsigned)length
                    compressionLevel:(int)level {
  return [self gtm_dataByCompressingBytes:bytes
                                   length:length
                         compressionLevel:level
                                  useGzip:NO];
} // gtm_dataByDeflatingBytes:length:level:

+ (NSData *)gtm_dataByDeflatingData:(NSData *)data
                   compressionLevel:(int)level {
  return [self gtm_dataByCompressingBytes:[data bytes]
                                   length:[data length]
                         compressionLevel:level
                                  useGzip:NO];
} // gtm_dataByDeflatingData:level:

+ (NSData *)gtm_dataByInflatingBytes:(const void *)bytes
                              length:(unsigned)length {
  if (!bytes || !length) return nil;

  z_stream strm;
  bzero(&strm, sizeof(z_stream));

  // setup the input
  strm.avail_in = length;
  strm.next_in = (unsigned char*)bytes;

  int windowBits = 15; // 15 to enable any window size
  windowBits += 32; // and +32 to enable zlib or gzip header detection.
  int retCode;
  if ((retCode = inflateInit2(&strm, windowBits)) != Z_OK) {
#ifdef DEBUG
    NSLog(@"Failed to init for inflate, error %d", retCode);
#endif
    return nil;
  }

  // hint the size at 4x the input size
  NSMutableData *result = [NSMutableData dataWithCapacity:(length*4)];
  unsigned char output[kChunkSize];

  // loop to collect the data
  do {
    // update what we're passing in
    strm.avail_out = kChunkSize;
    strm.next_out = output;
    retCode = inflate(&strm, Z_NO_FLUSH);
    if ((retCode != Z_OK) && (retCode != Z_STREAM_END)) {
#ifdef DEBUG
      NSLog(@"Error trying to inflate some of the payload, error %d",
            retCode);
#endif
      inflateEnd(&strm);
      return nil;
    }
    // collect what we got
    unsigned gotBack = kChunkSize - strm.avail_out;
    if (gotBack > 0) {
      [result appendBytes:output length:gotBack];
    }

  } while (retCode == Z_OK);

#ifdef DEBUG
  if (strm.avail_in != 0) {
    NSLog(@"thought we finished inflate w/o using all input, %u bytes left",
          strm.avail_in);
  }
  if (retCode != Z_STREAM_END) {
    NSLog(@"thought we finished inflate w/o getting a result of stream end, code %d",
          retCode);
  }
#endif

  // clean up
  inflateEnd(&strm);

  return result;
} // gtm_dataByInflatingBytes:length:

+ (NSData *)gtm_dataByInflatingData:(NSData *)data {
  return [self gtm_dataByInflatingBytes:[data bytes]
                                 length:[data length]];
} // gtm_dataByInflatingData:

@end
