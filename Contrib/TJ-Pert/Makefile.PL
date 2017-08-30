use ExtUtils::MakeMaker;
WriteMakefile(
	      NAME            => 'TJ-Pert.pl',
	      VERSION_FROM    => 'bin/TJ-Pert.pl',
	      test => {TESTS => 't/*.t t/*/*.t t/*/*/*.t'}
    );
