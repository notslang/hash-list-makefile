SHELL:=/bin/bash
TMP_DIR := /data/tmp/hashlist
UPLOAD_DIR := /data/tmp/uploadlist
OUT_DIR := ./torrent-hash-lists

$(TMP_DIR)/%: ./%.warc.gz
	mkdir -p '$(dir $@)'
	gzip --decompress < "$<" \
	| cat -v \
	| grep -i --perl-regexp --only-matching '(?<![0-9A-F])[0-9A-F]{40}(?![0-9A-F])' \
	| awk '{print toupper($$0)}' \
	| sort -u \
	> "$@"

$(TMP_DIR)/%: ./%
	mkdir -p '$(dir $@)'
	cat -v "$<" \
	| grep -i --extended-regexp --only-matching "[0-9A-F]{40}" \
	| awk '{print toupper($$0)}' \
	| sort -u \
	> "$@"

$(OUT_DIR)/bitsnoop: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./dump-bitsnoop.com/*))
	sort -u --merge $^ > "$@"

$(OUT_DIR)/demonoid: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./dump-demonoid/*))
	find $(TMP_DIR)/dump-demonoid -type f -exec cat {} + | sort -u  > "$@"

$(OUT_DIR)/extratorrent.cc: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./rss-extratorrent.cc/*))
	find $(TMP_DIR)/rss-extratorrent.cc -type f -exec cat {} + | sort -u  > "$@"

$(OUT_DIR)/idope.se: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./dump-idope.se/*))
	find $(TMP_DIR)/dump-idope.se -type f -exec cat {} + | sort -u  > "$@"

$(OUT_DIR)/isohunt: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./rss-isohunt/*))
	find $(TMP_DIR)/rss-isohunt -type f -exec cat {} + | sort -u  > "$@"

$(OUT_DIR)/kat: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./dump-kat/*))
	sort -u --merge $^ > "$@"

$(OUT_DIR)/limetorrents: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./rss-limetorrents/*))
	find $(TMP_DIR)/rss-limetorrents -type f -exec cat {} + | sort -u  > "$@"

$(OUT_DIR)/p2pspider: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./log-p2pspider/*.json))
	sort -u --merge $^ > "$@"

$(OUT_DIR)/pirateiro.com: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./dump-pirateiro.com/*))
	find $(TMP_DIR)/dump-pirateiro.com -type f -exec cat {} + | sort -u  > "$@"

$(OUT_DIR)/tokyotosho.info: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./rss-tokyotosho.info/*))
	find $(TMP_DIR)/rss-tokyotosho.info -type f -exec cat {} + | sort -u  > "$@"

$(OUT_DIR)/torrage.com: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./dump-torrage.com/*.txt))
	sort -u --merge $^ > "$@"

$(OUT_DIR)/torrentproject.se: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./dump-torrentproject.se/*))
	sort -u --merge $^ > "$@"

$(OUT_DIR)/zibri: $(patsubst ./%, $(TMP_DIR)/%, $(wildcard ./dump-zibri/*))
	sort -u --merge $^ > "$@"

$(OUT_DIR)/grab-site-torrent-scrape: $(patsubst ./%.warc.gz, $(TMP_DIR)/%, $(wildcard ./grab-site-torrent-scrape/**/*.warc.gz))
	sort -u --merge $^ > "$@"

$(OUT_DIR)/downloaded:
	find ./torrent-files/itorrents.org -type f \
	| grep --extended-regexp --only-matching "[0-9A-F]{40}" \
	| sort -u \
	> "$@"

$(OUT_DIR)/all: SHELL:=/bin/bash
$(OUT_DIR)/all: $(OUT_DIR)/bitsnoop $(OUT_DIR)/demonoid $(OUT_DIR)/downloaded $(OUT_DIR)/engiy.com $(OUT_DIR)/extratorrent.cc $(OUT_DIR)/grab-site-torrent-scrape $(OUT_DIR)/hashes-from-somewhere $(OUT_DIR)/idope.se $(OUT_DIR)/isohunt $(OUT_DIR)/kat $(OUT_DIR)/limetorrents $(OUT_DIR)/p2pspider $(OUT_DIR)/pirateiro.com $(OUT_DIR)/tokyotosho.info $(OUT_DIR)/torcache $(OUT_DIR)/torrage.com $(OUT_DIR)/torrentproject.se $(OUT_DIR)/torrents-mini-hash-list $(OUT_DIR)/torrentz-hashes $(OUT_DIR)/torrentz.eu-archive.org-hashes $(OUT_DIR)/torrentz2.eu $(OUT_DIR)/unique-to-tpb $(OUT_DIR)/zibri
	sort -u --merge $^ > $@
	comm -23 $@ $(OUT_DIR)/downloaded \
	| comm -23 - <(sort -u --merge $(UPLOAD_DIR)/*) \
	> "$(UPLOAD_DIR)/$(shell date +%Y-%m-%d-%H-%M-%S)"
