#
# Test version stub
#

use strict;



package Task;
sub new {
    my ( $class, $ref ) = @_;
    my $task = {
    };
    bless $task, $class;
    return $task;
}

sub draw
{
}
sub get_task_name
{
    return("testName");
}
sub is_milestone
{
    return 0;
}
sub get_id
{
    return "32";
}
sub get_start
{
    return 1;# 1970
}
sub get_end
{
    return 50000;
}
1;
