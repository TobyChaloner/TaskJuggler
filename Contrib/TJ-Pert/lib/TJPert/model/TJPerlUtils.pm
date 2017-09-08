package TJPerlUtils;


use POSIX;

=pod 
takes '2017-08-23T17:00:00'
returns 1506182400

=cut
sub util_sub_msp_time_to_unix_time
{
    my ($msp_time) = @_;
    my @parts= $msp_time=~/(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)/;
    my $year = $parts[0] - 1900; #2017 is 107
    #Month is 0-11, humans use 1-12 # hence month is - 1
    my $time = mktime($parts[5], $parts[4], $parts[3], $parts[2], $parts[1] - 1, $year);
    return $time; #
}


1;
