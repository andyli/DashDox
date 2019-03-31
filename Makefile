HAXE_DOC_VERSION=3.4.7
DOCSET=Haxe.docset
OUT_DIR=out
OUT_ARCHIVE=haxe.tgz
OUT_XML=haxe.xml
OUT_ARCHIVE_SHA1=$(shell openssl dgst -sha1 -binary "$(OUT_DIR)/$(OUT_ARCHIVE)" | xxd -p)
ARCHIVE_HOST=https://andyli.github.io/DashDox

all: $(OUT_DIR)/$(OUT_ARCHIVE) $(OUT_DIR)/$(OUT_XML)

.haxelib:
	haxelib newrepo
	haxelib install build.hxml --always

Main.n: build.hxml src/Main.hx .haxelib
	haxe build.hxml

xml:
	git clone --depth=1 --branch=master --single-branch https://github.com/HaxeFoundation/api.haxe.org.git api
	mv api/xml/$(HAXE_DOC_VERSION) xml
	rm -rf api

html:
	git clone --depth=1 --branch=gh-pages --single-branch https://github.com/HaxeFoundation/api.haxe.org.git api
	mv api/v/$(HAXE_DOC_VERSION) html
	rm -rf api

$(DOCSET): Main.n html xml
	neko Main.n -name Haxe -html-doc html -xml-doc xml -icon haxe.png -out . -clean

$(OUT_DIR)/$(OUT_ARCHIVE): $(DOCSET)
	tar -czf "$(OUT_DIR)/$(OUT_ARCHIVE)" "$(DOCSET)"

$(OUT_DIR)/$(OUT_XML): $(OUT_DIR)/$(OUT_ARCHIVE)
	echo "<entry>" 										>>"$(OUT_DIR)/$(OUT_XML)"
	echo "<version>$(HAXE_DOC_VERSION)</version>" 		>>"$(OUT_DIR)/$(OUT_XML)"
	echo "<sha1>$(OUT_ARCHIVE_SHA1)</sha1>" 			>>"$(OUT_DIR)/$(OUT_XML)"
	echo "<url>$(ARCHIVE_HOST)/$(OUT_ARCHIVE)</url>" 	>>"$(OUT_DIR)/$(OUT_XML)"
	echo "<head/>" 										>>"$(OUT_DIR)/$(OUT_XML)"
	echo "</entry>" 									>>"$(OUT_DIR)/$(OUT_XML)"

.PHONY: clean
clean:
	rm -f $(OUT_DIR)/$(OUT_ARCHIVE) $(OUT_DIR)/$(OUT_XML)
	rm -rf $(DOCSET)
	rm -rf xml html api
	rm -f Main.n
	rm -rf .haxelib

.PHONY: deploy
deploy: all
	haxe deploy.hxml