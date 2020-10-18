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
#ifndef _OBJCAUTOINDENTER_H
#define _OBJCAUTOINDENTER_H
 
#include <Foundation/Foundation.h>
#include "InputModifiable.h"
 
@interface ObjcAutoIndenter: NSObject {
	 id type;
	 id nonEnglishCharacters;
	 id backIndentCharacters;
	 id indentCharacters;
	 id otherIndentCharacters;
}

-(void)setType: (NSString*)newValue;
-(BOOL)modifyInput: (NSString*)input forModifiable: (id<InputModifiable>)view;
-(BOOL)modifyNewline: (id<InputModifiable>)view;
-(BOOL)modifyTab: (id<InputModifiable>)view;

@end

#endif
 