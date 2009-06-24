//
//  GTMUILocalizer.m
//
//  Copyright 2009 Google Inc.
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

#import "GTMDefines.h"
#import "GTMUILocalizer.h"

@implementation GTMUILocalizer
- (id)initWithBundle:(NSBundle *)bundle {
  if ((self = [super init])) {
    bundle_ = [bundle retain];
  }
  return self;
}

- (void)dealloc {
  [bundle_ release];
  [super dealloc];
}

- (void)awakeFromNib {
  if (owner_) {
    NSBundle *newBundle = [self bundleForOwner:owner_];
    bundle_ = [newBundle retain];
    [self localizeObject:owner_ recursively:YES];
    [self localizeObject:otherObjectToLocalize_ recursively:YES];
    [self localizeObject:yetAnotherObjectToLocalize_ recursively:YES];
  } else {
    _GTMDevLog(@"Expected an owner_ set for %@", self);
  }
}

- (NSBundle *)bundleForOwner:(id)owner {
  NSBundle *newBundle = nil;
  if (owner) {
    Class class = NSClassFromString(@"NSViewController");
    if ([owner isKindOfClass:class]) {
      newBundle = [owner performSelector:@selector(nibBundle)];
    } else {
      class = [NSWindowController class];
      if ([owner isKindOfClass:class] 
          && ![owner isMemberOfClass:class]) {
        newBundle = [NSBundle bundleForClass:[owner class]];
      }
    }
    if (!newBundle) {
      newBundle = [NSBundle mainBundle];
    }
  }
  return newBundle;
}

- (NSString *)localizedStringForString:(NSString *)string {
  NSString *localized = nil;
  if (bundle_ && [string hasPrefix:@"^"]) {
    NSString *notFoundValue = @"__GTM_NOT_FOUND__";
    NSString *key = [string substringFromIndex:1];
    localized = [bundle_ localizedStringForKey:key 
                                         value:notFoundValue 
                                         table:nil];
    if ([localized isEqualToString:notFoundValue]) {
      localized = nil;
    }
  }
  return localized;
}

- (void)localizeObject:(id)object recursively:(BOOL)recursive {
  if (object) {
    if ([object isKindOfClass:NSClassFromString(@"NSViewController")]) {
      NSView *view = [object view];
      [self localizeView:view recursively:recursive];
    } else if ([object isKindOfClass:[NSWindowController class]]) {
      NSWindow *window = [object window];
      [self localizeWindow:window recursively:recursive];
    } else if ([object isKindOfClass:[NSMenu class]]) {
      [self localizeMenu:(NSMenu *)object recursively:recursive];
    } else if ([object isKindOfClass:[NSWindow class]]) {
      [self localizeWindow:(NSWindow *)object recursively:recursive];
    } else if ([object isKindOfClass:[NSView class]]) {
      [self localizeView:(NSView *)object recursively:recursive];
    } else if ([object isKindOfClass:[NSApplication class]]) {
      // Do the main menu
      NSMenu *menu = [object mainMenu];
      [self localizeMenu:menu recursively:recursive];
    }
  }
}

- (void)localizeWindow:(NSWindow *)window recursively:(BOOL)recursive {
  NSString *title = [window title];
  NSString *localizedTitle = [self localizedStringForString:title];
  if (localizedTitle) {
    [window setTitle:localizedTitle];
  }
  if (recursive) {
    NSView *content = [window contentView];
    [self localizeView:content recursively:recursive];
  }
}

- (void)localizeView:(NSView *)view recursively:(BOOL)recursive {
  if (view) {
    // First do tooltips
    NSString *toolTip = [view toolTip];
    if (toolTip) {
      NSString *localizedToolTip = [self localizedStringForString:toolTip];
      if (localizedToolTip) {
        [view setToolTip:localizedToolTip];
      }
    }
    
    // Then do accessibility stuff
    NSArray *supportedAttrs = [view accessibilityAttributeNames];
    if ([supportedAttrs containsObject:NSAccessibilityHelpAttribute]) {
      NSString *accessibilityHelp 
        = [view accessibilityAttributeValue:NSAccessibilityHelpAttribute];
      if (accessibilityHelp) {
        NSString *localizedAccessibilityHelp 
          = [self localizedStringForString:accessibilityHelp];
        if (localizedAccessibilityHelp) {
          [view accessibilitySetValue:localizedAccessibilityHelp
                         forAttribute:NSAccessibilityHelpAttribute];
        }
      }
    }
    
    if ([supportedAttrs containsObject:NSAccessibilityDescriptionAttribute]) {
      NSString *accessibilityDesc 
        = [view accessibilityAttributeValue:NSAccessibilityDescriptionAttribute];
      if (accessibilityDesc) {
        NSString *localizedAccessibilityDesc 
          = [self localizedStringForString:accessibilityDesc];
        if (localizedAccessibilityDesc) {
          [view accessibilitySetValue:localizedAccessibilityDesc
                         forAttribute:NSAccessibilityDescriptionAttribute];
        }
      }
    }
    
    // Must do the menu before the titles, or else this will screw up
    // popup menus on us.
    [self localizeMenu:[view menu] recursively:recursive];
    if (recursive) {
      NSArray *subviews = [view subviews];
      NSView *subview = nil;
      GTM_FOREACH_OBJECT(subview, subviews) {
        [self localizeView:subview recursively:recursive];
      }
    }
    
    // Then do titles
    if ([view isKindOfClass:[NSTextField class]]) {
      NSString *title = [(NSTextField *)view stringValue];
      NSString *localizedTitle = [self localizedStringForString:title];
      if (localizedTitle) {
        [(NSTextField *)view setStringValue:localizedTitle];
      }
    } else if ([view respondsToSelector:@selector(title)] 
        && [view respondsToSelector:@selector(setTitle:)]) {
      NSString *title = [view performSelector:@selector(title)];
      if (title) {
        NSString *localizedTitle = [self localizedStringForString:title];
        if (localizedTitle) {
          [view performSelector:@selector(setTitle:) withObject:localizedTitle];
        }
      }
      if ([view respondsToSelector:@selector(alternateTitle)] 
          && [view respondsToSelector:@selector(setAlternateTitle:)]) {
        title = [view performSelector:@selector(alternateTitle)];
        if (title) {
          NSString *localizedTitle = [self localizedStringForString:title];
          if (localizedTitle) {
            [view performSelector:@selector(setAlternateTitle:) 
                       withObject:localizedTitle];
          }
        }
      }
    } else if ([view respondsToSelector:@selector(tabViewItems)]) {
      NSArray *items = [view performSelector:@selector(tabViewItems)];
      NSEnumerator *itemEnum = [items objectEnumerator];
      NSTabViewItem *item = nil;
      while ((item = [itemEnum nextObject])) {
        NSString *label = [item label];
        NSString *localizedLabel = [self localizedStringForString:label];
        if (localizedLabel) {
          [item setLabel:localizedLabel];
        }
        if (recursive) {
          [self localizeView:[item view] recursively:recursive];
        }
      }
    }
  }
  
  // Do NSSearchField placeholders
  if ([view isKindOfClass:[NSSearchField class]]) {
    NSString *placeholder = [[(NSSearchField *)view cell] placeholderString];
    NSString *localizedPlaceholer = [self localizedStringForString:placeholder];
    if (localizedPlaceholer) {
      [[(NSSearchField *)view cell] setPlaceholderString:localizedPlaceholer];
    }
  }
}

- (void)localizeMenu:(NSMenu *)menu recursively:(BOOL)recursive {
  if (menu) {
    NSString *title = [menu title];
    NSString *localizedTitle = [self localizedStringForString:title];
    if (localizedTitle) {
      [menu setTitle:localizedTitle];
    }
    NSArray *menuItems = [menu itemArray];
    NSMenuItem *menuItem = nil;
    GTM_FOREACH_OBJECT(menuItem, menuItems) {
      title = [menuItem title];
      localizedTitle = [self localizedStringForString:title];
      if (localizedTitle) {
        [menuItem setTitle:localizedTitle];
      }
      if (recursive) {
        [self localizeMenu:[menuItem submenu] recursively:recursive];
      }
    }
  }    
}
@end
