# ======================================================== #
# ---------------------- Variables ----------------------- #
# ======================================================== #

.PHONY = all buildAuxDirectories pruneEmptyAuxDirectories clean nuke

MAIN_FILE = main
AUX_DIR = .aux

CLEAN_EXTS = *.aux *.bcf *.fls *.idx *.ind *.lof *.lot *.out *.toc *.blg *.ilg *.log *.xdv *.run.xml *.fdb_latexmk *.bbl *.deps
NUKE_EXTS =  *.pdf *.synctex *.synctex.gz *.synctex.gz\(busy\) *.synctex\(busy\)
CLEAN_FILES =

LATEXMK = 	latexmk\
			-lualatex\
			-interaction=nonstopmode\
			-f\
			-bibtex-cond1\
			-bibtexfudge\
			-makeindexfudge\
			-emulate-aux-dir\
			-auxdir=$(AUX_DIR)\
			-M\
			-MP\
			-synctex=1\
			-file-line-error\
			-rc-report-\
			-norc\
			-logfilewarninglist

# ======================================================== #
# --------------------- Main Recipe ---------------------- #
# ======================================================== #

all: $(MAIN_FILE).pdf

$(foreach file, $(MAIN_FILE), $(eval -include $(AUX_DIR)/$(file).deps))

$(MAIN_FILE).pdf: $(MAIN_FILE).tex
	@$(MAKE) --quiet buildAuxDirectories
	@$(LATEXMK) -MF $(AUX_DIR)/$(basename $@).deps $<
	@$(MAKE) --quiet pruneEmptyAuxDirectories

# ======================================================== #
# ------------------ Aux-Dir Recipes --------------------- #
# ======================================================== #

buildAuxDirectories: pruneEmptyAuxDirectories
	@rsync -qav -f"- .*/" -f"+ */" -f"- *" "." "$(AUX_DIR)"

pruneEmptyAuxDirectories:
	@if [ -d $(AUX_DIR) ]; then find ./$(AUX_DIR)/ -type d -empty -delete; fi

# ======================================================== #
# ------------------ Cleaning Recipes -------------------- #
# ======================================================== #

clean:
	@for ext in $(CLEAN_EXTS) $(CLEAN_FILES); do \
		find ./ -maxdepth 1 -type f -name $$ext -delete; \
		if [ -d $(AUX_DIR) ]; then \
			find ./$(AUX_DIR)/ -type f -name $$ext -delete; \
		fi; \
	done
	@$(MAKE) --quiet pruneEmptyAuxDirectories

nuke:
	@for ext in $(CLEAN_EXTS) $(CLEAN_FILES) $(NUKE_EXTS); do \
		find ./ -maxdepth 1 -type f -name $$ext -delete; \
		if [ -d $(AUX_DIR) ]; then \
			find ./$(AUX_DIR)/ -type f -name $$ext -delete; \
		fi; \
	done
	@$(MAKE) --quiet pruneEmptyAuxDirectories