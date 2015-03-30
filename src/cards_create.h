// cards_create.h
//
//  Copyright (c) 2013-2015 by NuTyX team (http://nutyx.org)
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
//  USA.
//
#ifndef CARDSCREATE_H
#define CARDSCREATE_H

#include "pkgdbh.h"
#include "cards_argument_parser.h"

class CardsCreate : public Pkgdbh {

public:
	CardsCreate(const CardsArgumentParser& argParser);

	virtual void run(int argc, char** argv);
	virtual void printHelp() const;
private:
	const std::string m_baseDirectory;
	const CardsArgumentParser& m_argParser;
};
#endif /* CARDSCREATE_H */