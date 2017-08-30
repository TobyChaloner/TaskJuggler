######################################################################## 
# Copyright (c) 2002 by Philippe Midol-Monnet <philippe@midol-monnet.org>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
#########################################################################

use XML::Simple;

use strict;

use TJPert::model::TJPerlUtils;
use TJPert::model::Task;
use TJPert::model::TaskList;


package TJPert::model::Projet;

#use Carp;
#use Data::Dumper;


use vars qw(@ISA);
@ISA = qw( TaskList );

sub max {
    my ($max) = shift (@_);

    my $temp;
    foreach $temp (@_) {
        $max = $temp if $temp > $max;
    }
    return ($max);
}

sub min {
    my ($min) = shift (@_);

    my $temp;
    foreach $temp (@_) {
        $min = $temp if $temp < $min;
    }
    return ($min);
}

sub new {
    my ( $class, $ref ) = @_;

    my $projet = TJPert::model::TaskList->new($ref);
    $projet->{xml} = $ref;

    bless $projet, $class;

    return $projet;
}


sub extract_list_task {
    my $self = shift;

    # call the TaskList sub
    $self->SUPER::extract_list_task($self->{xml});
}

sub process_tasks {
    my $self = shift;

    # add dependencies lists for all tasks
    $self->add_depends_by_ref($self);

    # place all task in  the grid;
    $self->put_in_grid($self);
    $self->put_in_line;
    $self->set_lin(0);
}

sub get_name {
    my $self = shift;
    return $self->{xml}{Name}
}


sub get_version {
    my $self = shift;
    return $self->{xml}{SaveVersion}
}




sub get_end {
    my $self = shift;
    my $mspTime = $self->{xml}{FinishDate};
    my $time = TJPerlUtils::util_sub_msp_time_to_unix_time($mspTime);
    return POSIX::strftime( "%x", localtime( $time ) )
}


sub get_start {
    my $self = shift;
    my $mspTime = $self->{xml}{StartDate};
    my $time = TJPerlUtils::util_sub_msp_time_to_unix_time($mspTime);
    return POSIX::strftime( "%x", localtime( $time ) )
}


sub get_now {
    my $self = shift;

    my $mspTime = $self->{xml}{CurrentDate};
    my $time = TJPerlUtils::util_sub_msp_time_to_unix_time($mspTime);
    return POSIX::strftime( "%x", localtime( $time ) )
}





=pod 

call through

=cut

sub draw
{
    print "Projet::draw\n";
    my $self = shift;
    $self->SUPER::draw(@_);
}



1;
