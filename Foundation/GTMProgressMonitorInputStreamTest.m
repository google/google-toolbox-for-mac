//
//  GTMProgressMonitorInputStreamTest.m
//
//  Copyright 2008 Google Inc.
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

#import "GTMSenTestCase.h"
#import "GTMProgressMonitorInputStream.h"
#import "GTMUnitTestDevLog.h"
#import "GTMSystemVersion.h"

@interface GTMProgressMonitorInputStreamTest : GTMTestCase
@end

@interface TestStreamMonitor : NSObject {
 @private
  NSMutableArray *reportedDeliverySizesArray_;
  NSMutableSet *reportedTotalSizesSet_;
}
- (NSArray *)reportedSizes;
- (NSSet *)reportedTotals;
- (void)inputStream:(GTMProgressMonitorInputStream *)stream
  hasDeliveredBytes:(unsigned long long)numRead
       ofTotalBytes:(unsigned long long)total;
@end

@implementation GTMProgressMonitorInputStreamTest

static const unsigned long long kSourceDataByteCount = (10000*10);

- (void)testInit {
  
  // bad inputs
  
  // init
  STAssertNil([[GTMProgressMonitorInputStream alloc] init], nil);
  STAssertNil([[GTMProgressMonitorInputStream alloc] initWithStream:nil length:0], nil);
  STAssertNil([[GTMProgressMonitorInputStream alloc] initWithData:nil], nil);
  STAssertNil([[GTMProgressMonitorInputStream alloc] initWithFileAtPath:nil], nil);

  // class helpers
  STAssertNil([GTMProgressMonitorInputStream inputStreamWithStream:nil length:0], nil);
  STAssertNil([GTMProgressMonitorInputStream inputStreamWithData:nil], nil);
  STAssertNil([GTMProgressMonitorInputStream inputStreamWithFileAtPath:nil], nil);

  // some data for next round
  NSData *data = [@"some data" dataUsingEncoding:NSUTF8StringEncoding];
  STAssertNotNil(data, nil);
  GTMProgressMonitorInputStream *monStream;

  // good inputs
  
  NSInputStream *inputStream = [NSInputStream inputStreamWithData:data];
  STAssertNotNil(inputStream, nil);
  monStream =
    [GTMProgressMonitorInputStream inputStreamWithStream:inputStream
                                                  length:[data length]];
  STAssertNotNil(monStream, nil);

  monStream = [GTMProgressMonitorInputStream inputStreamWithData:data];
  STAssertNotNil(monStream, nil);

  monStream =
    [GTMProgressMonitorInputStream inputStreamWithFileAtPath:@"/etc/services"];
  STAssertNotNil(monStream, nil);
  
}

- (void)testMonitorAccessors {
  
  NSData *data = [@"some data" dataUsingEncoding:NSUTF8StringEncoding];
  STAssertNotNil(data, nil);
  GTMProgressMonitorInputStream *monStream =
    [GTMProgressMonitorInputStream inputStreamWithData:data];
  STAssertNotNil(monStream, nil);
  
  TestStreamMonitor *monitor = [[[TestStreamMonitor alloc] init] autorelease];
  STAssertNotNil(monitor, nil);

  SEL monSel = @selector(inputStream:hasDeliveredBytes:ofTotalBytes:);
  [monStream setMonitorDelegate:monitor selector:monSel];
  STAssertEquals([monStream monitorDelegate], monitor, nil);
  STAssertEquals([monStream monitorSelector], monSel, nil);
  
  [monStream setMonitorSource:data];
  STAssertEquals([monStream monitorSource], data, nil);
}

- (void)testInputStreamAccessors {

  GTMProgressMonitorInputStream *monStream =
    [GTMProgressMonitorInputStream inputStreamWithFileAtPath:@"/etc/services"];
  STAssertNotNil(monStream, nil);
  
  // delegate

  [monStream setDelegate:self];
  STAssertEquals([monStream delegate], self, nil);
  [monStream setDelegate:nil];
  STAssertNil([monStream delegate], nil);
  
  if (![GTMSystemVersion isBuildEqualTo:kGTMSystemBuild10_6_0_WWDC]) {
    // error (we get unknown error before we open things)
    // This was changed on SnowLeopard.
    // rdar://689714 Calling streamError on unopened stream no longer returns 
    // error
    // was filed to check this behaviour.
    NSError *err = [monStream streamError];
    STAssertEqualObjects([err domain], @"NSUnknownErrorDomain", nil);
  }
  
  // status and properties
  
  // pre open
  STAssertEquals([monStream streamStatus],
                 (NSStreamStatus)NSStreamStatusNotOpen, nil);
  [monStream open];
  // post open
  STAssertEquals([monStream streamStatus],
                 (NSStreamStatus)NSStreamStatusOpen, nil);
  STAssertEqualObjects([monStream propertyForKey:NSStreamFileCurrentOffsetKey],
                       [NSNumber numberWithInt:0], nil);
  // read some
  uint8_t buf[8];
  long bytesRead = [monStream read:buf maxLength:sizeof(buf)];
  STAssertGreaterThanOrEqual(bytesRead, (long)sizeof(buf), nil);
  // post read
  STAssertEqualObjects([monStream propertyForKey:NSStreamFileCurrentOffsetKey],
                       [NSNumber numberWithLong:bytesRead], nil);
  [monStream close];
  // post close
  STAssertEquals([monStream streamStatus],
                 (NSStreamStatus)NSStreamStatusClosed, nil);

}

- (void)testProgressMessagesViaRead {
  
  // make a big data buffer (sourceData)
  NSMutableData *sourceData =
    [NSMutableData dataWithCapacity:kSourceDataByteCount];
  for (int idx = 0; idx < 10000; idx++) {
    [sourceData appendBytes:"0123456789" length:10];
  }
  STAssertEquals([sourceData length], (NSUInteger)kSourceDataByteCount, nil);
  
  // make a buffer to hold the data as read from the stream, and an array
  // to hold the size of each read
  NSMutableData *resultData = [NSMutableData data];
  NSMutableArray *deliverySizesArray = [NSMutableArray array];

  TestStreamMonitor *monitor = [[[TestStreamMonitor alloc] init] autorelease];
  STAssertNotNil(monitor, nil);
  
  // create the stream; set self as the monitor
  GTMProgressMonitorInputStream* monStream =
    [GTMProgressMonitorInputStream inputStreamWithData:sourceData];
  [monStream setMonitorDelegate:monitor
                       selector:@selector(inputStream:hasDeliveredBytes:ofTotalBytes:)];
  [monStream open];
  
  // we'll read random-sized chunks of data from our stream, adding the chunk
  // size to deliverySizesArray and the data itself to resultData
  srandomdev();
  
  NSUInteger bytesReadSoFar = 0;
  uint8_t readBuffer[2048];
  while (1) {
    NSStreamStatus status = [monStream streamStatus];
    if (bytesReadSoFar < kSourceDataByteCount) {
      STAssertTrue([monStream hasBytesAvailable], nil);
      STAssertEquals(status, (NSStreamStatus)NSStreamStatusOpen, nil);
    } else {
      STAssertFalse([monStream hasBytesAvailable], nil);
      STAssertEquals(status, (NSStreamStatus)NSStreamStatusAtEnd, nil);
    }
    
    // read a random block size between 1 and 2048 bytes
    NSUInteger bytesToRead = (random() % sizeof(readBuffer)) + 1;
    NSInteger bytesRead = [monStream read:readBuffer maxLength:bytesToRead];

    // done?
    if (bytesRead <= 0) {
      break;
    }
    
    // save the data we just read, and the size of the read
    [resultData appendBytes:readBuffer length:bytesRead];
    bytesReadSoFar += bytesRead;
    NSNumber *bytesReadSoFarNumber =
      [NSNumber numberWithUnsignedLongLong:(unsigned long long)bytesReadSoFar];
    [deliverySizesArray addObject:bytesReadSoFarNumber];
  }
  
  [monStream close];
  
  // compare deliverySizesArray to the array built by our callback, and
  // resultData to the sourceData
  STAssertEqualObjects(deliverySizesArray, [monitor reportedSizes],
                       @"unexpected size deliveries");
  NSNumber *sourceNumber =
    [NSNumber numberWithUnsignedLongLong:kSourceDataByteCount];
  STAssertEqualObjects([NSSet setWithObject:sourceNumber],
                       [monitor reportedTotals],
                       @"unexpected total sizes");
  
  // STAssertEqualObjects on the actual NSDatas is hanging when they are unequal
  // here so I'll just assert True
  STAssertTrue([sourceData isEqualToData:resultData],
               @"unexpected data read");
}

@end

@implementation TestStreamMonitor

- (id)init {
  self = [super init];
  if (self) {
    reportedDeliverySizesArray_ = [[NSMutableArray alloc] init];
    reportedTotalSizesSet_ = [[NSMutableSet alloc] init];
  }
  return self;
}

- (void) dealloc {
  [reportedDeliverySizesArray_ release];
  [reportedTotalSizesSet_ release];
  [super dealloc];
}

- (NSArray *)reportedSizes {
  return reportedDeliverySizesArray_;
}

- (NSSet *)reportedTotals {
  return reportedTotalSizesSet_;
}

- (void)inputStream:(GTMProgressMonitorInputStream *)stream
  hasDeliveredBytes:(unsigned long long)numRead
       ofTotalBytes:(unsigned long long)total {
  // add the number read so far to the array
  [reportedDeliverySizesArray_ addObject:
     [NSNumber numberWithUnsignedLongLong:numRead]];
  [reportedTotalSizesSet_ addObject:
     [NSNumber numberWithUnsignedLongLong:total]];
}

@end
