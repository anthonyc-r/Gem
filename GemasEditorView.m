/* 
   Copyright (C) 2010, 2011, 2012, 2013, 2014 German A. Arias <germanandre@gmx.es>
   Copyright (C) 2020 Anthony Cohn-Richardby <anthonyc@gmx.co.uk>
	
   This file is part of Gemas application

   Gemas is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "GemasEditorView.h"
#import <Foundation/Foundation.h>
#import "GemasDocument.h"
#import <HighlighterKit/HighlighterKit.h>
#import "Preferences.h"
#import "InputModifiers/ObjcAutoIndenter.h"
#import "InputModifiers/InputModifiable.h"


@implementation GemasEditorView (Private)

- (void) updateVisibleHighlighting 
{
  NSLayoutManager *layoutManager;
  NSTextContainer *textContainer;
  NSRange drawnRange;
  NSScrollView *scrollView = (NSScrollView*)[self superview];
  NSRect visibleRect = [scrollView documentVisibleRect];

  layoutManager = [self layoutManager];
  textContainer = [self textContainer];
  drawnRange = [layoutManager glyphRangeForBoundingRect: visibleRect
                              inTextContainer: textContainer];
  [highlighter highlightRange: drawnRange];
}

@end

@implementation GemasEditorView

- (void) dealloc
{
  TEST_RELEASE(highlighter);
  TEST_RELEASE(openCharacters);
  TEST_RELEASE(closeCharacters);
  TEST_RELEASE(type);
  RELEASE(autoIndenter);
  RELEASE(openBrackets);
  RELEASE(closeBrackets);

  [super dealloc];
}

- (void) awakeFromNib
{
  openCharacters = [NSCharacterSet characterSetWithCharactersInString: @"[{("];
  RETAIN(openCharacters);
  closeCharacters = [NSCharacterSet characterSetWithCharactersInString: @"]})"];
  RETAIN(closeCharacters);
  closeBrackets = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
    @"[", @"]",
    @"{", @"}", 
    @"(", @")", 
    NULL];
  openBrackets = [[NSMutableDictionary alloc] initWithObjectsAndKeys: 
    @"]", @"[",
    @"}", @"{",
    @")", @"(", 
    NULL];
  
  autoIndenter = nil;
  if ([Preferences autoIndentEnabled]) 
  {
    autoIndenter = [[ObjcAutoIndenter alloc] initWithFiletype: type];
  }
}

- (void) highlightRange: (NSRange)range
{
  [highlighter highlightRange: range]; 
}

// Find ":" for next parameter
- (void) nextParameter: (id)sender
{
  NSRange range;
  NSUInteger loc = [self selectedRange].location;
  
  range = [[[self string] substringToIndex: loc] rangeOfString: @" "
                                             options: NSBackwardsSearch];
  
  if (range.location != NSNotFound)
    {
      NSString *line = nil;
      
      line = [[[self string] substringToIndex: loc]
                           substringFromIndex: range.location];
      
      range = [line rangeOfString: @":"];
      
      if (range.location != NSNotFound &&
           range.location < ([line length] - 1))
        {
          [self setSelectedRange: NSMakeRange(loc -
                                      ([line length] - range.location) + 1, 0)];
        }
      else
        {
          range = [[[self string] substringFromIndex: loc] rangeOfString: @":"];
          
          if (range.location != NSNotFound)
            {
              [self setSelectedRange: NSMakeRange(range.location + loc + 1, 0)];
            }
        }
    }
  else
    {
      range = [[[self string] substringFromIndex: loc] rangeOfString: @":"];
          
      if (range.location != NSNotFound)
        {
          [self setSelectedRange: NSMakeRange(range.location + loc + 1, 0)];
        }
    }
}

- (void) setAutoIndenter: (id)anAutoIndenter
{
  ASSIGN(autoIndenter, anAutoIndenter);
}

//Insert the correponding indentation when the user press Tab key
- (void) insertTab: (id)sender
{
	 if ([autoIndenter modifyTab: self]) 
	   {
	   	 return;
 	   }
  [super insertText: [Preferences indentation]];
}

//If the new line need indentation, add it
- (void) insertNewline: (id)sender
{
	 if ([autoIndenter modifyNewline: self]) 
	   {
	    return;	
 	   }
  [super insertNewline: sender];
}

- (void) insertText: (id)string
{
  if ([autoIndenter modifyInput: string forModifiable: self]) 
  	 {
      return;
    }	
  [super insertText: string];
}

- (void) didChangeText
{
  [self updateVisibleHighlighting];
  [super didChangeText];
}

// Delete from the beginning of line to current position
- (void) deleteToBeginningOfLine: (id)sender
{
  NSUInteger start;
  NSUInteger loc = [self selectedRange].location;
  
  start = [[[self string] substringToIndex: loc]
                                          rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet]
                                                                            options: NSBackwardsSearch].location;
  
  if (start == NSNotFound)
    {
      start = -1;
    }
  
  if (loc > start + 1)
    {
      [self setSelectedRange: NSMakeRange(start + 1, loc - start - 1)];
      [self delete: self];
    }
}

// Delete from current position to end of line
- (void) deleteToEndOfLine: (id)sender
{
  NSUInteger end;
  NSUInteger loc = [self selectedRange].location;
  
  end = [[[self string] substringFromIndex: loc]
                                          rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet]].location;
  
  if (end == NSNotFound)
    {
      end = [[self string] length] - 1;
    }
  
  if (end > 1)
    {
      [self setSelectedRange: NSMakeRange(loc, end)];
      [self delete: self];
    }
}

/*Select the range of parentheses when the user do a double 
  click obove one*/
- (void) mouseDown: (NSEvent *)event 
{
  NSRange textRange;
  NSString *selection;
  [super mouseDown: event];
  textRange = [self selectedRange];
  selection = [[self string] substringFromRange: textRange];
  if (textRange.length != 1)
    {
      return;      
    }
  NSString *opositeMatch, *context;
  NSRange matchRange;

  if ((opositeMatch = [openBrackets objectForKey: selection]))
    {
      context = [[self string] substringFromIndex: textRange.location];
      matchRange = [context rangeOfString: opositeMatch options: 0];
      if (matchRange.location != NSNotFound)
        {
          [self setSelectedRange: NSMakeRange(textRange.location, matchRange.location + 1)];
        }
    }
  else if ((opositeMatch = [closeBrackets objectForKey: selection]))
    {
      context = [[self string] substringToIndex: textRange.location];
      matchRange = [context rangeOfString: opositeMatch options: NSBackwardsSearch];
      if (matchRange.location != NSNotFound)
        {
          [self setSelectedRange: NSMakeRange(matchRange.location, (textRange.location - 
            matchRange.location) + 1)];
        }
    }
}

- (NSRange) rangeForUserCompletion
{
  NSUInteger count = 0;
  NSRange range = [super rangeForUserCompletion];
  NSString *word = [[self string] substringWithRange: range];
  
  while ([word hasPrefix: @"["] || [word hasPrefix: @"("])
    {
      word = [word substringFromIndex: 1];
      count += 1;
    }
  
  return NSMakeRange(range.location + count, range.length - count);
}

//Creates a new syntax highlighter for the specified file type
- (void) createSyntaxHighlighterForFileType: (NSString *) fileType
{
  NSString *name = [[editorDocument fileName] lastPathComponent];
  type = [NSString stringWithString: fileType];
  
  if ([type isEqualToString: @"GNUmakefile"] && ([name length] > 0))
    {
      if (![name hasPrefix: @"GNUmakefile"] &&
          ![name isEqualToString: @"ChangeLog"] &&
          ![name isEqualToString: @"Changelog"])
        {
          type = @"Generic";
        }
      else if ([name isEqualToString: @"ChangeLog"] ||
               [name isEqualToString: @"Changelog"])
        {
          type = @"ChangeLog";
        }
    }
  
  ASSIGN (highlighter, [[[HKSyntaxHighlighter alloc]
                          initWithHighlighterType: type
                          textStorage: [self textStorage]
                          defaultTextColor: [editorDocument textColor]]
                          autorelease]);
                          
  [type retain];

  if ([type isEqualToString: @"C"])
    {
      [[self window] setMiniwindowImage: [NSImage imageNamed: @"FileIcon_.c"]];
    }

  if ([type isEqualToString: @"C-Header"])
    {
      [[self window] setMiniwindowImage: [NSImage imageNamed: @"FileIcon_.h"]];
    }

  if ([type isEqualToString: @"C++"])
    {
      [[self window] setMiniwindowImage: [NSImage imageNamed: @"FileIcon_.cc"]];
    }

  if ([type isEqualToString: @"ObjC"])
    {
      [[self window] setMiniwindowImage: [NSImage imageNamed: @"FileIcon_.m"]];
    }

  if ([type isEqualToString: @"ObjC++"])
    {
      [[self window] setMiniwindowImage: [NSImage imageNamed: @"FileIcon_.mm"]];
    }

  if ([type isEqualToString: @"Plist"])
    {
      [[self window] setMiniwindowImage: [NSImage imageNamed: @"FileIcon_.plist"]];
    }

  if ([type isEqualToString: @"Strings"])
    {
      [[self window] setMiniwindowImage: [NSImage imageNamed: @"FileIcon_.strings"]];
    }

  if ([type isEqualToString: @"GSmarkup"])
    {
      [[self window] setMiniwindowImage: [NSImage imageNamed: @"FileIcon_.gsmarkup"]];
    }

  if ([type isEqualToString: @"GNUmakefile"])
    {
      [[self window] setMiniwindowImage: [NSImage imageNamed: @"FileIcon_makefile"]];
    }
  
  if ([type isEqualToString: @"Generic"] || [type isEqualToString: @"ChangeLog"])
    {
      [[self window] setMiniwindowImage: [NSImage imageNamed: @"common_Unknown"]];
    }
}

- (void) modifyInputByReplacingRange: (NSRange)aRange withString: (NSString*)aString {
  [self replaceCharactersInRange: aRange withString: aString];
}

- (void) modifyInputByInserting: (NSString*)aString {
   [super insertText: aString];
}

- (void) modifyInputByInsertingTab {
  [super insertText: [Preferences indentation]];
}

- (void) modifyInputByInsertingNewline {
   [super insertNewline: self];
}

- (NSString*) inputModifiableString {
  return [self string];
}

- (int) inputModifiableCursor {
  return [self selectedRange].location;
}

@end
