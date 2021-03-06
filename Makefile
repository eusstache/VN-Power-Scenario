# Assessment of CCS scenario for Vietnam with power development model
#
# (c) Minh Ha-Duong, An Ha Truong 2016, 2017
# minh.haduong@gmail.com
# Creative Commons Attribution-ShareAlike 4.0 International
#

PYTHON = python3


tables = table-parameters.fwf table-comparison.fwf

figures = plan_baseline.pdf plan_withCCS.pdf figure-capacities.pdf figure-capacities.png


all-parallel:
	make all -j

all: $(tables) $(figures)

table-parameters.fwf: param_reference.txt
	head -13 $< | tail -11 > $@

table-comparison.fwf: Run.txt
	head -26 $< | tail -16 > $@

%.txt: %.py
	@-sed -i "s/VERBOSE = True/VERBOSE = False/" init.py
	$(PYTHON) $< summarize > $@

%.pdf: %.py
	$(PYTHON) $< plot $@

%.png: %.py
	$(PYTHON) $< plot $@

test: cleaner
	py.test-3 --doctest-modules

coverage: coverage.xml
	python3.5-coverage html
	see htmlcov/index.html

coverage.xml:
	py.test-3 --doctest-modules --cov=. --cov-report term-missing --cov-report xml

regtest-reset:
	py.test-3 --regtest-reset

lint:
	pylint3 *py

docstyle:
	# Ignored messages:
	# D102: Missing docstring in public method                              too many positives
	# D105: Missing docstring in magic method                               why does it need a docstring ?
	# D203: 1 blank line required before class docstring                    bug in the tool
	# D213: Multi-line docstring summary should start at the second line    """We choose D212 ;)
	pydocstyle --ignore=D102,D105,D203,D213 *py

codestyle:
	pycodestyle *py

.PHONY: test regtest-reset lint docstyle codestyle clean cleaner


clean:
	rm -f $(tables)
	rm -f $(figures)

cleaner: clean
	find . -type f -name '*.pyc' -delete
	rm -f Run.txt param_reference.txt 
	rm -rf __pycache__
	rm -f *.bak
	rm -rf .coverage coverage.xml htmlcov
