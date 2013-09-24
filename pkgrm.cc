//
//  cards
// 
//  Copyright (c) 2000-2005 Per Liden
//  Copyright (c) 2006-2013 by CRUX team (http://crux.nu)
//  Copyright (c) 2013 by NuTyX team (http://nutyx.org)
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

#include "pkgrm.h"
#include <unistd.h>
#include <stdio.h>

void pkgrm::run(int argc, char** argv)
{
	//
	// Check command line options
	//
	string o_package;
	string o_root;

	for (int i = 1; i < argc; i++) {
		string option(argv[i]);
		if (option == "-r" || option == "--root") {
			assert_argument(argv, argc, i);
			o_root = argv[i + 1];
			i++;
		} else if (option[0] == '-' || !o_package.empty()) {
			throw runtime_error("invalid option " + option);
		} else {
			o_package = option;
		}
	}

	if (o_package.empty())
		throw runtime_error("option missing");
	
	// Check UID
	if (getuid())
		throw runtime_error("only root can remove packages");

	// Remove package
	{
		db_lock lock(o_root, true);

		// Get the list of installed packages
		list_pkg(o_root);

		// Retrieve info about all the packages
		db_open_2();

		if (!db_find_pkg(o_package))
			throw runtime_error("package " + o_package + " not installed");

		// Remove metadata about the package removed 
		db_rm_pkg(o_package);

		// Remove the files on hd
		rm_pkg_files(o_package);
		ldconfig();
	}
}
void pkgrm::progress() const
{
	static int j = 0;
	int i;
	switch ( actual_action )
	{
		case DB_OPEN_START:
			cout << "Retrieve info about the " << set_of_db.size() << " packages: ";
			break;

		case DB_OPEN_RUN:
			if ( set_of_db.size()>100)
			{
				i = j / ( set_of_db.size() / 100);
				printf("%3d%%\b\b\b\b",i);
			}
			j++;
			break;
    
		case DB_OPEN_END:
			printf("100 %%\n");
      break;

		case RM_PKG_FILES_START:
			j=0;
			cout << "Removing " << files.size() << " files: ";
			break;

		case RM_PKG_FILES_RUN:
			if ( files.size()>100)
			{
				i = j / ( files.size() / 100);
				printf("%3d%%\b\b\b\b",i);
			}
			j++;
			break;

		case RM_PKG_FILES_END:
			printf("100 %%\n");
			break;
	}
}
void pkgrm::print_help() const
{
	cout << "usage: " << utilname << " [options] <package>" << endl
	     << "options:" << endl
	     << "  -r, --root <path>   specify alternative installation root" << endl
	     << "  -v, --version       print version and exit" << endl
	     << "  -h, --help          print help and exit" << endl;
}
// vim:set ts=2 :
