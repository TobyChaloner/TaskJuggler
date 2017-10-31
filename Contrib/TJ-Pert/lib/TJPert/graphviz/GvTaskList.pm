######################################################################## 
# Copyright (c) 2017 by Toby Chaloner <toby.chaloner+git@gmail.com>
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



use strict;

use gv;

use TJPert::model::TaskList;
use TJPert::graphviz::GvTask;


# This package specialises TaskList for output to graphviz


package TJPert::graphviz::GvTaskList;


use Data::Dumper;


use vars qw(@ISA);
@ISA = qw( TJPert::graphviz::GvTask TJPert::model::TaskList  );



# takes a ref to XML from XMLin which is a tasklist.  Could be a list of tasks which is a sub-list of another.

sub new {
    my ( $class, $ref ) = @_;
    my $tl =  TJPert::model::TaskList->new($ref);
    my $pst = TJPert::graphviz::GvTask->new($ref);
    #join the two class hashes into one.
    my $this = {( %{$tl}, %{$pst} )};
    return bless $this, $class;
}






# Overload the method to create a Task, so it creates a GvTask

sub createTask
{
    print "GvTaskList::createTask\n";
    my $self = shift;
    my $task = shift;
    return TJPert::graphviz::GvTask->new($task);
}





# Overload the method to create a TaskList, so it creates a GvTaskList

sub createTaskList
{
    print "GvTaskList::createTaskList\n";
    my $self = shift;
    my $task = shift;
    return TJPert::graphviz::GvTaskList->new($task);
}





# draw recursively all the tasks and dependencies

sub draw {
    print "GvTaskList::draw\n";
#    print Dumper(@_);
    my $self = shift;
    print "GvTaskList::draw processing a ".ref($self)."\n";

    #postscript output
    my $p = shift;

    my $xpos = shift;
    my $ypos = shift;
    my $rhOutputFlags = shift;

    my $task;

    #print "GvTaskList::draw: ". Dumper($self)."\n";
    

    # draw tasks
    foreach $task ( @{ $self->{List} } ) {
	#print "tasks: wbs ".$task->{WBS}."\n";
	#task is responsible for remembering its Gv ID
	print "draw on a ".ref($task)."\n";
	$task->draw( $p, 0,0, $rhOutputFlags);
    }

    print "\n\ndrawing lines between dependents:\n";
    #draw lines between dependents
    my $dep;
    foreach $task ( @{ $self->{List} } )
    {
	print "draw deps on a ".ref($task)."\n";
	#print "deps on ".Dumper($task)."\n";
	#print "taskLists: wbs ".$task->{WBS}."\n";
	if (defined ($task->get_dep()))
	{
       foreach $dep ( @{ $task->get_dep() } )
	{
	    my $tn = $task->get_id();
	    my $dn = $dep->get_id();
	    my $edge = gv::edge($p, $dn, $tn);
	    gv::setv($edge, 'dir', 'forward');
	}
   }
    }

=pod 
    #
    # This part is where the sub-tasks should be output
    #


    
    # cell height
    my $c_h = GvTask::get_task_height() * GvTask->cell_coef();

    # cell width
    my $c_w = GvTask::get_task_width() * GvTask->cell_coef();

    #cell margins
    my $m_x = ( $c_w - GvTask::get_task_width() ) / 2.0;
    my $m_y = ( $c_h - GvTask::get_task_height() ) / 2.0;

    print "cell ht $c_h, cell margin $m_y\n";

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


    }

=cut

}

1;
