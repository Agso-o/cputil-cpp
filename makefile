PROJECT := cputil

CXX      := g++
CXXFLAGS := -O2 -std=c++17

PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib/$(PROJECT)

GEN_SRC := src/genrand-tc.cpp
GEN_BIN := genrand-tc
SCRIPT  := scripts/cputil.sh

.PHONY: all build install uninstall clean

all: build

build:
	$(CXX) $(CXXFLAGS) $(GEN_SRC) -o $(GEN_BIN)

install: build
	install -Dm755 $(SCRIPT)  $(DESTDIR)$(BINDIR)/$(PROJECT)
	install -Dm755 $(GEN_BIN) $(DESTDIR)$(LIBDIR)/$(GEN_BIN)

uninstall:
	rm -f  $(DESTDIR)$(BINDIR)/$(PROJECT)
	rm -rf $(DESTDIR)$(LIBDIR)

clean:
	rm -f $(GEN_BIN)

