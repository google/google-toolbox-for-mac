//
//  GTMDelegatingTableColumn.m
//
//  Copyright 2006-2008 Google Inc.
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

#import "GTMDelegatingTableColumn.h"

@implementation GTMDelegatingTableColumn
- (void)setDelegate:(id)delegate {
  delegate_ = delegate;
}

- (id)delegate {
  return delegate_;
}

- (id)dataCellForRow:(int)row {
  id dataCell = nil;
  if (delegate_ && [delegate_ respondsToSelector:@selector(tableColumn:dataCellForRow:)]) {
    dataCell = [delegate_ tableColumn:self dataCellForRow:row];
  } else {
    dataCell = [super dataCellForRow:row];
  }
  return dataCell;
}
@end
