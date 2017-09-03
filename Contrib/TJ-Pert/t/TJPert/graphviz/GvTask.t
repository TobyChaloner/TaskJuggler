#!/usr/bin/perl -w
use Data::Dumper;

use FindBin;
use lib $FindBin::Bin ;
#use lib "$FindBin::Bin/../../model" ;
use lib ".";



use XML::Simple;
use gv;

use TJPert::model::Task;
use TJPert::graphviz::GvTask;

use strict;

use Test::More qw(no_plan);

BEGIN {
    use_ok('TJPert::graphviz::GvTask');
}


package main;


my $input_file = "t/TJPert/data/output/simpleTasksTestData.msp.xml";

my $projetxml =
    XMLin( $input_file, forcearray => [ "Task", "TaskID", "Previous" ] );

my $rXmlTask0 = $projetxml->{Tasks}->{Task}[0];
#diag( Dumper($rXmlTask0));


my $tmp;
$tmp = "/tmp/" if (-d "/tmp");

my $output_file = $tmp."task_output.txt";

my $g=gv::graph('gg'); ########################

#my $gvtTask = $xmlTask;
my $gvt = TJPert::graphviz::GvTask->new($rXmlTask0);
#diag($gvt->get_task_name());
$gvt->draw($g,0,0);
gv::layout($g, 'dot');
gv::render($g, 'plain', $output_file);
gv::rm($g);
  
open( INPUTFILE, "<$output_file" ) or fail "$!";
my $found = 0;
while (my $line = <INPUTFILE>) {
    if ( $line =~ /FirstTask/ ) {
	$found++;
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

1;
