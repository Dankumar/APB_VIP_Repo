# cleaning the temporary file generated
# like .log licence files dump etc.

CLEAN = clean
VLIB = verilog_lib
VSIM = vsim_cmd

TOP_NAME = apb_top
COVERAGE = -coverage
ASSERTCOVERAGE = -assertcover
COVERAGE_DATABASE = coverage_database
UVM_VERBOSITY	= "UVM_MEDIUM"
UVM_OPT 	= +UVM_VERBOSITY=${UVM_VERBOSITY}
UVM_TEST_NAME = +UVM_TESTNAME=apb_base_test
UVM_DEPRICATED = +define+UVM+UVM_NO_DEPRECATED
UVM_AWARE_DEBUG = -classdebug \
		  -msgmode both				\
		  -uvmcontrol=all			\
		  -debugDB=questa.dbg			\
		  -assertdebug			\
		  -onfinish stop			\
		  +uvm_set_config_int=*,recording_detail,400 \
#		  +UVM_CONFIG_DB_TRACE \
		  +UVM_OBJECTION_TRACE

UCDB_TO_HTML_CNVRT = vcover report -html -htmldir coverage_database/ -verbose -threshL 50 -threshH 90 cover_database.ucdb

PROJECT_FILES = +incdir+apb_master \
								+incdir+apb_slave \
								+incdir+apb_env \
								+incdir+tests

vsim_check : 
	  vlog -sv $(UVM_DEPRICATED) $(PROJECT_FILES) apb_top.sv; vsim -lib work +UVM_NO_RELNOTES $(TOP_NAME) $(UVM_TOP) -c -do wave_dump.do

vsim_cmd :
	@echo "==================== Start Running Testcase ====================="
	vlog -sv $(UVM_DEPRICATED) $(PROJECT_FILES) apb_top.sv; vsim -lib work +UVM_NO_RELNOTES $(COVERAGE) $(ASSERTCOVERAGE) $(UVM_TEST_NAME) $(TOP_NAME) $(UVM_TOP) -solvefaildebug -sva -assertdebug -voptargs="+acc" -c -do wave_dump.do

clean :
	@echo ==================== Cleaning Starts =====================
	rm -rf work/ 
	rm -rf *.log 
	rm -rf simv* 
	rm -rf *.ucdb
	rm -rf dump*
	rm -rf transcript
	rm -rf vsim.wlf 
	rm -rf *.vstf 
	rm -rf csrc covhtmlreport transcript ucli.key vc_hdrs.h
	rm -rf $(COVERAGE_DATABASE)
	@echo ==================== Cleaning Ends =====================

vlib :
	vlib work

run : 
	make clean; \
  make vlib; \
  make vsim_cmd; $(UCDB_TO_HTML_CNVRT)



