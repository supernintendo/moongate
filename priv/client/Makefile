BIN_DIR=bin/
HEADER_DIR=include/
SRC_DIR=src/
PRE_JS=--pre-js js/browser/prefix.js
POST_JS=--post-js js/browser/postfix.js


all: javascript

javascript:
	emcc --bind $(PRE_JS) $(POST_JS) -o $(BIN_DIR)/moongate.js -I $(HEADER_DIR) $(SRC_DIR)/moongate.cpp
