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



#takes a unix time number 0: epoch 1970
#in 1436742000
#out "13/7/2015"
#returns in localtime - current timezone
sub timeToStringYMD
{
    my ($time_epoch) = @_;
    #diag($time_epoch);
    my @times = localtime($time_epoch);
    #diag("@times");
    my $str = ($times[5] + 1900) . "/" . ($times[4] + 1) . "/" . $times[3];
    #diag($str);
    return ($str);
}

#test the test harness
is(timeToStringYMD(1436745600), "2015/7/13", "timeToStringYMD");
is(timeToStringYMD(1422748800), "2015/2/1", "timeToStringYMD");
is(timeToStringYMD(1044057600), "2003/2/1", "timeToStringYMD");
is(timeToStringYMD(1485820800), "2017/1/31", "timeToStringYMD");
is(timeToStringYMD(1449964800), "2015/12/13", "timeToStringYMD");

#above dates were generate by eg
#TZ=GMT date --date     '13 jul 2015' +%s


#
#######################################################################
#
# test the library method(s)
#


my $times = "2017-08-23T17:00:00";
my $timen = TJPerlUtils::util_sub_msp_time_to_unix_time($times);
is(timeToStringYMD($timen), "2017/8/23", "$times");



$times = "2015-07-13T17:00:00";
$timen = TJPerlUtils::util_sub_msp_time_to_unix_time($times);
is(timeToStringYMD($timen), "2015/7/13", "$times");



$times = "2018-01-31T17:00:00";
$timen = TJPerlUtils::util_sub_msp_time_to_unix_time($times);
is(timeToStringYMD($timen), "2018/1/31", "$times");



$times = "2013-02-01T17:00:00";
$timen = TJPerlUtils::util_sub_msp_time_to_unix_time($times);
is(timeToStringYMD($timen), "2013/2/1", "$times");





1;

