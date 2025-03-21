# Compiler options.
CC = gcc
WINDRES=windres

CFLAGS=-m32
LFLAGS=-m32 -no-pie -ldl

ifeq ($(OS),Windows_NT)
LLIBS=-static -mwindows -lstdc++ -lws2_32 -lwinmm
else
LLIBS=-lm -lpthread -lstdc++
endif

# Setup binary names.
ifeq ($(OS),Windows_NT)
BIN_NAME=cod2rev_win32
LIB_NAME=libcod2rev
BIN_EXT=.exe
LIB_EXT=.dll
else
BIN_NAME=cod2rev_lnxded
LIB_NAME=libcod2rev
BIN_EXT=
LIB_EXT=.so
endif

# Setup directory names.
BIN_DIR=bin
OBJ_DIR=obj
SRC_DIR=src

LINUX_DIR=$(SRC_DIR)/unix
WIN32_DIR=$(SRC_DIR)/win32
ZLIB_DIR=$(SRC_DIR)/zlib

# Source dirs
BGAME_DIR=$(SRC_DIR)/bgame
GAME_DIR=$(SRC_DIR)/game
QCOMMON_DIR=$(SRC_DIR)/qcommon
SCR_DIR=$(SRC_DIR)/script
SERVER_DIR=$(SRC_DIR)/server
STRINGED_DIR=$(SRC_DIR)/stringed
UNIVERSAL_DIR=$(SRC_DIR)/universal
XANIM_DIR=$(SRC_DIR)/xanim

# Libcod stuff
WITH_LIBCOD=true
WITH_MYSQL=false
WITH_SQLITE=true

ifeq ($(WITH_LIBCOD),true)
LIBCOD_SETTINGS=-D LIBCOD
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_BOTS=1
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_ENTITY=1
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_EXEC=1
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_LEVEL=1
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_MEMORY=1
ifeq ($(WITH_MYSQL),true)
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_MYSQL=1
endif
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_PLAYER=1
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_RATELIMITER=1
ifeq ($(WITH_SQLITE),true)
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_SQLITE=1
endif
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_UTILS=1
LIBCOD_SETTINGS+=-D LIBCOD_COMPILE_WEAPONS=1
endif

ifeq ($(WITH_LIBCOD),true)
ifeq ($(WITH_MYSQL),true)
ifeq ($(OS),Windows_NT)
MYSQL_COPY_CMD=xcopy $(SRC_DIR)\libcod\mysql\windows\lib\libmysql.dll $(BIN_DIR) /Y
LLIBS+=$(SRC_DIR)/libcod/mysql/windows/lib/libmysql.lib
else
LLIBS+=-lmysqlclient -L$(SRC_DIR)/libcod/mysql/unix/lib
endif
endif
LIBCOD_DIR=$(SRC_DIR)/libcod
LIBCOD_SOURCES=$(wildcard $(LIBCOD_DIR)/*.cpp)
LIBCOD_OBJ=$(patsubst $(LIBCOD_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(LIBCOD_SOURCES))
ifeq ($(WITH_SQLITE),true)
SQLITE_DIR=$(SRC_DIR)/libcod/sqlite
SQLITE_SOURCES=$(wildcard $(SQLITE_DIR)/*.c)
SQLITE_OBJ=$(patsubst $(SQLITE_DIR)/%.c,$(OBJ_DIR)/%.o,$(SQLITE_SOURCES))
endif
endif

# Target files
TARGET=$(addprefix $(BIN_DIR)/,$(BIN_NAME)$(BIN_EXT))

# C files
BGAME_SOURCES=$(wildcard $(BGAME_DIR)/*.cpp)
GAME_SOURCES=$(wildcard $(GAME_DIR)/*.cpp)
QCOMMON_SOURCES=$(wildcard $(QCOMMON_DIR)/*.cpp)
SCR_SOURCES=$(wildcard $(SCR_DIR)/*.cpp)
SERVER_SOURCES=$(wildcard $(SERVER_DIR)/*.cpp)
STRINGED_SOURCES=$(wildcard $(STRINGED_DIR)/*.cpp)
UNIVERSAL_SOURCES=$(wildcard $(UNIVERSAL_DIR)/*.cpp)
XANIM_SOURCES=$(wildcard $(XANIM_DIR)/*.cpp)
LINUX_SOURCES=$(wildcard $(LINUX_DIR)/*.cpp)
WIN32_SOURCES=$(wildcard $(WIN32_DIR)/*.cpp)
WIN32_RESOURCES=$(wildcard $(WIN32_DIR)/*.rc)
ZLIB_SOURCES=$(wildcard $(ZLIB_DIR)/*.c)

# Object files.
BGAME_OBJ=$(patsubst $(BGAME_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(BGAME_SOURCES))
GAME_OBJ=$(patsubst $(GAME_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(GAME_SOURCES))
QCOMMON_OBJ=$(patsubst $(QCOMMON_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(QCOMMON_SOURCES))
SCR_OBJ=$(patsubst $(SCR_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SCR_SOURCES))
SERVER_OBJ=$(patsubst $(SERVER_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SERVER_SOURCES))
STRINGED_OBJ=$(patsubst $(STRINGED_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(STRINGED_SOURCES))
UNIVERSAL_OBJ=$(patsubst $(UNIVERSAL_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(UNIVERSAL_SOURCES))
XANIM_OBJ=$(patsubst $(XANIM_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(XANIM_SOURCES))

# Platform specific lists
ifeq ($(OS),Windows_NT)
WIN32_OBJ=$(patsubst $(WIN32_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(WIN32_SOURCES))
WIN32_RES_OBJ=$(patsubst $(WIN32_DIR)/%.rc,$(OBJ_DIR)/%.res,$(WIN32_RESOURCES))
else
LINUX_OBJ=$(patsubst $(LINUX_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(LINUX_SOURCES))
endif
ZLIB_OBJ=$(patsubst $(ZLIB_DIR)/%.c,$(OBJ_DIR)/%.o,$(ZLIB_SOURCES))


# Default rule.
cod2rev: mkdir $(TARGET)
    $(TARGET): \
	$(BGAME_OBJ) $(GAME_OBJ) $(QCOMMON_OBJ) $(SCR_OBJ) $(SERVER_OBJ) $(STRINGED_OBJ) $(UNIVERSAL_OBJ) $(XANIM_OBJ) \
	$(LINUX_OBJ) $(WIN32_OBJ) $(WIN32_RES_OBJ) $(ZLIB_OBJ) $(LIBCOD_OBJ) $(SQLITE_OBJ)
	$(CC) $(LFLAGS) -o $@ $^ $(LLIBS)

ifeq ($(OS),Windows_NT)
mkdir:
	if not exist $(BIN_DIR) md $(BIN_DIR)
	if not exist $(OBJ_DIR) md $(OBJ_DIR)
	$(MYSQL_COPY_CMD)
else
mkdir:
	mkdir -p $(BIN_DIR)
	mkdir -p $(OBJ_DIR)
endif


# Build C sources


# A rule to build bgame source code.
$(OBJ_DIR)/%.o: $(BGAME_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) $(LIBCOD_SETTINGS) -o $@ $<

# A rule to build script source code.
$(OBJ_DIR)/%.o: $(SCR_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) $(LIBCOD_SETTINGS) -o $@ $<

# A rule to build game source code.
$(OBJ_DIR)/%.o: $(GAME_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) $(LIBCOD_SETTINGS) -o $@ $<

# A rule to build qcommon source code.
$(OBJ_DIR)/%.o: $(QCOMMON_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) $(LIBCOD_SETTINGS) -o $@ $<

# A rule to build server source code.
$(OBJ_DIR)/%.o: $(SERVER_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) $(LIBCOD_SETTINGS) -o $@ $<

# A rule to build stringed source code.
$(OBJ_DIR)/%.o: $(STRINGED_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) $(LIBCOD_SETTINGS) -o $@ $<

# A rule to build universal source code.
$(OBJ_DIR)/%.o: $(UNIVERSAL_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) $(LIBCOD_SETTINGS) -o $@ $<

# A rule to build xanim source code.
$(OBJ_DIR)/%.o: $(XANIM_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) $(LIBCOD_SETTINGS) -o $@ $<

# A rule to build linux source code.
$(OBJ_DIR)/%.o: $(LINUX_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) -o $@ $<

# A rule to build win32 source code.
$(OBJ_DIR)/%.o: $(WIN32_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) -o $@ $<

# A rule to build win32 resource files.
$(OBJ_DIR)/%.res: $(WIN32_DIR)/%.rc
	@echo $(WINDRES)  $@
	@$(WINDRES) -i $< -O coff $@

# A rule to build zlib source code.
$(OBJ_DIR)/%.o: $(ZLIB_DIR)/%.c
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) -o $@ $<

# A rule to build libcod source code.
$(OBJ_DIR)/%.o: $(LIBCOD_DIR)/%.cpp
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) $(LIBCOD_SETTINGS) -o $@ $<

# A rule to build sqlite source code.
$(OBJ_DIR)/%.o: $(SQLITE_DIR)/%.c
	@echo $(CC)  $@
	@$(CC) -c $(CFLAGS) -o $@ $<


# Cleanup


ifeq ($(OS),Windows_NT)
clean:
	del /Q /S "$(BIN_DIR)\$(BIN_NAME)$(BIN_EXT)"
	del /Q /S "$(BIN_DIR)\$(LIB_NAME)$(LIB_EXT)"
	del /Q /S "$(BIN_DIR)\libmysql.dll"
	del /Q /S "$(OBJ_DIR)\*.o"
	del /Q /S "$(OBJ_DIR)\*.res"
else
clean:
	rm -f $(BIN_DIR)/$(BIN_NAME)$(BIN_EXT)
	rm -f $(BIN_DIR)/$(LIB_NAME)$(LIB_EXT)
	rm -f $(OBJ_DIR)/*.o
endif
