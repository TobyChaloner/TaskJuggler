#!/usr/bin/perl -w
use Data::Dumper;

use FindBin;
use lib $FindBin::Bin ;
#use lib "$FindBin::Bin/../../model" ;

use XML::Simple;
use gv;

use GvTask;

use strict;

use Test::More qw(no_plan);

BEGIN {
    use_ok('GvTask');
}







package main;

my $output_file = "task_output.txt";

my $g=gv::graph('gg'); ########################

my $r = {
	 "Task" => {
		    Name => "Forester"
		   }
	};
my $task = Task->new($r);
#my $gvtTask = $xmlTask;
my $gvt = GvTask->new($task);
diag($gvt->get_task_name());
$gvt->draw($g,0,0);
    gv::layout($g, 'dot');
    gv::render($g, 'png', $output_file); #####################
    
    gv::rm($g);

1;
