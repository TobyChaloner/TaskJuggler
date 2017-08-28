INSTALL_D=${HOME}/lib/perl

all: t1 t2 t3 t4 y5 t6 t7 t8 t9 


t1:
	#perl TJ-Pert.pl t2.msp.xml

t2:
	perl TJ-Pert.pl test/output/testDepends.msp.xml

t3:
	perl TJ-Pert.pl test/output/testPrecedes.msp.xml

t4:
	perl TJ-Pert.pl test/output/testMilestone.msp.xml

t5:
	perl TJ-Pert.pl test/output/testPercentComplete.msp.xml


t6:
	perl TJ-Pert.pl test/output/testDepends.msp.xml -t png

t7:
	perl TJ-Pert.pl test/output/testPrecedes.msp.xml -t png

t8:
	perl TJ-Pert.pl test/output/testMilestone.msp.xml -t png

t9:
	perl TJ-Pert.pl test/output/testPercentComplete.msp.xml -t png -o test/output/testPercentComplete.png







g2:
	perl TJ-Pert-GraphViz.pl test/output/testDepends.msp.xml

g3:
	perl TJ-Pert-GraphViz.pl test/output/testPrecedes.msp.xml
g4:
	perl TJ-Pert-GraphViz.pl test/output/testMilestone.msp.xml
g5:
	perl TJ-Pert-GraphViz.pl 

install:
	cp *.pm *.pl ${INSTALL_D}
	chmod 766 ${INSTALL_D}/TJ-Pert.pl


doc:
	mkdir -p html_docs; 
	cd html_docs; perl -mPod::Simple::HTMLBatch -ePod::Simple::HTMLBatch::go .. .

