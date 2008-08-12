//
//  GTMProgressMonitorInputStream.m
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

#import "GTMProgressMonitorInputStream.h"
#import "GTMDefines.h"
#import "GTMDebugSelectorValidation.h"

@implementation GTMProgressMonitorInputStream

// we'll forward all unhandled messages to the NSInputStream class
// or to the encapsulated input stream.  This is needed
// for all messages sent to NSInputStream which aren't
// handled by our superclass; that includes various private run
// loop calls.
+ (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
  return [NSInputStream methodSignatureForSelector:selector];
}

+ (void)forwardInvocation:(NSInvocation*)invocation {  
  [invocation invokeWithTarget:[NSInputStream class]];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
  return [inputStream_ methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation {    
  [invocation invokeWithTarget:inputStream_];
}

#pragma mark -

+ (id)inputStreamWithStream:(NSInputStream *)input 
                     length:(unsigned long long)length {
  
  return [[[self alloc] initWithStream:input 
                                length:length] autorelease];
}

- (id)initWithStream:(NSInputStream *)input 
              length:(unsigned long long)length {
  
  if ((self = [super init]) != nil) {
    
    inputStream_ = [input retain];
    dataSize_ = length;
    
    if (!inputStream_) {
      [self release];
      self = nil;
    }
  }
  return self;
}

#pragma mark -

- (id)init {
  return [self initWithStream:nil length:0];
}

- (id)initWithData:(NSData *)data {
  unsigned long long dataLength = [data length];
  NSInputStream *inputStream = nil;
  if (data) {
    inputStream = [NSInputStream inputStreamWithData:data];
  }
  return [self initWithStream:inputStream length:dataLength];
}

- (id)initWithFileAtPath:(NSString *)path {
  NSDictionary *fileAttrs =
    [[NSFileManager defaultManager] fileAttributesAtPath:path
                                            traverseLink:YES];
  unsigned long long fileSize = [fileAttrs fileSize];
  NSInputStream *inputStream = nil;
  if (fileSize) {
    inputStream = [NSInputStream inputStreamWithFileAtPath:path];
  }
  return [self initWithStream:inputStream length:fileSize];
}

- (void)dealloc {
  [inputStream_ release];
  [super dealloc]; 
}

#pragma mark -

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {

  NSInteger numRead = [inputStream_ read:buffer maxLength:len];
  
  if (numRead > 0) {
    
    numBytesRead_ += numRead;
    
    if (monitorDelegate_ && monitorSelector_) {
      
      // call the monitor delegate with the number of bytes read and the
      // total bytes read
      
      NSMethodSignature *signature = [monitorDelegate_ methodSignatureForSelector:monitorSelector_];
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:monitorSelector_];
      [invocation setTarget:monitorDelegate_];
      [invocation setArgument:&self atIndex:2];
      [invocation setArgument:&numBytesRead_ atIndex:3];
      [invocation setArgument:&dataSize_ atIndex:4];
      [invocation invoke];
    }
  }
  return numRead;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len {
  // TODO: doesn't this advance the stream so we should warn the progress
  // callback?  NSInputStream w/ a file and NSData both seem to return NO for
  // this so I'm not sure how to test it.
  return [inputStream_ getBuffer:buffer length:len];
}

- (BOOL)hasBytesAvailable {
  return [inputStream_ hasBytesAvailable];
}

#pragma mark Standard messages

// Pass expected messages to our encapsulated stream.
//
// We want our encapsulated NSInputStream to handle the standard messages;
// we don't want the superclass to handle them.
- (void)open {
  [inputStream_ open]; 
}

- (void)close {
  [inputStream_ close]; 
}

- (id)delegate {
  return [inputStream_ delegate]; 
}

- (void)setDelegate:(id)delegate {
  [inputStream_ setDelegate:delegate];
}

- (id)propertyForKey:(NSString *)key {
  return [inputStream_ propertyForKey:key]; 
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key {
  return [inputStream_ setProperty:property forKey:key]; 
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
  [inputStream_ scheduleInRunLoop:aRunLoop forMode:mode]; 
}
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
  [inputStream_ removeFromRunLoop:aRunLoop forMode:mode]; 
}

- (NSStreamStatus)streamStatus {
  return [inputStream_ streamStatus]; 
}

- (NSError *)streamError {
  return [inputStream_ streamError];
}

#pragma mark Setters and getters

- (void)setMonitorDelegate:(id)monitorDelegate
                  selector:(SEL)monitorSelector {
  monitorDelegate_ = monitorDelegate; // non-retained
  monitorSelector_ = monitorSelector; 
  GTMAssertSelectorNilOrImplementedWithArguments(monitorDelegate,
                                                 monitorSelector,
                                                 @encode(GTMProgressMonitorInputStream *),
                                                 @encode(unsigned long long),
                                                 @encode(unsigned long long),
                                                 NULL);
}

- (id)monitorDelegate {
  return monitorDelegate_; 
}

- (SEL)monitorSelector {
  return monitorSelector_;
}

- (void)setMonitorSource:(id)source {
  monitorSource_ = source;  // non-retained
}

- (id)monitorSource {
  return monitorSource_; 
}

@end
