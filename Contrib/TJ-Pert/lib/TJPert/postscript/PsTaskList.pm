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

use PostScript::Simple 0.09;


use strict;

use TJPert::model::TaskList;
use TJPert::postscript::PsTask;

=pod 

This package specialises TaskList for output to Postscript

=cut

package  TJPert::postscript::PsTaskList;



use vars qw(@ISA);
@ISA = qw(    TJPert::postscript::PsTask TJPert::model::TaskList );


sub new {
    my ( $class, $ref ) = @_;
    my $tl = TJPert::model::TaskList->new($ref);
    my $pst = TJPert::postscript::PsTask->new($ref);
    #join the two class hashes into one. Developer: There is a risk that the order is wrong
    my $this = {( %{$tl}, %{$pst} )};
    return bless $this, $class;
}





=pod 

Overload the method to create a Task, so it creates a PsTask

=cut

sub createTask
{
#    print "PsTaskList::createTask\n";
    my $self = shift;
    my $task = shift;
    return TJPert::postscript::PsTask->new($task);
}



=pod 

Overload the method to create a TaskList, so it creates a PsTaskList

=cut

sub createTaskList
{
    print "PsTaskList::createTaskList\n";
    my $self = shift;
    my $task = shift;
    return TJPert::postscript::PsTaskList->new($task);
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






=pod 
This is where -ve y is being applied

=cut

# draw recursively all the tasks and dependencies
sub draw {
#    print "PsTaskList::draw\n";
#    print Dumper(@_);
    my $self = shift;

    #postscript output
    my $p = shift;

    my $xpos = shift;
    my $ypos = shift;

    my $task;

    # cell height
    my $c_h = TJPert::postscript::PsTask::get_task_height() * TJPert::postscript::PsTask->cell_coef();

    # cell width
    my $c_w = TJPert::postscript::PsTask::get_task_width() * TJPert::postscript::PsTask->cell_coef();

    #cell margins
    my $m_x = ( $c_w - TJPert::postscript::PsTask::get_task_width() ) / 2.0;
    my $m_y = ( $c_h - TJPert::postscript::PsTask::get_task_height() ) / 2.0;

#    print "cell ht $c_h, cell margin $m_y\n";

    # draw dependencies lines
    my ( $x_rs, $y_rs, $x_ls, $y_ls );
    my $dep;

    foreach $task ( @{ $self->{List} } ) {
        $x_rs = $task->get_min_col() * $c_w + $m_x;
#       $y_rs = -( ( $task->get_lin() + 0.5 ) * $c_h );
        $y_rs =  ( ( $task->get_lin() + 1.5 ) * $c_h );
        foreach $dep ( @{ $task->get_dep() } ) {
            $x_ls = ( $dep->get_max_col() + 1 ) * $c_w - $m_x;
#           $y_ls = -( $dep->get_lin() * $c_h + 0.5 * $c_h );
            $y_ls =  ( $dep->get_lin() * $c_h + 1.25 * $c_h );
            $p->line( $x_ls, $y_ls, $x_rs, $y_rs ) or die $p->err();
        }
    }

    # draw tasks
    foreach $task ( @{ $self->{List} } ) {

        #      if ($task->get_lin() != -1 && $task->get_col() != -1) {
        if ( $task->get_lin() != -1 ) {

            # task position in the chart
            my $x_pos = $task->get_col() * $c_w + $m_x;
#           my $y_pos = -( ( $task->get_lin() + 1 ) * $c_h - $m_y );
            my $y_pos =  ( ( $task->get_lin() + 1 ) * $c_h - $m_y );

            $task->draw( $p, $x_pos, $y_pos );
        }

=pod dont need the container drawn

        $p->setcolour("grey70") or die $p->err();

        # draw rectangle for container
        if ( $task->get_lin() != -1 ) {
            $p->box( $self->get_min_col() * $c_w + 0.5 * $m_x,
#               -( $self->get_lin * $c_h + 0.5 * $m_y ),
                 ( $self->get_lin * $c_h - 0.5 * $m_y ),
                ( $self->get_max_col + 1 ) * $c_w - 0.5 * $m_x,
#               -( ( ( $self->get_lin + $self->get_height ) * $c_h ) - 0.5 *
                 ( ( ( $self->get_lin + 1 + $self->get_height ) * $c_h ) + 0.5 *
                $m_y ) ) or die $p->err();
        }
        $p->setcolour("black") or die $p->err();

=cut

    }

}
