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


=pod Format of the MSProject XML produced by TJ

This is only a partial - where I need it.

TODO sub tasks (recursive)

Tasks
 Task
  UID
  Name
  Start
  Finish
  PredecessorLink
    PredecessorUID
  PredecessorLink
    PredecessorUID
  PredecessorLink
    PredecessorUID


=cut





use XML::Simple;



use strict;



use TJPert::model::Task qw(set_lin add_lin);



package TJPert::model::TaskList;


use Carp;
use Data::Dumper;


use vars qw(@ISA);
@ISA = qw( TJPert::model::Task );

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

    my $tasklist = TJPert::model::Task->new($ref);
    $tasklist->{Liste}     = [];
    $tasklist->{Max_X}     = -1;
    $tasklist->{Min_X}     = 999;
    $tasklist->{Abs_Max_X} = -1;
    $tasklist->{Abs_Max_Y} = -1;

    bless $tasklist, $class;

    $tasklist->set_height(0);#set cos, defaulting to undef not always tolerated

    return $tasklist;
}


=pod

added here as the assignments are only created once
this is to be called after new

=cut

sub set_assignments
{
    my $self = shift;
    my $assignents = shift;
    $self->{Assignments} = $assignents;
}


=pod 
	arg is a hash with contents like UID, Name, Start, Finish

=cut


sub add_task {
    my $self = shift;

    return push @{ $self->{List} }, shift;
}

sub get_abs_max_x {
    my $self = shift;

    return $self->{AbsMaxX};
}

sub get_abs_max_y {
    my $self = shift;

    return $self->{AbsMaxY};
}

=pod 

 extract each task from the xml structure in a TaskList
$xmllist looks like
$VAR1 = {
          'Task' => [
                    {
                      'Name' => 'Remove Unit to Right Cooker',
                      'UID' => '1',
                       'PredecessorLink' => [
                                           {
                                             'PredecessorUID' => '8',
                                             'Type' => '1'
                                           },
                                           {
                                             'PredecessorUID' => '10',
                                             'Type' => '1'
                                           }
                                         ],
                   ...
                  },
                    {
                      'Priority' => '500',
                      'PercentWorkComplete' => '0',
                      'ID' => '2',
                      'Milestone' => '0',
                      'Name' => 'Remove Cooker',
                      'UID' => '2',
                   ...
                    }
                  ]
        };


=cut

sub extract_list_task {
    my $self = shift;

    # xml/perl struct
    my $xmllist = shift;

    my $task;
    my $taskl;

    #yields an array of hashes in TJ/MSP format
    #each hash has contents like UID, Name, Start, Finish

    #looking at Tasks->Task.@array of records
    foreach $task ( @{ $xmllist->{Tasks}->{Task} } ) {
	#$task is a hash with contents like UID, Name, Start, Finish

	#TODO - deferred
	if ( $task->{SubTasks} ) {

            # the task have subtasks => create new TaskList
	    $taskl = createTaskList($task);
	    $taskl->set_assignments($self->{Assignments});
	    
            # extract subtasks from xml/perl struct
            $taskl->extract_list_task( $task->{SubTasks} );

            # add the new TaskList
            $self->add_task($taskl);

        }
        else {
            my $ntask = $self->createTask($task);
	    $ntask->set_assignments($self->{Assignments});
	    $self->add_task( $ntask );
        }
    }
}


=pod 

This creates a Task, if this object has been inherited, this could return an inherited Task.

=cut
sub createTask
{
    print "TaskList::createTask\n";
    my $self    = shift;
    my $task = shift;
    return TJPert::model::Task->new($task);
}



=pod 

This creates a TaskList, if this object has been inherited, this could return an inherited TaskList.

=cut
sub createTaskList
{
    print "TaskList::createTaskList\n";
    my $self    = shift;
    my $task = shift;
    return TJPert::model::TaskList->new($task);
}




# Find a task whith its Id
sub find_id {
    my $self    = shift;
    my $task_id = shift;

    my $task;

    foreach $task ( @{ $self->{List} } ) {
        return $task if ( $task_id eq $task->get_id() );
        if ( ref($task) eq "TaskList" ) {
            my $result = $task->find_id($task_id);
            return $result if ($result);
        }
    }

#    carp "didnt find id";
    return;

}




=pod 

Output:
Each task will have a 'Dep' attribute which is an array.
This array has each task it is dependent on (possibly a ref).


TOBY looks ok for non hierachical

=cut


#TODO
sub add_depends_by_ref {
    my $self     = shift;
    my $alltasks = shift;

    my $lst_dep;

    my $task;
    foreach $task ( @{ $self->{List} } ) {
      $lst_dep = $task->find_dep_lst($alltasks);
      $task->set_dep($lst_dep);
      if ( $task->is_container ) #task is not, tasklist is.
	{
	  # traite récursivement les taches de la liste
	  $task->add_depends_by_ref($alltasks);
	  
	  # ajoute les dépendance de la liste à la premiere sous-tache
	  if ( $lst_dep )
	    {
	      my $first = $task->first_subtask();
	      $first->set_dep($lst_dep);
	    }
	}
    }
}

# TaskList is a container
sub is_container {
    my $self = shift;

    return 1;
}

sub get_max_col {
    my $self = shift;

    return $self->{Max_X};
}

sub get_min_col {
    my $self = shift;

    return $self->{Min_X};
}

sub get_height {
    my $self = shift;

    return $self->{Height};
}

sub set_height {
    my $self = shift;

    $self->{Height} = shift;
}




#TODO
# Find latest sub task
sub last_subtask {
    my $self = shift;

print "last_subtask ".Dumper($self);

    my $id = $self->get_id();
    my $lastsub;
    my $date = 0;
    my $subtask;

    foreach $subtask ( @{ $self->{List} } ) {
        if ( $subtask->get_end() > $date ) {
            $lastsub = $subtask;
            $date    = $subtask->get_end();
        }
    }

    $lastsub = $lastsub->last_subtask() if ( $lastsub->is_container() );

    return $lastsub;
}

#TODO
# Find first subtask
sub first_subtask {
    my $self = shift;

print "first_subtask ".Dumper($self);

    my $id = $self->get_id();
    my $firstsub;
    my $date;
    my $subtask;

    $firstsub = $self->{List}->[0];
    $date = $firstsub->get_start();
    foreach $subtask ( @{ $self->{List} } ) {
        if ( $subtask->get_start() < $date ) {
            $firstsub = $subtask;
            $date    = $subtask->get_start();
        }
    }

    $firstsub = $firstsub->first_subtask() if ( $firstsub->is_container() );

    return $firstsub;
}

# return true if the cell is free in local grid
sub cell_is_free {
    my $self       = shift;
    my $line       = shift;
    my $height     = shift;
    my $column_min = shift;
    my $column_max = shift;

    # intersection coordinates
    my $x_min;
    my $y_min;
    my $x_max;
    my $y_max;

    my $task;

    foreach $task ( @{ $self->{List} } ) {
        if ( $task->get_lin != -1 ) {
            $x_min = max( $column_min, $task->get_min_col );
            $x_max = min( $column_max, $task->get_max_col );
            $y_min = max( $line,       $task->get_lin );
            $y_max =
              min( $line + $height - 1,
                $task->get_lin + $task->get_height - 1 );
            return 0 if ( $x_min <= $x_max and $y_min <= $y_max );
        }
    }

    return 1;
}

sub col_is_set {
    my $self = shift;

    my $task;
    foreach $task ( @{ $self->{List} } ) {
        return 0 if ( !$task->col_is_set );
    }
    return 1;
}

# find first free line in column $column since line $line
sub find_free_line {
    my $self   = shift;
    my $column = shift;
    my $line   = shift;

    while ( !$self->cell_is_free( $column, $line ) ) {
        $line++;
    }

    return $line;
}

# Place each task in the grid
sub put_in_grid {
    my $self = shift;

    my $alltasks = shift;

    my $again = 1;
    my $task;

    my $col;
    my $line;

    my $againrec = 0;

    while ($again) {
        $again = 0;

        foreach $task ( @{ $self->{List} } ) {
            if ( $task->is_container ) {
                $again = $task->put_in_grid($alltasks);
                $self->{Max_X} = $task->get_max_col
                  if ( $self->{Max_X} < $task->get_max_col );

                $self->{Min_X} = $task->get_min_col
                  if ( $self->{Min_X} > $task->get_min_col );

            }
            else {
                if ( !$task->col_is_set() && $task->can_set_col() ) {

                    # find column and line in the grid
                    $col = $task->set_col();

                    # update the last line and column
                    $self->{Max_X} = $col if ( $self->{Max_X} < $col );

                    $self->{Min_X} = $col if ( $self->{Min_X} > $col );

                    $again    = 1;
                    $againrec = 1;

                }
            }
        }
    }

    return $againrec;

}



=pod 

call through

=cut

sub draw
{
    my $self = shift;
    $self->SUPER::draw(@_);
}





# each task are put in a relative line
sub put_in_line {
    my $self = shift;
#print(Dumper($this));
    my $task;

    foreach $task ( @{ $self->{List} } ) {
        $task->put_in_line if ( $task->is_container );
        my $line = 0;
        while (
            !$self->cell_is_free( $line, $task->get_height, $task->get_min_col,
                $task->get_max_col ) )
        {
            $line++;
        }
        $task->set_lin($line);
        if ( $self->get_height < $line +
	     $task->get_height ) {
            $self->set_height( $line + $task->get_height );
        }
    }
}

# set line for a TaskList
# all the subtasks are in relative coordinate => they are moved down
sub set_lin {
    my $self = shift;
    my $line = shift;

    my $task;

    $self->SUPER::set_lin($line);

    foreach $task ( @{ $self->{List} } ) {
        $task->add_lin($line);
    }

}

sub add_lin {

    my $self = shift;
    my $line = shift;

    my $task;

    $self->SUPER::add_lin($line);

    foreach $task ( @{ $self->{List} } ) {
        $task->add_lin($line);
    }

}

1;
