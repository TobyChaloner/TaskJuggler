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

use model::TaskList;
use postscript::PsTask;

=pod 

This package specialises TaskList for output to Postscript

=cut

package PsTaskList;



use vars qw(@ISA);
@ISA = qw( TaskList PsTask );


sub new {
    my ( $class, $ref ) = @_;
    my $tl = TaskList->new($ref);
    my $pst = PsTask->new($ref);
    #join the two class hashes into one. Developer: There is a risk that the order is wrong
    my $this = {( %{$tl}, %{$pst} )};
    return bless $this, $class;
}





=pod 

Overload the method to create a Task, so it creates a PsTask

=cut

sub createTask
{
    print "PsTaskList::createTask\n";
    my $self = shift;
    my $task = shift;
    return PsTask->new($task);
}



=pod 

Overload the method to create a TaskList, so it creates a PsTaskList

=cut

sub createTaskList
{
    print "PsTaskList::createTaskList\n";
    my $self = shift;
    my $task = shift;
    return PsTaskList->new($task);
}





=pod 
This is where -ve y is being applied

=cut

# draw recursively all the tasks and dependencies
sub draw {
    print "PsTaskList::draw\n";
#    print Dumper(@_);
    my $self = shift;

    #postscript output
    my $p = shift;

    my $xpos = shift;
    my $ypos = shift;

    my $task;

    # cell height
    my $c_h = PsTask::get_task_height() * PsTask->cell_coef();

    # cell width
    my $c_w = PsTask::get_task_width() * PsTask->cell_coef();

    #cell margins
    my $m_x = ( $c_w - PsTask::get_task_width() ) / 2.0;
    my $m_y = ( $c_h - PsTask::get_task_height() ) / 2.0;

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

=cut

    }

}
