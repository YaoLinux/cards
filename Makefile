#
#  cards
#
#  Copyright (c) 2000-2005 by Per Liden <per@fukt.bth.se>
#  Copyright (c) 2006-2013 by CRUX team (http://crux.nu)
#  Copyright (c) 2013-2014 by NuTyX team (http://nutyx.org)
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
#  USA.
#

DESTDIR =
BINDIR = /bin
MANDIR = /usr/share/man
LIBDIR = /usr/lib
ETCDIR = /etc

VERSION = 0.6.80.4
NAME = cards-$(VERSION)

CXXFLAGS += -DNDEBUG
CXXFLAGS += -O2 -Wall -pedantic -D_GNU_SOURCE -DVERSION=\"$(VERSION)\" \
	    -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fPIC
CFLAGS += -DNDEBUG
CFLAGS += -D_GNU_SOURCE

LIBARCHIVELIBS := $(shell pkg-config --libs --static libarchive)
LIBCURLLIBS := $(shell pkg-config --libs --static libcurl)

LDFLAGS += $(LIBARCHIVELIBS)

TOOLSOBJECTS = tools.o md5.o string_utils.o file_utils.o process.o runtime_dependencies_utils.o pkgdbh.o pkgadd.o pkgrm.o pkginfo.o

CARDSOBJECTS = md5.o string_utils.o config_parser.o file_download.o compile_dependencies_utils.o argument_parser.o cards_argument_parser.o file_utils.o cards_depends.o cards_sync.o cards.o


LIBOBJECTS =  pkgdbh.o pkgadd.o pkgrm.o pkginfo.o

MANPAGES = pkgadd.8 pkgrm.8 pkginfo.8 pkgmk.8 pkgmk.8.fr rejmerge.8 pkgmk.conf.5 pkgmk.conf.5.fr


libs:
	$(CXX) -shared -o libcards.so.$(VERSION)  $(LIBOBJECTS) #-Wl,soname=libcards-$(VERSION)

all: pkgadd cards pkgmk rejmerge man

pkgadd: .tools_depend $(TOOLSOBJECTS)
	$(CXX) $(TOOLSOBJECTS) -o $@ $(LDFLAGS)

pkgmk: pkgmk.in

cards:  .cards_depend $(CARDSOBJECTS)
	$(CXX) $(CARDSOBJECTS) -o $@ $(LDFLAGS) $(LIBCURLLIBS)

rejmerge: rejmerge.in

man: $(MANPAGES)

mantxt: man $(MANPAGES:=.txt)

%.8.txt: %.8
	nroff -mandoc -c $< | col -bx > $@

%: %.in
	sed -e "s/#VERSION#/$(VERSION)/" $< > $@

.tools_depend:
	$(CXX) $(CXXFLAGS) -MM $(TOOLSOBJECTS:.o=.cc) > .tools_depend

.cards_depend:
	$(CXX) $(CXXFLAGS) -MM $(CARDSOBJECTS:.o=.cc) > .cards_depend

ifeq (.cards_depend,$(wildcard .cards_depend))
include .cards_depend
endif

ifeq (.tools_depend,$(wildcard .tools_depend))
include .tools_depend
endif

.PHONY:	install clean distclean dist

dist: distclean
	rm -rf $(NAME) $(NAME).tar.gz
	git archive --format=tar --prefix=$(NAME)/ HEAD | tar -x
	git log > $(NAME)/ChangeLog
	tar czvf $(NAME).tar.gz $(NAME)
	rm -rf $(NAME)

install: all
	install -D -m0755 pkgadd $(DESTDIR)$(BINDIR)/pkgadd
	install -D -m0755 cards $(DESTDIR)$(BINDIR)/cards
	install -D -m0644 pkgadd.conf $(DESTDIR)$(ETCDIR)/pkgadd.conf
	install -D -m0755 pkgmk $(DESTDIR)$(BINDIR)/pkgmk
	install -D -m0755 rejmerge $(DESTDIR)$(BINDIR)/rejmerge
	install -D -m0644 pkgmk.conf $(DESTDIR)$(ETCDIR)/pkgmk.conf
	install -D -m0644 cards.conf $(DESTDIR)$(ETCDIR)/cards.conf
	install -D -m0644 rejmerge.conf $(DESTDIR)$(ETCDIR)/rejmerge.conf
	install -D -m0644 pkgadd.8 $(DESTDIR)$(MANDIR)/man8/pkgadd.8
	install -D -m0644 pkgrm.8 $(DESTDIR)$(MANDIR)/man8/pkgrm.8
	install -D -m0644 pkginfo.8 $(DESTDIR)$(MANDIR)/man8/pkginfo.8
	install -D -m0644 pkgmk.8 $(DESTDIR)$(MANDIR)/man8/pkgmk.8
	install -D -m0644 rejmerge.8 $(DESTDIR)$(MANDIR)/man8/rejmerge.8
	install -D -m0644 pkgmk.conf.5 $(DESTDIR)$(MANDIR)/man5/pkgmk.conf.5
	install -D -m0644 pkgmk.conf.5.fr $(DESTDIR)$(MANDIR)/fr/man5/pkgmk.conf.5
	install -D -m0644 pkgmk.8.fr $(DESTDIR)$(MANDIR)/fr/man8/pkgmk.8
	ln -sf pkgadd $(DESTDIR)$(BINDIR)/pkgrm
	ln -sf pkgadd $(DESTDIR)$(BINDIR)/pkginfo

clean:
	rm -f .tools_depend
	rm -f .cards_depend
	rm -f $(TOOLSOBJECTS)
	rm -f $(CARDSOBJECTS)
	rm -f $(MANPAGES)
	rm -f $(MANPAGES:=.txt)
	rm -f libcards.so.$(VERSION)
	rm -f pkgadd
	rm -f pkgmk
	rm -f pkgcrea
	rm -f cards

distclean: clean
	rm -f pkgadd pkginfo pkgrm pkgmk rejmerge cards

# End of file
