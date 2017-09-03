#!/usr/bin/perl -w

#cd ../../..; make; make -k test TEST_FILES=t/TJPert/graphviz/GvProjet.t


use Data::Dumper;



use FindBin;
use lib $FindBin::Bin ;
use lib "$FindBin::Bin/../../model" ;

use XML::Simple;


use TJPert::model::TaskList;
use TJPert::model::Task;
use TJPert::graphviz::GvTaskList;
#use TJPert::postscript::PsProjet;
use TJPert::graphviz::GvProjet;

use strict;

use Test::More qw(no_plan);


BEGIN {
    use_ok('TJPert::graphviz::GvProjet');
}

package main;


my $input_file = "t/TJPert/data/output/simpleTasksTestData.msp.xml";


my $tmp;
$tmp = "/tmp/" if (-d "/tmp");
my $output_file = $tmp."task_projet_output.txt";






my $projetxml =
    XMLin( $input_file, forcearray => [ "Task", "TaskID", "Previous" ] );

#diag( Dumper($projetxml));

my $projet;
$projet = TJPert::graphviz::GvProjet->new($projetxml);

#$DB::single = 1;

# Extract task from xml/perl struct
$projet->extract_list_task($projetxml);

#diag( Dumper($projet));
$projet->process_tasks;


#diag( Dumper($projet));


#diag($gvt->get_task_name());

#text
$projet->set_format('plain');

#arguments to this function are unique to the object.
$projet->drawFile($output_file);







#
# the output file should have the names of three tasks in it
#
open( INPUTFILE, "<$output_file" ) or fail "$!";


my $found = 0;
my $found2 = 0;
my $found3 = 0;

while (my $line = <INPUTFILE>) {
    if ( $line =~ /FirstTask/ ) {
	$found++;
    }
    if ( $line =~ /50% complete/ ) {
	$found2++;
    }
    if ( $line =~ /Not Started/ ) {
	$found3++;
    }
}
if ( $found)
{
    pass("find string in output");
}
else
{
    fail("find string in output");
}
if ( $found2)
{
    pass("find string '50% complete' in output");
}
else
{
    fail("find string '50% complete' in output");
}

if ( $found3)
{
    pass("find string 'Not Started' in output");
}
else
{
    fail("find string 'Not Started' in output");
}

1;
