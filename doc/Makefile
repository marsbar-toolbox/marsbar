# Makefile for Sphinx documentation

# Octave also seems to work:
# export MATLAB_CMD="octave --eval"
# Make sure m2html is on the path (e.g. with .octaverc).
MATLAB_CMD ?= matlab -nosplash -nodesktop -r

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
PAPER         =

# Internal variables.
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d build/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) source

.PHONY: help clean html dirhtml pickle json htmlhelp qthelp latex changes linkcheck doctest pdf all dist public apidocs apidoc-stamp thing

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  html      to make standalone HTML files"
	@echo "  dirhtml   to make HTML files named index.html in directories"
	@echo "  pickle    to make pickle files"
	@echo "  json      to make JSON files"
	@echo "  htmlhelp  to make HTML files and a HTML help project"
	@echo "  qthelp    to make HTML files and a qthelp project"
	@echo "  latex     to make LaTeX files, you can set PAPER=a4 or PAPER=letter"
	@echo "  pdf       to make <latex> and run the PDF generation"
	@echo "  changes   to make an overview of all changed/added/deprecated items"
	@echo "  linkcheck to check all external links for integrity"
	@echo "  doctest   to run all doctests embedded in the documentation (if enabled)"
	@echo "  gitwash-update update git workflow from source repo"

clean:
	-rm -rf build/* dist apidocs *-stamp tarball

pdf: latex
	cd build/latex && make all-pdf

apidocs: apidocs-stamp

apidocs-stamp:
	cd scripts && $(MATLAB_CMD) "make_apidocs;exit"
	touch $@

all: apidocs html pdf

dist: dist-stamp

distclean: clean dist-stamp

dist-stamp: all
	ln build/latex/*.pdf dist/
	cp -a build/html/* dist/
	echo "Options +Indexes" > dist/apidocs/.htaccess
	mkdir dist/doc-stable
	mkdir dist/doc-devel
	cp dist/apidocs/.htaccess dist/doc-stable
	cp dist/apidocs/.htaccess dist/doc-devel
	ln -s ../apidocs dist/doc-stable/latest
	ln -s ../apidocs dist/doc-devel/latest
	@echo "Build finished.  Final docs are in dist/"
	touch $@

doc-release: dist-stamp
	python scripts/write_doc_release.py dist ../marsbar archives

github-pages:
	echo "See marsbar-toolbox.github.io repository"

html:
	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) build/html
	@echo
	@echo "Build finished. The HTML pages are in build/html."

dirhtml:
	$(SPHINXBUILD) -b dirhtml $(ALLSPHINXOPTS) build/dirhtml
	@echo
	@echo "Build finished. The HTML pages are in build/dirhtml."

pickle:
	$(SPHINXBUILD) -b pickle $(ALLSPHINXOPTS) build/pickle
	@echo
	@echo "Build finished; now you can process the pickle files."

json:
	$(SPHINXBUILD) -b json $(ALLSPHINXOPTS) build/json
	@echo
	@echo "Build finished; now you can process the JSON files."

htmlhelp:
	$(SPHINXBUILD) -b htmlhelp $(ALLSPHINXOPTS) build/htmlhelp
	@echo
	@echo "Build finished; now you can run HTML Help Workshop with the" \
	      ".hhp project file in build/htmlhelp."

qthelp:
	$(SPHINXBUILD) -b qthelp $(ALLSPHINXOPTS) build/qthelp
	@echo
	@echo "Build finished; now you can run "qcollectiongenerator" with the" \
	      ".qhcp project file in build/qthelp, like this:"
	@echo "# qcollectiongenerator build/qthelp/marsbar.qhcp"
	@echo "To view the help file:"
	@echo "# assistant -collectionFile build/qthelp/marsbar.qhc"

latex:
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) build/latex
	@echo
	@echo "Build finished; the LaTeX files are in build/latex."
	@echo "Run \`make all-pdf' or \`make all-ps' in that directory to" \
	      "run these through (pdf)latex."

changes:
	$(SPHINXBUILD) -b changes $(ALLSPHINXOPTS) build/changes
	@echo
	@echo "The overview file is in build/changes."

linkcheck:
	$(SPHINXBUILD) -b linkcheck $(ALLSPHINXOPTS) build/linkcheck
	@echo
	@echo "Link check complete; look for any errors in the above output " \
	      "or in build/linkcheck/output.txt."

doctest:
	$(SPHINXBUILD) -b doctest $(ALLSPHINXOPTS) build/doctest
	@echo "Testing of doctests in the sources finished, look at the " \
	      "results in build/doctest/output.txt."

gitwash-update:
	python scripts/gitwash_dumper.py source/development marsbar --github-user=matthew-brett
