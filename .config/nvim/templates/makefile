#**************
# Hayden Coffey
# 
#**************

targets=

all: $(targets)

.PHONY: clean

CC=
CXX=

flags=

cxxFlags=$(shell llvm-config --cxxflags)
ldFlags=$(shell llvm-config --ldflags --libs)

#%.ll: %.cc
#	$(CUSTOM_CC) -o $@ $< -std=c++14 $(cxxFlags) $(flags) -S -emit-llvm -fverbose-asm

#%.o: %.cc
#	$(CUSTOM_CC) -c -o $@ $< -std=c++14 $(cxxFlags) $(flags)
#

#tool.so: tool.o
#	$(CXX) -shared -fPIC -o $@ $< $(cxxFlags) $(ldFlags) $(flags)

#src_dir: export CFLAGS=-DCUSTOM_MACRO
#src_dir:
#	$(MAKE) -C src_dir

#clean:
#	$(MAKE) -C src_dir clean

clean:
	rm *.o *.ll
