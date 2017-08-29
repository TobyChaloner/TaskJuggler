#!/usr/bin/perl -w
use Data::Dumper;

use FindBin;
use lib $FindBin::Bin ;
use lib "$FindBin::Bin/../../model" ;

use XML::Simple;

use TaskList;

use strict;

use Test::More qw(no_plan);

BEGIN {
    use_ok('Task');
}

