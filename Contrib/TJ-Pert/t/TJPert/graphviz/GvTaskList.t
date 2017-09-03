#!/usr/bin/perl -w
use Data::Dumper;

use FindBin;
use lib $FindBin::Bin ;

use XML::Simple;

use TJPert::model::TaskList;
use TJPert::model::Task;
use TJPert::graphviz::GvTaskList;

use strict;

use Test::More qw(no_plan);


BEGIN {
    use_ok('TJPert::graphviz::GvTaskList');
}

package main;


my $input_file = "t/TJPert/data/output/simpleTasksTestData.msp.xml";

my $projetxml =
    XMLin( $input_file, forcearray => [ "Task", "TaskID", "Previous" ] );

my $taskList = TJPert::graphviz::GvTaskList->new($projetxml);
#diag( Dumper($taskList));

$taskList->extract_list_task($projetxml);
$taskList->add_depends_by_ref($taskList);
#my $rXmlTask0 = $projetxml->{Tasks}->{Task}[0];
#my $task0 = $taskList->createTask($rXmlTask0);
#my $taskList0 = $taskList->createTaskList($rXmlTask0);

my $tmp;
$tmp = "/tmp/" if (-d "/tmp");

my $output_file = $tmp."task_list_output.txt";

my $g=gv::graph('gg'); ########################

#my $gvtTask = $xmlTask;
#my $gvt = TJPert::graphviz::GvTask->new($rXmlTask0);
#diag($gvt->get_task_name());
#$gvt->draw($g,0,0);

$taskList->draw($g,0,0);

gv::layout($g, 'dot');
gv::render($g, 'plain', $output_file);
gv::rm($g);


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
