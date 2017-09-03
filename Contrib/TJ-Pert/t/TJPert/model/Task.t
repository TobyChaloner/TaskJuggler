#!/usr/bin/perl -w

#cd ../../..; make; make -k test TEST_FILES=t/TJPert/model/Task.t


use Data::Dumper;

use FindBin;
use lib $FindBin::Bin ;
#use lib "../../../lib";

use XML::Simple;

use TJPert::model::TaskList;
use TJPert::model::Task;

use strict;

use Test::More qw(no_plan);

BEGIN {
    use_ok('TJPert::model::Task');
}


#get a ref to 1st Task
#path relative to the model directory, not this 't' one.
#my $input_file = "../data/output/simpleTasksTestData.msp.xml";
my $input_file = "t/TJPert/data/output/simpleTasksTestData.msp.xml";

my $projetxml =
    XMLin( $input_file, forcearray => [ "Task", "TaskID", "Previous" ] );

my $rXmlTask0 = $projetxml->{Tasks}->{Task}[0];
#diag( Dumper($rXmlTask0));

can_ok('TJPert::model::Task', ('new'));
my $task0 = TJPert::model::Task->new($rXmlTask0);

can_ok('TJPert::model::Task', ('get_id'));
is($task0->get_id(), 1, "get_id = 1");

can_ok('TJPert::model::Task', ('get_task_name'));
is($task0->get_task_name(), 'FirstTask', "get_task_name: FirstTask");


can_ok('TJPert::model::Task', ('get_dep'));
is($task0->get_dep(), undef, "get_dep = undef");


#get a ref to 2nd Task
#path relative to the model directory, not this 't' one.
my $rXmlTask1 = $projetxml->{Tasks}->{Task}[1];

#diag( Dumper($rXmlTask1));
my $task1 = TJPert::model::Task->new($rXmlTask1);


my $rXmlTask2 = $projetxml->{Tasks}->{Task}[2];
#diag( Dumper($rXmlTask2));
my $task2 = TJPert::model::Task->new($rXmlTask2);

my $rXmlTask3 = $projetxml->{Tasks}->{Task}[3];
#diag( Dumper($rXmlTask3));
my $task3 = TJPert::model::Task->new($rXmlTask3);



#dep should return nil at this point, further tests below
is($task1->get_dep(), undef, "get_dep == undef");




#populate a TaskList do the 
my $taskList =TJPert::model::TaskList->new($projetxml);
$taskList->extract_list_task($projetxml);
my $list_dep;
$list_dep = $task1->find_dep_lst($taskList);
#diag( Dumper($lst_dep));
$task1->set_dep($list_dep);

#
#Post dep populated tests
#
isnt($task1->get_dep(), undef, "get_dep != undef");



can_ok('TJPert::model::Task', ('get_previous_id'));
is($task0->get_previous_id(), undef, "get_previous_id = undef");
isnt($task1->get_previous_id(), undef, "get_previous_id != undef");


#  get_follower_id: NI

can_ok('TJPert::model::Task', ('is_container'));
is($task0->is_container(), 0, "is_container == 0");


can_ok('TJPert::model::Task', ('get_end'));
is($task0->get_end(), 1471647600, "get_end");

can_ok('TJPert::model::Task', ('is_milestone'));
isnt($task0->is_milestone(), 1, "!is_milestone");
is($task3->is_milestone(), 1, "is_milestone");

can_ok('TJPert::model::Task', ('get_percent_complete'));
is($task1->get_percent_complete(), 49, "get_percent_complete != 49");


can_ok('TJPert::model::Task', ('get_start'));
is($task1->get_start(), 1471680000, "get_start");


#id_to_abs unchanged



#find_dep_lst
#  Simplest case: nil
#  Next one - hash ref
#  Many array of hash ref
$list_dep = $task0->find_dep_lst($taskList);
#diag( Dumper($list_dep));
is(@$list_dep == 0, 1, "find_dep_lst no dependencies");

$list_dep = $task1->find_dep_lst($taskList);
#diag( Dumper($list_dep));
is(@$list_dep == 1, 1, "find_dep_lst 1 dependency");

$list_dep = $task2->find_dep_lst($taskList);
#diag( Dumper($list_dep));
is(@$list_dep == 2, 1, "find_dep_lst 2 dependencies");



=pod


can_ok('TJPert::model::Task', (''));
isnt($task->(), undef, " != undef");

=cut 



#unchanged routines









exit 0;
