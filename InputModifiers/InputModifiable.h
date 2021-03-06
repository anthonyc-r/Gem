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
#ifndef _INPUTMODIFIABLE_H
#define _INPUTMODIFIABLE_H
 
#include <Foundation/Foundation.h>
 
@protocol InputModifiable
 
- (void) modifyInputByReplacingRange: (NSRange)aRange withString: (NSString*)aString;
- (void) modifyInputByInserting: (NSString*)aString;
- (void) modifyInputByInsertingTab;
- (void) modifyInputByInsertingNewline;
- (NSString*) inputModifiableString;
- (int) inputModifiableCursor;
 
@end

#endif