//
//  GTMLoggerRingBufferWriter.m
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

#import "GTMLoggerRingBufferWriter.h"

// Define a trivial assertion macro to avoid dependencies
#ifdef DEBUG
#define GTMLOGGER_ASSERT(expr) assert(expr)
#else
#define GTMLOGGER_ASSERT(expr)
#endif

// Holds a message and a level.
struct GTMRingBufferPair {
  NSString *logMessage_;
  GTMLoggerLevel level_;
};


// There are two operations that involve iterating over the buffer
// contents and doing Something to them.  This is a callback function
// that is called for every pair living in the buffer.
typedef void (GTMRingBufferPairCallback)(GTMLoggerRingBufferWriter *rbw,
                                         GTMRingBufferPair *pair);


@interface GTMLoggerRingBufferWriter (PrivateMethods)

// Add the message and level to the ring buffer.
- (void)addMessage:(NSString *)message level:(GTMLoggerLevel)level;

// Walk the buffer invoking the callback.
- (void)iterateBufferWithCallback:(GTMRingBufferPairCallback)callback;

@end  // PrivateMethods


@implementation GTMLoggerRingBufferWriter

+ (id)ringBufferWriterWithCapacity:(int)capacity
                            writer:(id<GTMLogWriter>)writer {
  GTMLoggerRingBufferWriter *rbw =
    [[[self alloc] initWithCapacity:capacity
                            writer:writer] autorelease];
  return rbw;

}  // ringBufferWriterWithCapacity


- (id)initWithCapacity:(int)capacity
                writer:(id<GTMLogWriter>)writer {
  if ((self = [super init])) {
    if (capacity > 0) {
      writer_ = [writer retain];
      capacity_ = capacity;

      buffer_ = calloc(capacity_, sizeof(GTMRingBufferPair));

      nextIndex_ = 0;
    }

    if (buffer_ == NULL || writer_ == nil) {
      [self release];
      return nil;
    }
  }

  return self;

}  // initWithCapacity


- (id)init {
  return [self initWithCapacity:0 writer:nil];
}  // init


- (void)dealloc {
  [self reset];

  [writer_ release];
  free(buffer_);

  [super dealloc];
  
}  // dealloc


- (int)capacity {
  return capacity_;
}  // capacity


- (id<GTMLogWriter>)writer {
  return writer_;
}  // writer


- (int)count {
  int count = 0;
  @synchronized(self) {
    if ((nextIndex_ == 0 && totalLogged_ > 0)
        || totalLogged_ >= capacity_) {
      // We've wrapped around
      count = capacity_;
    } else {
      count = nextIndex_;
    }
  }

  return count;

}  // count


- (int)droppedLogCount {
  int droppedCount = 0;
  
  @synchronized(self) {
    droppedCount = totalLogged_ - capacity_;
  }
  
  if (droppedCount < 0) droppedCount = 0;

  return droppedCount;

}  // droppedLogCount


- (int)totalLogged {
  return totalLogged_;
}  // totalLogged


// Assumes caller will do any necessary synchronization.
// This walks over the buffer, taking into account any wrap-around,
// and calls the callback on each pair.
- (void)iterateBufferWithCallback:(GTMRingBufferPairCallback)callback {
  GTMRingBufferPair *scan, *stop;

  // If we've wrapped around, print out the ring buffer from |nextIndex_|
  // to the end.
  if (totalLogged_ >= capacity_) {
    scan = buffer_ + nextIndex_;
    stop = buffer_ + capacity_;
    while (scan < stop) {
      callback(self, scan);
      ++scan;
    }
  }

  // And then print from the beginning to right before |nextIndex_|
  scan = buffer_;
  stop = buffer_ + nextIndex_;
  while (scan < stop) {
    callback(self, scan);
    ++scan;
  }

}  // iterateBufferWithCallback


// Used when resetting the buffer.  This frees the string and zeros out
// the structure.
static void ResetCallback(GTMLoggerRingBufferWriter *rbw,
                          GTMRingBufferPair *pair) {
  [pair->logMessage_ release];
  pair->logMessage_ = nil;
  pair->level_ = 0;
}  // ResetCallback


// Reset the contents.
- (void)reset {
  @synchronized(self) {
    [self iterateBufferWithCallback:ResetCallback];
    nextIndex_ = 0;
    totalLogged_ = 0;
  }

}  // reset


// Go ahead and log the stored backlog, writing it through the
// ring buffer's |writer_|.
static void PrintContentsCallback(GTMLoggerRingBufferWriter *rbw,
                                  GTMRingBufferPair *pair) {
  [[rbw writer] logMessage:pair->logMessage_ level:pair->level_];
}  // PrintContentsCallback


- (void)dumpContents {
  @synchronized(self) {
    [self iterateBufferWithCallback:PrintContentsCallback];
  }
}  // printContents


// Assumes caller will do any necessary synchronization.
- (void)addMessage:(NSString *)message level:(GTMLoggerLevel)level {
    int newIndex = nextIndex_;
    nextIndex_ = (nextIndex_ + 1) % capacity_;
    
    ++totalLogged_;
    
    // Sanity check
    GTMLOGGER_ASSERT(buffer_ != NULL);
    GTMLOGGER_ASSERT(nextIndex_ >= 0 && nextIndex_ < capacity_);
    GTMLOGGER_ASSERT(newIndex >= 0 && newIndex < capacity_);
    
    // Now store the goodies.
    GTMRingBufferPair *pair = buffer_ + newIndex;
    [pair->logMessage_ release];
    pair->logMessage_ = [message copy];
    pair->level_ = level;
  
}  // addMessage


// From the GTMLogWriter protocol.
- (void)logMessage:(NSString *)message level:(GTMLoggerLevel)level {
  @synchronized(self) {
    [self addMessage:message level:level];
    
    if (level >= kGTMLoggerLevelError) {
      [self dumpContents];
      [self reset];
    }
  }

}  // logMessage

@end  // GTMLoggerRingBufferWriter
