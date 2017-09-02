#!/usr/bin/perl -w
use Data::Dumper;

use FindBin;
use lib $FindBin::Bin ;

use XML::Simple;

use TJPert::model::TaskList;

use strict;

use Test::More qw(no_plan);

BEGIN {
    use_ok('TJPert::model::Task');
}


package DerivedTaskList;


sub new {
    my ( $class, $ref ) = @_;
    my $tl = TJPert::model::TaskList->new($ref);
    my $this = {( %{$tl} )};
    return bless $this, $class;
}






sub draw
{
	return 1;
}


package main;


#get a ref to 1st Task
#path relative to the model directory, not this 't' one.
my $input_file = "t/TJPert/data/output/simpleTasksTestData.msp.xml";
my $projetxml =
    XMLin( $input_file, forcearray => [ "Task", "TaskID", "Previous" ] );



#
#extract_list_task
#
#NI: subtasks

#populate a TaskList do the 
my $taskList = TJPert::model::TaskList->new($projetxml);
#is( $task1->find_dep_lst($taskList), undef, "find_dep_lst on empty");
$taskList->extract_list_task($projetxml);

my $list_dep;
#$list_dep = $task1->find_dep_lst($taskList);
#diag( Dumper($lst_dep));
#$task1->set_dep($list_dep);


my $rXmlTask0 = $projetxml->{Tasks}->{Task}[0];

#
# createTask
#

my $task0 = $taskList->createTask($rXmlTask0);
is($task0->is_container(), 0, "is task not a container");


#
# createTaskList
#

my $taskList0 = $taskList->createTaskList($rXmlTask0);
is($taskList0->is_container(), 1, "is task a container");

#
#find_id
#
#NI: subTasks
#diag( Dumper($taskList->find_id(1)));
#diag( $taskList->find_id(1)->{Task}->{UID});
isnt($taskList->find_id(1), undef, "find_id");
isnt($taskList->find_id(2), undef, "find_id");
isnt($taskList->find_id(3), undef, "find_id");
isnt($taskList->find_id(4), undef, "find_id");
is($taskList->find_id(1)->{Task}->{UID}, 1, "find_id");
is($taskList->find_id(2)->{Task}->{UID}, 2, "find_id");
is($taskList->find_id(3)->{Task}->{UID}, 3, "find_id");
is($taskList->find_id(4)->{Task}->{UID}, 4, "find_id");
#not found
is($taskList->find_id(5), undef, "find_id");



#
#add_depends_by_ref
#
#unchanged

#
#last_subtask
#
# unchanged

#
#first_subtask
#
#unchanged

#
#cell_is_free
#

#...


#
# draw
#

my $dtl = DerivedTaskList->new($projetxml);
is($dtl->draw(), 1, "TaskList::draw calls derived routine");

#...



1;
