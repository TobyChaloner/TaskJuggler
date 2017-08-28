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
use strict;


use PostScript::Simple 0.09;



use Task;

=head1 PSTASK

PsTask - Outputs a Task as Postscript

=head1 DESCRIPTION

This class draws a task in a box.  The task is annotated with start and end dates and the progress.  Milestones have only a single date.

=head2 Methods

new
draw

=cut

package PsTask;




use vars qw(@ISA);
@ISA = qw( Task );



# Parameters (Globals)

my $task_width  = 4;      # 4cm
my $task_height = 1.5;    # 1,5 cm
my $cell_coef   = 1.3;



sub new {
    my ( $class, $ref ) = @_;
    my $parent = Task->new($ref);
    return bless ($parent);
}



#get functions

sub get_task_width {
    return $task_width;
}

sub get_task_height {
    return $task_height;
}

sub cell_coef {
    return $cell_coef;
}




=over 12

=item C<draw(postscriptObject, x, y)>

 The x 
 The y is the bottom corner.  so rest drawn above.

=cut

sub draw {
    my $self   = shift;
    my $out_ps = shift;
    my $x_pos  = shift;
    my $y_pos  = shift;

    #print Dumper($self);
    #  print $x_pos, " ",$y_pos, "\n";

=pod 

    # blank zone
    $out_ps->setcolour("white") or die $out_ps->err();
    $out_ps->box( {filled => 1}, $x_pos, $y_pos, $x_pos + $task_width, $y_pos + $task_height) or die $out_ps->err();

=cut

    # draw rectangle surrounding this task
    $out_ps->setcolour("black") or die $out_ps->err();
    $out_ps->box( $x_pos, $y_pos, $x_pos + $task_width, $y_pos + $task_height ) or die $out_ps->err();



    my $x3          = $task_width / 3.0;
    my $y4          = $task_height / 4.0;
    my $text_margin = $y4 / 4.0;

    if ($self->is_milestone() )
    {
	#milestone has a top central box
	#in which the sole date goes
	#there are no lower boxes
	$out_ps->box($x_pos + $x3, $y_pos + 3 * $y4, $x_pos + 2 * $x3, $y_pos + $task_height) or die $out_ps->err();
    } else
    {
	# draw each rectangle inside
	#draws at top, 3 boxes. left:Start Date, right: end Date.
	#at bottom, 3 boxes.  Not sure what for.
	$out_ps->line( $x_pos, $y_pos + $y4, $x_pos + $task_width, $y_pos + $y4 ) or die $out_ps->err();
	$out_ps->line( $x_pos, $y_pos + 3 * $y4, $x_pos + $task_width,
		       $y_pos + 3 * $y4 ) or die $out_ps->err();
	$out_ps->line( $x_pos + $x3, $y_pos, $x_pos + $x3, $y_pos + $y4 ) or die $out_ps->err();
	$out_ps->line( $x_pos + 2 * $x3, $y_pos, $x_pos + 2 * $x3, $y_pos + $y4 ) or die $out_ps->err();
	$out_ps->line( $x_pos + $x3, $y_pos + 3 * $y4, $x_pos + $x3,
		       $y_pos + $task_height ) or die $out_ps->err();
	$out_ps->line(
		      $x_pos + 2 * $x3, $y_pos + 3 * $y4,
		      $x_pos + 2 * $x3, $y_pos + $task_height
		     ) or die $out_ps->err();

    }

=pod 

    # draw progress bar (% complete)
    #drawn over the three bottom boxes
    $out_ps->setcolour("grey80") or die $out_ps->err();
    $out_ps->box( {filled => 1}, $x_pos, 
		  $y_pos + $y4, 
		  $x_pos + $task_width *  $self->get_percent_complete() / 100.0,
		  $y_pos + 2 * $y4
		) or die $out_ps->err();
    $out_ps->setcolour("black") or die $out_ps->err();

=cut

    print "draw: Percent Complete (SUPPRESSED): ".$self->get_percent_complete()."\n";

    # write text
    # In the example from V2, this was text, in the version downloaded,
    # This was just the ID.  Not sure why.
    #WEAKNESS: A long string is going to cause problems.
    # Task ID
#   my $text = $self->get_id();
    my $text = $self->get_task_name();
    $out_ps->text( {align => 'centre'},
        $x_pos + $task_width / 2.0, $y_pos + 2 * $y4 + $text_margin,
        $text
		 ) or die $out_ps->err();

#print "id: ".$self->get_id()."\n";


=pod 

        The following dates are available.  They are NOT in the unix epoch LONG INT which the original xml had
          'ManualFinish' => '2017-08-23T17:00:00',
          'ActualFinish' => '2017-08-23T17:00:00',
          'ManualStart' => '2017-08-23T09:00:00',
          'ConstraintDate' => '2017-08-23T09:00:00',
          'Finish' => '2017-08-23T17:00:00',
          'Start' => '2017-08-23T09:00:00',
          'ActualStart' => '2017-08-23T09:00:00',

        The following percentage completes are available
          'PercentComplete' => '0',
          'PercentWorkComplete' => '0',

=cut

    #we want to show the date this is planned to start, or the date it did start.  This was different in the v2 XML
    # Start
    my $start = POSIX::strftime( "%x", localtime( $self->get_start() ) );


   if ($self->is_milestone() )
	{
    $out_ps->text( {align => 'centre'},
        $x_pos + $x3 + $x3 / 2.0, $y_pos + 3 * $y4 + $text_margin,
        $start
    ) or die $out_ps->err();
    }
    else
    {
    $out_ps->text( {align => 'centre'},
        $x_pos + $x3 / 2.0, $y_pos + 3 * $y4 + $text_margin,
        $start
    ) or die $out_ps->err();
    }
    # End

    my $end = POSIX::strftime( "%x", localtime( $self->get_end() ) );

   if (!$self->is_milestone() )
   {
       $out_ps->text( {align => 'centre'}, $x_pos + 2 * $x3 + $x3 / 2.0,
		      $y_pos + 3 * $y4 + $text_margin, $end ) or die $out_ps->err();
   }
}


=back

1;
