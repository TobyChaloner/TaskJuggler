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

=pod 
WEAKNESS
Not sure if get_id should be using UID or ID - see as go

=cut


use POSIX;
use TJPert::model::TJPerlUtils;

use strict;




package TJPert::model::Task;

use Carp;
use Data::Dumper;

sub new {
    my ( $class, $ref ) = @_;

    my $task = {
        Task => $ref,
        Col  => -1,
        Lin  => -1,
    };

    bless $task, $class;

    return $task;

}


=pod 
TODO
Not sure if should be returning ID or UID

=cut

sub get_id {
    my $self = shift;

    #DEBUG SANITY
    die "get_id - identies different UID != ID " if ($self->{Task}->{ID} != $self->{Task}->{UID});

    #return $self->{Task}->{ID};
    return $self->{Task}->{UID};

}


=pod 

Gets the name

=cut

sub get_task_name {
    my $self = shift;
    return $self->{Task}->{Name};
}



=pod 
Sets my Dep attribute to a [list of dependencies] that
has been passed in.  List could be empty.

=cut
sub set_dep {
    my $self = shift;

    my $dep = shift;

    $self->{Dep} = $dep;
}

sub can_set_col {
    my $self = shift;

    my $task_dep;

    foreach $task_dep ( @{ $self->{Dep} } ) {
        return 0 if ( !$task_dep->col_is_set() );
    }

    return 1;

}

sub set_col {
    my $self = shift;

    my $column = -1;
    my $task_dep;
    my $col_task;

    foreach $task_dep ( @{ $self->{Dep} } ) {

        $col_task = $task_dep->get_max_col();
        $column = $col_task if ( $col_task > $column );
    }

    $column++;

    $self->{Col} = $column;

    return $column;
}

sub col_is_set {
    my $self = shift;

    return ( $self->{Col} != -1 );
}

sub get_col {
    my $self = shift;

    return $self->{Col};
}

sub get_min_col {
    my $self = shift;

    return $self->{Col};
}

sub get_max_col {
    my $self = shift;

    return $self->{Col};
}

sub calc_lin {
    my $self = shift;

    my $first_dep;
    my $line = 0;

    if ( $self->{Dep}[0] ) {
        $first_dep = $self->{Dep}[0];
        $line      = $first_dep->get_lin();
    }

    return $line;
}

sub set_lin {
    my $self = shift;
    my $line = shift;

    $self->{Lin} = $line;

    return;
}

sub add_lin {
    my $self = shift;
    my $line = shift;

    $self->{Lin} = $self->{Lin} + $line;

    return;
}

sub get_lin {
    my $self = shift;

    return $self->{Lin};
}

sub get_height {
    return 1;
}

sub set_abs_lin {
    my $self = shift;
    my $line = shift;

    $self->{Abs_Lin} = $line;

    return;
}


# return task dependencies
sub get_dep {
    my $self = shift;

    return $self->{Dep};
}

## return task dependencie id from xml
#sub get_dep_id
#  {
#    my $self = shift;

#    return $self->{Task}->{Depends}{TaskID};
#  }


=pod 
Returns 
nil - no previous
a reference to a hash (one previous)
a reference to an array of hashes (many previous)

One:
          'PredecessorLink' => {
                               'PredecessorUID' => '1',
                               'Type' => '1'
                             },
Many:
          'PredecessorLink' => [
                               {
                                 'Type' => '1',
                                 'PredecessorUID' => '1'
                               },
                               {
                                 'PredecessorUID' => '2',
                                 'Type' => '1'
                               }
                             ],


=cut


# return task dependencie id from xml
sub get_previous_id {
    my $self = shift;
    #carp "get_previous_id";
    #print Dumper($self->{Task});
#TC    return $self->{Task}->{Previous};
    return $self->{Task}->{PredecessorLink};
}



#TODO - not used
# return task dependencie id from xml
sub get_follower_id {
    my $self = shift;
carp "get_follower_id - NOT IMPLEMENTED";
    return $self->{Task}->{Followers};
}


#a Task is not a countainer
sub is_container {
    my $self = shift;

    return 0;
}


#TODO
sub get_parent {
    my $self = shift;
carp "get_parent - NOT IMPLEMENTED";
    return $self->{Task}->{ParentTask};

}


#This appears to be returning an EPOCH LONG INT
sub get_end {
    my $self = shift;

    my $mspTime;
    if ( $self->get_percent_complete() != 0)
    {
	#actual
	$mspTime = $self->{Task}->{Finish}
      }
    else 
    {
	#planned
	$mspTime = $self->{Task}->{Finish};#TODO
#carp "get_end - planned is not Implemented";
    }
    return TJPerlUtils::util_sub_msp_time_to_unix_time($mspTime);
}


=pod 

true if milestone

=cut


sub is_milestone
{
    my $self = shift;
    my $isMilestone =  $self->{Task}->{Milestone} == 1;
    return $isMilestone;
}




#
# TODO - only 100% seems to get passed through.  Need to understand
#

=pod 

This is separated out so that the choice of which attribute to use is in one place
range 0 to 100

always returns a num

=cut

sub get_percent_complete
{
    my $self = shift;
    my $percent = $self->{Task}->{PercentComplete};
    $percent = 0 if (!defined $percent);
#print "Percent:  $percent\n";
    return $percent;
};




#This is returning an EPOCH LONG INT
sub get_start {
    my $self = shift;
    my $mspTime;
    if ( $self->get_percent_complete() != 0)
    {
	#actual
	 $mspTime = $self->{Task}->{Start}
      }
    else 
    {
	#planned
	$mspTime = $self->{Task}->{Start}; #TODO
#	carp "planned start NI - returning 'Start'";
      }
    return TJPerlUtils::util_sub_msp_time_to_unix_time($mspTime);
}





#TODO
# compute absolute Id from relative Id
sub id_to_abs {
    my $self   = shift;
    my $rel_id = shift;

    my $abs_id;
    my $task_id = $self->get_id;

    my @lst_sub_id = split /\./, $task_id;

    while ( $rel_id =~ s/^\!(.*)/$1/ ) {
        pop @lst_sub_id;
    }

    $abs_id = join '.', ( @lst_sub_id, $rel_id );
    return $abs_id;
}




=pod 

$self->get_previous_id:
  Simplest case: nil
  Next one - hash ref
  Many array of hash ref


This works with UIDs

This array does not exist in the MSP version.

returns a list of dependencies.
each element is ?

=cut

#create dependencies (previous tasks) reference list
sub find_dep_lst {
    my $self     = shift;
    my $alltasks = shift; #an object of type TaskList

    my $dep_ref;
    my $dep_id;
    my @lst_dep;
    my $abs_dep;

#    print "find_dep_lst".Dumper($self);
    my $rPreviousElem = $self->get_previous_id;

    #print Dumper($rPreviousElem);

    #nil
    if ( !$rPreviousElem ) {
#	print Dumper(@lst_dep);
	return \@lst_dep;
    }

    #one
    if (ref($rPreviousElem) eq 'HASH')
    {
	#working with UIDs
	$dep_id = $rPreviousElem->{PredecessorUID};
	$dep_ref = $alltasks->find_id($dep_id);
	push @lst_dep, $dep_ref;
	return \@lst_dep;
    }

    #many
    foreach my $rhprevious ( @{ $rPreviousElem } ) {
	$dep_id = $rhprevious->{PredecessorUID};
	$dep_ref = $alltasks->find_id($dep_id);
	push @lst_dep, $dep_ref;
    }
    return \@lst_dep;

=pod 
    
        foreach $dep_id ( @{ $self->get_previous_id } ) {
            $dep_ref = $alltasks->find_id($dep_id);

            # Task depends of a TaskList then find last task from this list
            $dep_ref = $dep_ref->last_subtask if ($dep_ref->is_container());

            push @lst_dep, $dep_ref;
        }
    }

    return \@lst_dep;

=cut

}

#create back dependencies (follower tasks) reference list
sub find_follower_lst {
    my $self     = shift;
    my $alltasks = shift;

    my $dep_ref;
    my $dep_id;
    my @lst_dep;
    my $abs_dep;
carp "find_follower_lst - Not Implemented";
    
    if ( $self->get_follower_id ) {
        foreach $dep_id ( @{ $self->get_follower_id } ) {
            $abs_dep = $self->id_to_abs($dep_id);
            $dep_ref = $alltasks->find_id($abs_dep);

            # not the best way but it works
            if ( $dep_ref->is_container() ) {
                $dep_ref = $dep_ref->last_sub_task;
            }
            push @lst_dep, $dep_ref;
        }
    }

    return \@lst_dep;
}

1;
