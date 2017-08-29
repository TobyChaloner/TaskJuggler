#!/usr/bin/perl -w
use Data::Dumper;

use FindBin;
use lib $FindBin::Bin ;

use XML::Simple;

use TaskList;
use Projet;

use strict;

use Test::More qw(no_plan);

BEGIN {
    use_ok('Task');
}


package DerivedProjet;

use vars qw(@ISA);
@ISA = qw( Projet );

sub new {
    my ( $class, $ref ) = @_;
    my $p = Projet->new($ref);
    my $this = $p;
    return bless $this, $class;
}






sub draw
{
	return 1;
}


package main;



############################################################
################### TESTS ##################################
############################################################



#get a ref to 1st Task
#path relative to the model directory, not this 't' one.
my $input_file = "../test/output/testTask.msp.xml";
my $projetxml =
    XMLin( $input_file, forcearray => [ "Task", "TaskID", "Previous" ] );






#populate a projet do the 
my $prj = DerivedProjet->new($projetxml);


#diag( Dumper($prj));

#
#get_name
#
is($prj->get_name(), "testTask.msp.xml", "get_name");





#
#get_version
#
is($prj->get_version(), 14, "get_version");




#
#get_end
#
is($prj->get_end(), "18/11/16", "get_end");



#
#get_start
#
is($prj->get_start(), "19/08/16", "get_start");





#
#
#
is($prj->get_now(), "25/08/16", "get_now");


#
#extract_list_task
#
#NI: subtasks

#is( $task1->find_dep_lst($taskList), undef, "find_dep_lst on empty");
$prj->extract_list_task($projetxml);

my $list_dep;
#$list_dep = $task1->find_dep_lst($taskList);
#diag( Dumper($lst_dep));
#$task1->set_dep($list_dep);


my $rXmlTask0 = $projetxml->{Tasks}->{Task}[0];

#
# createTask
#

my $task0 = $prj->createTask($rXmlTask0);
is($task0->is_container(), 0, "is task not a container");


1;
