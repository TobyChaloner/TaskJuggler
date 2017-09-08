#!/usr/bin/perl -w

#cd ../../..; make; make -k test TEST_FILES=t/TJPert/model/TJPertUtils.t


use Data::Dumper;

use FindBin;
use lib $FindBin::Bin ;
#use lib "../../../lib";

use TJPert::model::TJPerlUtils;

use strict;

use Test::More qw(no_plan);

BEGIN {
    use_ok('TJPert::model::TJPerlUtils');
}



sub timeToStringYMD
{
    my ($time_epoch) = @_;
    #diag($time_epoch);
    my @times = gmtime($time_epoch);
    #diag("@times");
    my $str = ($times[5] + 1900) . "/" . ($times[4] + 1) . "/" . $times[3];
    #diag($str);
    return ($str);
}

my $times = "2017-08-23T17:00:00";

my $timen = TJPerlUtils::util_sub_msp_time_to_unix_time($times);


my $str = timeToStringYMD($timen);
is(timeToStringYMD($timen), "2017/8/23", "$times");




1;

