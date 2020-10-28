include platform.mk

LUA_CLIB_PATH ?= luaclib
BIN_PATH ?= bin
LUA_INC ?= 3rd/lua

CFLAGS = -g -O2 -Wall -I$(LUA_INC) $(MYCFLAGS)

LUA_CLIB = lpeg sproto $(TLS_MODULE)
LUA_T = lua

update3rd :
	git submodule update --init

all : \
  $(foreach v, $(LUA_CLIB), $(LUA_CLIB_PATH)/$(v).so) \
  $(foreach v, $(LUA_T), $(BIN_PATH)/$(v)) 

$(LUA_CLIB_PATH) :
	mkdir $(LUA_CLIB_PATH)

$(BIN_PATH) :
	mkdir $(BIN_PATH)

$(BIN_PATH)/lua : | $(BIN_PATH)
	pushd $(LUA_INC) && $(MAKE) CC='$(CC) -std=gnu99 ' $(PLAT) && popd && \
	mv $(LUA_INC)/lua $(BIN_PATH) && \
	mv $(LUA_INC)/luac $(BIN_PATH) && \
	pushd $(LUA_INC) && $(MAKE) clean

$(LUA_CLIB_PATH)/sproto.so : 3rd/sproto/sproto.c 3rd/sproto/lsproto.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I3rd/sproto $^ -o $@ 

$(LUA_CLIB_PATH)/lpeg.so : 3rd/lpeg/lpcap.c 3rd/lpeg/lpcode.c 3rd/lpeg/lpprint.c 3rd/lpeg/lptree.c 3rd/lpeg/lpvm.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I3rd/lpeg $^ -o $@ 

clean :
	rm -f $(LUA_CLIB_PATH)/*.so && \
	rm -f $(BIN_PATH)/*