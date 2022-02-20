#!/usr/bin/make -f
.PHONY: all
all: <mainFileName>

<mainFileName>: %: %.tex
	latexmk -f -pdf $@

.PHONY: clean
clean:
	latexmk -c

.PHONY: cleanall
cleanall:
	latexmk -C
