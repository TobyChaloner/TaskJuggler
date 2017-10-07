######################################################################## 
# Copyright (c) 2017 Toby Chaloner
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


use POSIX;



use gv;


use TJPert::model::Task;


# GvTask - Outputs a Task as Postscript


# This class draws a task in a box.  The task is annotated with start and end dates and the progress.  Milestones have only a single date.

package TJPert::graphviz::GvTask;




use vars qw(@ISA);
@ISA = qw(TJPert::model::Task);



# Parameters (Globals)

my $task_width  = 4;      # 4cm
my $task_height = 1.5;    # 1,5 cm
my $cell_coef   = 1.3;



# Takes a ref to a hash which is a task.
# The task is inputed from XML by XMLinthe XML

sub new {
    my ( $class, $ref ) = @_;
    my $parent = TJPert::model::Task->new($ref);
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




 # draw
 # The x 
 # The y is the bottom corner.  so rest drawn above.

sub draw {
    my $self   = shift;
    my $gv = shift;
    my $x_pos  = shift;
    my $y_pos  = shift;
    my $rhOutputFlags = shift;

    #print Dumper($self);

    # The name may need to be split if its long
    # TODO

    # Baseline TODO

    # Completeness TODO

    my $name = $self->get_task_name();

    my $start = POSIX::strftime( "%x", localtime( $self->get_start() ) );
    if ($self->is_milestone() )
    {
	#milestone
	my $node = gv::node($gv, $self->get_id());
	gv::setv($node, 'label',$name."\n".$start);######################## \n is wrong
	gv::setv($node, 'shape','diamond'); #or plaintext
        #add reference to gv self into the objects hash
#	$self->{'gv_node'} = \$node;
    }
    else
    {
	#normal task
	my $info = "";
	$info .= $self->get_allocated() if ($rhOutputFlags->{who});
#print "info $info i\n";
	my $end = POSIX::strftime( "%x", localtime( $self->get_end() ) );
	my $html = qq'< 
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4"> 
 <TR>
  <TD>'.$start.'</TD>
  <TD></TD>
  <TD>'.$end.'</TD>
 </TR>
 <TR> 
  <TD COLSPAN="3">'.$name.'</TD>
 </TR>
 <TR> 
  <TD COLSPAN="3">'.$info.'</TD>
 </TR> 
</TABLE> >';

	my $node = gv::node($gv, $self->get_id());
	gv::setv($node, 'label',$html);
	gv::setv($node, 'shape','none'); #or plaintext
        #add reference to gv self into the objects hash
#	$self->{'gv_node'} = \$node;

    }




=pod 

    # draw progress bar (% complete)
    #drawn over the three bottom boxes
    $out_ps->setcolour("grey80") or die $out_ps->err();
    print "draw: Percent Complete (SUPPRESSED): ".$self->get_percent_complete()."\n";


=cut


}

1;
