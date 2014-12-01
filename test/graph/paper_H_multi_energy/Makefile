# Copyright (C) 2009-2012 Derek Bruening <iye@alum.mit.edu>
# http://www.burningcutlery.com/derek/bargraph/
# http://code.google.com/p/bargraphgen/

OUTDIR := ../build_H_multi_energy

BARGRAPH := ../bargraph_H_multi_energy.pl

SIZE := 700

SRCS := $(wildcard *.g)
OBJS := $(patsubst %.g,$(OUTDIR)/%.pdf,$(SRCS))

all: mkoutdir $(OBJS)

mkoutdir:
	@(if ! test -e $(OUTDIR); then mkdir -p $(OUTDIR); fi)

%.png: %.ppm
	mogrify -reverse -flatten $<
	mogrify -resize ${SIZE}x${SIZE} -format png $<
$(OUTDIR)/%.ppm: %.g $(BARGRAPH)
	$(BARGRAPH) -fig $< | fig2dev -L ppm -m 4 > $@
$(OUTDIR)/%.eps: %.g $(BARGRAPH)
	$(BARGRAPH) -eps $< > $@
$(OUTDIR)/%.pdf: %.g $(BARGRAPH)
	$(BARGRAPH) -pdf $< > $@

clean:
	-rm $(OBJS)
