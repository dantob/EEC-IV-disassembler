PROGNAME    =SADX
CXX         =/usr/bin/g++
CXXWIN      =/usr/bin/x86_64-w64-mingw32-g++
CXXWIN32    =/usr/bin/i686-w64-mingw32-g++

CXXFLAGS    =-pipe -std=c++11 -fstack-protector-strong -fno-plt -fPIE -D_FORTIFY_SOURCE=2
CXXFLAGS64  =-m64 -march=x86-64 -mtune=generic
CXXFLAGS32  =-m32 -march=i386 -mtune=generic
WARNINGS    =-Wpedantic -Wall -Wextra -Wformat-security
HIDE        =-Wno-maybe-uninitialized -Wno-unused-parameter -Wno-type-limits -Wno-unused-but-set-variable -Wno-unused-result #remove as they get fixed
DEBUG       =-Og -ggdb #-0g or any optimization other than -O0 breaks 4.0.4 and 4.0.5, fixed with 4.0.6
ASAN        =-fsanitize=address,undefined,leak
GCOV        =-fprofile-arcs -ftest-coverage
OPTIMIZE    =-O2 -flto
MSWIN       =-static
GCC10       =-fstack-clash-protection -fanalyzer -Wno-analyzer-file-leak -Wno-analyzer-null-dereference

SRCDIR      =./source
VERSION     =4.0.6
SRC         =$(SRCDIR)/$(VERSION)/*.h $(SRCDIR)/$(VERSION)/*.cpp
UISRC       =$(SRCDIR)/SADWin/W32_main.cpp

all: $(PROGNAME)_$(VERSION).Og

lin: $(PROGNAME)_$(VERSION).bin #$(PROGNAME)32_$(VERSION).bin 

win: $(PROGNAME)32_$(VERSION).exe #wingui #$(PROGNAME)_$(VERSION).exe

wingui: $(PROGNAME)32_WINGUI.exe

$(PROGNAME)_$(VERSION).Og: $(SRC)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(CXXFLAGS64) $(WARNINGS) $(HIDE) $(DEBUG) #$(GCC10) #$(ASAN) #$(GCOV)
	objcopy --only-keep-debug $@ $@.debug
	objcopy --strip-unneeded $@
	objcopy --add-gnu-debuglink=$@.debug $@

$(PROGNAME)_$(VERSION).bin: $(SRC)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(CXXFLAGS64) $(WARNINGS) $(HIDE) $(OPTIMIZE)
	objcopy --strip-unneeded $@

$(PROGNAME)32_$(VERSION).bin: $(SRC)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(CXXFLAGS32) $(WARNINGS) $(HIDE) $(OPTIMIZE)
	objcopy --strip-unneeded $@

$(PROGNAME)_$(VERSION).exe: $(SRC)
	$(CXXWIN) -o $@ $^ $(CXXFLAGS) $(CXXFLAGS64) $(WARNINGS) $(HIDE) $(OPTIMIZE) $(MSWIN) -fpermissive #hack
	objcopy --strip-unneeded $@

$(PROGNAME)32_$(VERSION).exe: $(SRC)
	$(CXXWIN32) -o $@ $^ $(CXXFLAGS) $(CXXFLAGS32) $(WARNINGS) $(HIDE) $(OPTIMIZE) $(MSWIN)
	objcopy --strip-unneeded $@

$(PROGNAME)32_WINGUI.exe: $(UISRC)
	$(CXXWIN32) -o $@ $^ $(CXXFLAGS) $(CXXFLAGS32) $(WARNINGS) $(OPTIMIZE) $(MSWIN) -lcomdlg32 -Wno-unused-parameter -Wno-pedantic -Wno-missing-field-initializers #hack
	objcopy --strip-unneeded $@

clean:
	rm -vf $(PROGNAME)* *.gcno

#compress executable
upx:
	upx -q $(PROGNAME)*

#coverage testing
gcovr:
	gcovr --html-details --html-title $(PROGNAME) -o summary.html -s

clean_gcov:
	rm -vf *.gcda *.gcov *.cpp.html summary.html

#aditional static code analysis
cppcheck:
	cppcheck --template=gcc $(SRCDIR)

