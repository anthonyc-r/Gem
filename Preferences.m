/*
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
#include <Preferences.h>

#define KEY_INDENTATION @"identationSym"
#define KEY_TABWIDTH @"tabWidth"

static NSString *indentation;
static int lenForTabWidth(TabWidth tw) {
  switch (tw) {
    case TabWidthTwo: return 2;
    case TabWidthFour: return 4; 
    case TabWidthEight: return 8;
  }
}
static void calculateIndentation() {
  char *str;
  int len;
  TabWidth tw = [[NSUserDefaults standardUserDefaults] integerForKey: KEY_TABWIDTH];
  IndentationType it = [[NSUserDefaults standardUserDefaults] 
    integerForKey: KEY_INDENTATION];
  [indentation release];
  switch (it) {
    case IndentationTypeTabs:
      indentation = [[NSString alloc] initWithCString: "\t"];
      break;
    case IndentationTypeSpaces:
      len = lenForTabWidth(tw);
      str = malloc(len + 1);
      for (int i = 0; i < len; i++) {
        str[i] = ' '; 
      }
      str[len] = '\0';
      indentation = [[NSString alloc] initWithCString: str];
      free(str);
      break;
  }
}

@implementation Preferences
+(NSString*)indentation {
  if (indentation == nil) {
    calculateIndentation(); 
  }
  return indentation;
}

+(int)tabWidthSpaces {
  return lenForTabWidth([self tabWidth]); 
}

+(TabWidth)tabWidth {
  return [[NSUserDefaults standardUserDefaults] integerForKey: KEY_TABWIDTH];
}

+(IndentationType)indentationType {
  return [[NSUserDefaults standardUserDefaults] integerForKey: KEY_INDENTATION];
}

+(void)setIndentationType: (IndentationType)newValue {
  [[NSUserDefaults standardUserDefaults] setInteger: newValue
                                   forKey: KEY_INDENTATION];
  calculateIndentation();
}
+(void)setTabWidth: (TabWidth)newValue {
  [[NSUserDefaults standardUserDefaults] setInteger: newValue
                                         forKey: KEY_TABWIDTH];
  calculateIndentation();
}

@end