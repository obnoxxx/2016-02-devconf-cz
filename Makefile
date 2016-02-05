TARGET_BASE_NAME := $(shell cat BASENAME)

TARGET_PR = $(TARGET_BASE_NAME).pr
TARGET_HO = $(TARGET_BASE_NAME).ho
TARGET_HO2 = $(TARGET_BASE_NAME).ho2

TARGET = $(TARGET_BASE_NAME)

# IMAGE_MC_V1 = smb3-mc-samba
# IMAGE_MC_V2 = smb3-mc-samba-v2
# IMAGE_MC_DAEMONS_N1 = smb3-mc-daemons-n1
# IMAGE_MC_DAEMONS_N1A = smb3-mc-daemons-n1a
# IMAGE_MC_DAEMONS_N2 = smb3-mc-daemons-n2
# IMAGE_MC_DAEMONS_N3 = smb3-mc-daemons-n3
# IMAGE_RDMA_V2 = smb3-rdma-samba-v2
IMAGE_CTDB_3N = design-ctdb-three-nodes
IMAGE_CTDB_DAEMONS = ctdb-design-daemons
IMAGE_SAMBA_LAYERS = samba-layers
IMAGE_CTDB_3N_WITNESS = design-ctdb-three-nodes-with-witness
IMAGE_SAMBA_DAEMONS_P1 = samba-daemons-vfs-p1
IMAGE_SAMBA_DAEMONS_P2 = samba-daemons-vfs-p2
IMAGE_SAMBA_DAEMONS_P3 = samba-daemons-vfs-p3
IMAGE_SAMBA_DAEMONS_P4 = samba-daemons-vfs-p4
# IMAGE_SAMBA_RELEASES = samba-release-stream
# 
# DIAIMAGES_BASE := $(IMAGE_MC_V1) \
# 		  $(IMAGE_MC_V2) \
# 		  $(IMAGE_MC_DAEMONS_N1) \
# 		  $(IMAGE_MC_DAEMONS_N1A) \
# 		  $(IMAGE_MC_DAEMONS_N2) \
# 		  $(IMAGE_MC_DAEMONS_N3) \
# 		  $(IMAGE_RDMA_V2) \
# 		  $(IMAGE_CTDB_3N) \
# 		  $(IMAGE_CTDB_DAEMONS) \
# 		  $(IMAGE_SAMBA_LAYERS) \
# 		  $(IMAGE_SAMBA_RELEASES)

DIAIMAGES_BASE := \
		  $(IMAGE_CTDB_3N) \
		  $(IMAGE_CTDB_3N_WITNESS) \
		  $(IMAGE_CTDB_DAEMONS) \
		  $(IMAGE_SAMBA_LAYERS) \
		  $(IMAGE_SAMBA_DAEMONS_P1) \
		  $(IMAGE_SAMBA_DAEMONS_P2) \
		  $(IMAGE_SAMBA_DAEMONS_P3) \
		  $(IMAGE_SAMBA_DAEMONS_P4)


DIAIMAGES :=     $(foreach image, $(DIAIMAGES_BASE), $(image).dia)
DIAIMAGES_PNG := $(foreach image, $(DIAIMAGES_BASE), $(image).png)
DIAIMAGES_SVG := $(foreach image, $(DIAIMAGES_BASE), $(image).svg)
DIAIMAGES_FIG := $(foreach image, $(DIAIMAGES_BASE), $(image).fig)

#IMAGES = $(DIAIMAGES_PNG) \
#	 regedit.png \
#	 ctdb-status.png \
#	 ctdb-status-1.png \
#	 ctdb-ip.png \
#	 ctdb-ip-1.png \
#	 smbstatus.png

IMAGES = $(DIAIMAGES_PNG)


EXTRA_WIKI_FILES = \
		   intro-history.wiki \
		   clustering-ctdb.wiki \
		   smb3.wiki


CMN_DEPS = Makefile $(IMAGES)

CMN_DEPS_WIKI = $(CMN_DEPS) document.part1.wiki document.part2.wiki document.part3.wiki content.wiki info.wiki

CMN_DEPS_TEX = $(CMN_DEPS) beamercolorthemeobnoxsamba.sty beamerouterthemeobnoxinfolines.sty beamerthemeObnoxSamba.sty

CONTENT_DEPS_WIKI = $(CMN_DEPS) content.wiki $(EXTRA_WIKI_FILES)

COMMON_DEPS = $(CMN_DEPS)

VIEWER = evince
SHOW = yes

.SUFFIXES: .tex .pdf .dia .png .fig .svg .wiki

.PHONY: all

all: pr


.PHONY: pr $(TARGET_PR)

pr: $(TARGET_PR)

$(TARGET_PR): $(TARGET_PR).pdf
	if [ "$(SHOW)" = "yes" ]; then $(VIEWER) $@.pdf ; fi &

$(TARGET_PR).pdf: $(CMN_DEPS) pr.pdf
	cp pr.pdf $@

pr.pdf: $(CMN_DEPS_TEX) pr.tex

pr.tex: pr.wiki $(CONTENT_DEPS_WIKI)

pr.wiki: $(CMN_DEPS_WIKI) pr.class.wiki
	cat document.part1.wiki pr.class.wiki document.part2.wiki info.wiki document.part3.wiki > $@


.PHONY: ho $(TARGET_HO)

ho: $(TARGET_HO)

$(TARGET_HO): $(TARGET_HO).pdf
	if [ "$(SHOW)" = "yes" ]; then $(VIEWER) $@.pdf ; fi &

$(TARGET_HO).pdf: $(CMN_DEPS) ho.pdf
	cp ho.pdf $@

ho.pdf: $(CMN_DEPS_TEX) ho.tex

ho.tex: ho.wiki $(CONTENT_DEPS_WIKI)

ho.wiki: $(CMN_DEPS_WIKI) ho.class.wiki
	cat document.part1.wiki ho.class.wiki document.part2.wiki info.wiki document.part3.wiki > $@


.PHONY: ho2 $(TARGET_HO2)

ho2: $(TARGET_HO2)

$(TARGET_HO2): $(TARGET_HO2).pdf
	if [ "$(SHOW)" = "yes" ]; then $(VIEWER) $@.pdf ; fi &

$(TARGET_HO2).pdf: $(CMN_DEPS) ho2.pdf
	cp ho2.pdf $@

ho2.pdf: $(CMN_DEPS_TEX) ho2.tex

ho2.tex: ho2.wiki $(CONTENT_DEPS_WIKI)

ho2.wiki: $(CMN_DEPS_WIKI) ho2.class.wiki
	cat document.part1.wiki ho2.class.wiki document.part2.wiki info.wiki document.part3.wiki > $@



.wiki.tex:
	wiki2beamer $< > $@

.tex.pdf:
	pdflatex $<
	pdflatex $<
	#if [ "$(SHOW)" = "yes" ]; then $(VIEWER) $@ ; fi &

.dia.png:
	@dia -e $@ -s x1280 $<

.dia.fig:
	@dia -e $@ $<

.dia.svg:
	@dia -e $@ $<


.PHONY: png fig svg images

png: $(DIAIMAGES_PNG)

fig: $(DIAIMAGES_FIG)

svg: $(DIAIMAGES_SVG)

images: $(IMAGES)


.PHONY: archive

archive: $(TARGET).tar.gz

$(TARGET).tar.gz: $(TARGET).tar
	@echo "Creating $@"
	@rm -f $(TARGET).tar.gz
	@gzip $(TARGET).tar


# make $(TARGET).tar phony - it vanishes by gzipping...
.PHONY: $(TARGET).tar

$(TARGET).tar: pr ho ho2
	@echo "Creating $@"
	@git archive --prefix=$(TARGET)/ HEAD > $@
	@rm -rf $(TARGET)
	@mkdir $(TARGET)
	@cp $(TARGET_PR).pdf $(TARGET)
	@cp $(TARGET_HO).pdf $(TARGET)
	@cp $(TARGET_HO2).pdf $(TARGET)
	@tar rf $@ $(TARGET)/$(TARGET_PR).pdf
	@tar rf $@ $(TARGET)/$(TARGET_HO).pdf
	@tar rf $@ $(TARGET)/$(TARGET_HO2).pdf



.PHONY: clean

clean:
	@git clean -f
