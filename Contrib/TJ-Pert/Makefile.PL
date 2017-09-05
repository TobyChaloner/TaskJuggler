use ExtUtils::MakeMaker;
WriteMakefile(
	      NAME            => 'TJ-Pert.pl',
	      VERSION_FROM    => 'bin/TJ-Pert.pl',
	      ABSTRACT_FROM   => 'bin/TJ-Pert.pl',
	      EXE_FILES       => ['bin/TJ-Pert.pl'],
	      BUILD_REQUIRES  => { "ExtUtils::MakeMaker" => 0 },
	      test => {TESTS => 't/*.t t/*/*.t t/*/*/*.t'},
	      TEST_REQUIRES   => {
				  Test::More => 0.95,
				 },
	      #'LIBS'  =>  qw(-llib/TJPert/model),
	      MAN1PODS => { 'bin/TJ-Pert.pl' => 'blib/man1/TJ-Pert.1' },
	      MAN3PODS => { },
	      #	      INC=>'-Ilib/TJPert/model' ,
	      PREREQ_PM => {
			    #graphviz - no version, but it must exist
			    "gv" => "0",
			     "XML::Simple" => "2.2",
			    },

	     );


#
# When the system is built, the test data needs to be prepared with
# the (latest/installed) TaskJuggler
#
package MY;
system("cd t/TJPert/data/; make -f Makefile.data") == 0 or die "make of test data failed";
system("dot -V") == 0 or die "Error: graphviz not installed, need >= 2.38";

1;
