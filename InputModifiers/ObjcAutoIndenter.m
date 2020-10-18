/*
    
    Actual method implementations:
    Copyright (C) 2010, 2011, 2012, 2013, 2014 German A. Arias <germanandre@gmx.es>
    Modified and refactored:
    Copyright (C) 2020 Anthony Cohn-Richardby

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
 
#include <Foundation/Foundation.h>
#include "ObjcAutoIndenter.h"
#include "InputModifiable.h"
#include "../Preferences.h"


@interface ObjcAutoIndenter (Private)

- (NSString *) indentForCloseBracket: (id<InputModifiable>)view;
- (BOOL) isGSmarkupIndent: (NSString *)string;
- (BOOL) isGSmarkupBackIndent: (NSString *)string;
- (void) insertSpace: (id<InputModifiable>)view;

@end

@implementation ObjcAutoIndenter (Private)

- (NSString *) indentForCloseBracket: (id<InputModifiable>)view
{
  NSUInteger start;
  NSString *selection = @"}", *search = @"{" ;
  NSRange firstClose, firstOpen;
  int cursorLoc = [view inputModifiableCursor];
  
  NSString *contextA, *contextB, *sub;
  NSString *context = [[view inputModifiableString] substringFromRange: NSMakeRange(0, cursorLoc)];
  
  firstOpen = [context rangeOfString: search options: NSBackwardsSearch];
  firstClose = [context rangeOfString: selection options: NSBackwardsSearch];
  
  // If no open bracket return nil.
  if (firstOpen.location == NSNotFound)
    {
      return nil;
    }

  while ((firstOpen.location < firstClose.location) &&
               (firstClose.length != 0) && (firstClose.length != 0))
    {
      contextA = [[view inputModifiableString] substringFromRange: 
    	  NSMakeRange(0, firstOpen.location)];
      contextB = [[view inputModifiableString] substringFromRange: 
    	  NSMakeRange(0, firstClose.location)];
      
      firstOpen = [contextA rangeOfString: search options: NSBackwardsSearch];
      firstClose = [contextB rangeOfString: selection options: NSBackwardsSearch];
    }
  
  // If there isn't a corresponding open bracket return nil.
  if (firstOpen.location == NSNotFound)
    {
      return nil;
    }
  
  start = [[[view inputModifiableString] substringToIndex: firstOpen.location]
                                          rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet]
                                                                            options: NSBackwardsSearch].location;
  
  if (start == NSNotFound)
    {
      start = -1;
    }
  
  sub = [[view inputModifiableString] substringFromRange: 
    NSMakeRange(start + 1, firstOpen.location - start - 1)];
  
  if ([[sub stringByTrimmingLeadSpaces] length] > 0)
    {
      return nil;
    }
  else
    {
      return sub;
    }
}

- (BOOL) isGSmarkupIndent: (NSString *)string
{
  if ([type isEqualToString: @"GSmarkup"])
    {
      if ([string hasPrefix: @"<"] &&
          [string hasSuffix: @">"] &&
          ![string hasPrefix: @"<!"] &&
          ![string hasPrefix: @"<?"] &&
          ![string hasPrefix: @"</"] &&
          ![string hasSuffix: @"/>"] &&
          ![string hasSuffix: @"</label>"] &&
          ![string hasSuffix: @"</textField>"] &&
          ![string hasSuffix: @"</secureTextField>"])
        {
          return YES;
        }
      else
        {
          return NO;
        }
    }
  else
    {
      return NO;
    }
}

- (BOOL) isGSmarkupBackIndent: (NSString *)string
{
  return NO;
}

- (void) insertSpace: (id<InputModifiable>)view
{
  [view modifyInputByInserting: [Preferences indentation]];
}

@end
 
@implementation ObjcAutoIndenter

-(void)setType: (NSString*)newValue {
  ASSIGN(type, newValue);
}

-(BOOL)modifyInput: (NSString*)input forModifiable: (id<InputModifiable>)view {
	 NSString *string = [view inputModifiableString];
	 int cursor = [view inputModifiableCursor];
  if ([string isKindOfClass: [NSString class]] && ([string length] > 0) )
    {
      /* Insert the corresponding code instead the character for non english
         character. */
      if ([type isEqualToString: @"Strings"] || [type isEqualToString: @"Plist"])
        {
          if ([[nonEnglishCharacters allKeys] containsObject: string])
            {
              [view modifyInputByInserting: [nonEnglishCharacters objectForKey: string]];
            }
          else if ([string length] > 1)
            {
              int x;
              NSString *character;
              for (x = 0; x < [string length]; x++)
                {
                  character = [string substringFromRange: NSMakeRange(x, 1)];
                  
                  if ([[nonEnglishCharacters allKeys] containsObject: character])
                    {
                      [view modifyInputByInserting: [nonEnglishCharacters objectForKey:
                    	  character]];
                    }
                  else
                    {
                      [view modifyInputByInserting: character];
                    }
                }
            }
          else
            {
              [view modifyInputByInserting: string];
            }
        }
      // Indent the line if user insert "*" in ChangeLog files.
      else if ([type isEqualToString: @"ChangeLog"] && [string isEqualToString: @"*"])
        {
          NSArray *lines = [[string
                              substringFromRange: NSMakeRange(0, cursor)]
                              componentsSeparatedByString: @"\n"];
          
          if ([[lines objectAtIndex: [lines count] - 1] length] > 0)
            {
              [view modifyInputByInserting: string];
            }
          else
            {
              [view modifyInputByInserting: @"        *"];
            }
        }
      // Indentation cases in Objective-C and GSmarkup.
      else if (([backIndentCharacters characterIsMember: [string characterAtIndex: 0]]) ||
               ([indentCharacters characterIsMember: [string characterAtIndex: 0]]) ||
               ([otherIndentCharacters characterIsMember: [string characterAtIndex: 0]]) ||
               ([string isEqualToString: @";"]) ||
               ([string isEqualToString: @"c"]) ||
               ([type isEqualToString: @"GSmarkup"] && [string isEqualToString: @"/"]))
        {
          BOOL gsmarkup = NO;
          BOOL backIndent = NO;
          BOOL backIndentCase = NO;
          NSString *prevLine, *lastLine;
          NSArray *lines = [[string
                              substringFromRange: NSMakeRange(0, cursor)]
                              componentsSeparatedByString: @"\n"];
          
          // Get previous line.                   
          if ([lines count] >= 2)
            {
              prevLine = [lines objectAtIndex: [lines count] - 2];
            }
          else
            {
              prevLine = @"";
            }
          
          // Get last line.
          if ([lines count] >= 1)
            {
              lastLine = [lines objectAtIndex: [lines count] - 1];
            }
          else
            {
              lastLine = @"";
            }
          
          int length;
          NSString *stringToReplace;
          NSCharacterSet *spaces = [NSCharacterSet whitespaceCharacterSet];
          NSCharacterSet *charsLine = [NSCharacterSet characterSetWithCharactersInString:
                                                      lastLine];

          // Check if is a gsmarkup case.
          if ([[lastLine stringByTrimmingLeadSpaces] isEqualToString: @"<"] && 
              [type isEqualToString: @"GSmarkup"])
            {
              gsmarkup = YES;
            }

          // Check if is a backindent case with "break".
          if ([[prevLine stringByTrimmingTailSpaces] hasSuffix: @"}"] &&
              [[lastLine stringByTrimmingLeadSpaces] isEqualToString: @"break"] &&
              [string isEqualToString: @";"])
            {
              backIndent = YES;
            }
          
          // Check if is a backindent case with "case".
          if ([[prevLine stringByTrimmingLeadSpaces] hasPrefix: @"case "] &&
              [string isEqualToString: @"c"])
            {
              backIndentCase = YES;
            }
          
          // Get the string to replace, if apply.  
          if ((([lastLine length] == 0) || ([spaces isSupersetOfSet: charsLine])) ||
                 gsmarkup ||
                 backIndent)
            {
              stringToReplace = [NSString stringWithString: lastLine];
            }
          else
            {
              [view modifyInputByInserting: string];
              return YES;
            }
          
          length = [stringToReplace length];

          //Check if is a gsmarkup character
          if (gsmarkup)
            {
              stringToReplace = [stringToReplace stringByDeletingPrefix: 
                                                 [Preferences indentation]];
            }
          // Back indent with "break".
          else if (backIndent)
            {
              NSString *replacement = [NSString stringWithFormat: @"%@break",
                                                [Preferences indentation]];
              stringToReplace = [stringToReplace stringByReplacingString: @"break"
                                                     withString: replacement];
            }
          // Back indent with "case", when the user add other "case" in current line.
          else if (backIndentCase)
            {
              stringToReplace = [stringToReplace stringByDeletingPrefix: 
                                                 [Preferences indentation]];
            }
          // Check backindent for characters "{" after close a multiline condition.
          else if ([indentCharacters characterIsMember: [string characterAtIndex: 0]])
            {
              NSString *str = [[prevLine stringByTrimmingTailSpaces]
                                                 stringByTrimmingLeadSpaces];
              
              if (![str hasPrefix: @"else if"] && ![str hasPrefix: @"if"] &&
                   ![str hasPrefix: @"while"] && ![str hasPrefix: @"switch"] &&
                   ![str hasPrefix: @"for"] && [str hasSuffix: @")"] &&
                   ([stringToReplace length] >= 5))
                {
                  stringToReplace = [stringToReplace stringByDeletingPrefix: @"   "];
                }
            }
          // Check indentation of a line in a multiline condition.
          else if ([otherIndentCharacters characterIsMember: [string characterAtIndex: 0]])
            {
              NSString *str = [prevLine stringByTrimmingLeadSpaces];
              
              if ([str hasPrefix: @"else if"] || [str hasPrefix: @"if"] ||
                   [str hasPrefix: @"while"])
                {
                  stringToReplace = [stringToReplace stringByAppendingString: @"   "];
                }
            }
          else if (![string isEqualToString: @";"] && ![string isEqualToString: @"c"])
            {
              /* Back indent for "}", except after "break" which
                 backindent automatically. */
              if (![[prevLine stringByTrimmingTailSpaces] hasSuffix: @"break;"])
                {
                  stringToReplace = [stringToReplace stringByDeletingPrefix: 
                                                     [Preferences indentation]];
                  
                  // Backindent if the user insert "}".
                  if ([backIndentCharacters characterIsMember:
                                            [string characterAtIndex: 0]])
                    {
                      NSString *space = [self indentForCloseBracket: view];
                      
                      if (space != nil)
                        {
                          stringToReplace = space;
                        }
                    }
                }
            }
          
          [view modifyInputByReplacingRange: NSMakeRange(cursor - length, length)
                withString: stringToReplace];
          [view modifyInputByInserting: string];
        }
      else
        {
          [view modifyInputByInserting: string];
        }
    }
  else
    {
      [view modifyInputByInserting: string];
    }
  return YES;
}

-(BOOL)modifyNewline: (id<InputModifiable>)view {
  return NO;
}

-(BOOL)modifyTab: (id<InputModifiable>)view {
	 return NO;
}

@end
 