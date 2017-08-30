######################################################################## 
# Copyright (c) 2017 by Toby Chaloner
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

CVersion of PostScript::Simple

 Assuming $p->{pspages} is an array.  In earlier versions, it was a string

=cut




use strict;

use gv;

use TJPert::graphviz::GvTaskList;
use TJPert::model::Projet;


package TJPert::graphviz::GvProjet;

=pod 

Inheritance

GvTaskList is before Projet so its functions override the non Specialised functions

=cut

use vars qw(@ISA);
@ISA = qw( TJPert::graphviz::GvTaskList TJPert::model::Projet );

=pod 

Because of the multiple inheritance, the hashes of both superclasses need to be joined.
Currently the joining order is not critical.

=cut

sub new {
    my ( $class, $ref ) = @_;
    my $projet = Projet->new($ref);
    my $psTaskList = GvTaskList->new($ref);
    #join the two class hashes into one. Developer: There is a risk that the order is wrong
    my $this = {( %{$psTaskList}, %{$projet} )};
    return bless $this, $class;
}





=pod 

The drawing in this routine are default bottom left orientated.
However the y axis is reversed, before the pert components are laid
out.  If they are not visible, its becaus they're below the page.

The arguments to this function are different to the 'draw' function arguments, so
this should be named differently.

=cut

sub drawFile {
    print "PsProjet::draw\n";

    my $self = shift;
#print Dumper($self);

    my $output_file = shift;



    my $g=gv::graph('gg'); ########################

    gv::setv($g, 'rankdir', "LR");

=pod 
    


    my $marginx = 1.0; # 1cm
    my $marginy = 1.0; # 1cm
    my $cartouchex = 7.0; # 10cm
    my $cartouchey = 2.0; # 4cm

    #
    # Normal Y AXIS 
    #
    # +ve Y values are on the page


    # calculate bouding box
    my $bx =
      ( $self->get_max_col + 1 ) * GvTask->get_task_width() * GvTask->cell_coef + 2 * $marginx;
    my $by = ( $self->get_height ) * GvTask->get_task_height() * GvTask->cell_coef + 2 * $marginy + $cartouchey;

    # create postscript file
    my $p =
      new PostScript::Simple( units => "cm", xsize => $bx, ysize => $by,
        eps => 1 );

    $p->setfont( "Times-Roman-iso", 9 ) or die $p->err();

=pod 

    #draw cartouche
#    $p->setlinewidth(0.1);
#    $p->box( 0, 0, $bx, $by);
#    $p->setlinewidth(0.025);
    $p->box( $marginx , $marginy, 
	     $bx - $marginx , $by - $marginy) or die $p->err();
	
    my $lineheight = $cartouchey / 4.0;
    my $colwidth = $cartouchex / 4.0;
    $p->box( $marginx , $marginy, 
	     $marginx + $cartouchex , $marginy + $cartouchey) or die $p->err();
    # title + version
    $p->line( $marginx, $marginy + $lineheight,
	     $marginx + $cartouchex, $marginy + $lineheight) or die $p->err();
#    $p->text( $marginx +  $cartouchex / 2.0, $marginy + $lineheight / 3.5,
#        $self->get_name()." ".$self->get_version(), 'centre'
    #The centre arg appears to have moved
    $p->text( {align => 'centre'}, $marginx +  $cartouchex / 2.0, $marginy + $lineheight / 3.5,
        $self->get_name()." ".$self->get_version()
    ) or die $p->err();

    # start, end , now
    $p->line( $marginx, $marginy + 2.0 * $lineheight,
	     $marginx + $cartouchex, $marginy + 2.0 * $lineheight) or die $p->err();
    $p->line( $marginx, $marginy + 3.0 * $lineheight,
	     $marginx + $cartouchex, $marginy + 3.0 * $lineheight) or die $p->err();
    $p->line( $marginx + $colwidth, $marginy + $lineheight, 
	      $marginx + $colwidth, $marginy + $cartouchey) or die $p->err();
    $p->text(  {align => 'centre'}, $marginx + $colwidth / 2.0, $marginy + $lineheight / 3.5 + $lineheight, "End") or die $p->err();
    $p->text(  {align => 'centre'}, $marginx + $colwidth / 2.0, $marginy + $lineheight / 3.5 + 2 * $lineheight, "Start") or die $p->err();
    $p->text( {align => 'centre'}, $marginx + $colwidth / 2.0, $marginy + $lineheight / 3.5 + 3 * $lineheight, "Now") or die $p->err();
    $p->text( {align => 'centre'}, $marginx + 2.5 *$colwidth, $marginy + $lineheight / 3.5 + $lineheight, $self->get_end()) or die $p->err();
    $p->text(  {align => 'centre'},$marginx + 2.5 *$colwidth, $marginy + $lineheight / 3.5 + 2 * $lineheight, $self->get_start()) or die $p->err();
    $p->text(  {align => 'centre'},$marginx + 2.5 *$colwidth, $marginy + $lineheight / 3.5 + 3 * $lineheight, $self->get_now()) or die $p->err();

# a ajouter : nom du projet + info du projet voir dtd

=cut

    #
    # (WAS) Invert the Y AXIS
    #
    # -ve Y values are on the page
    
    ###TOBY PROBLEM IS HERE
    # inverse y axis
    #print ${ $p->{pspages} }."+++\n";
    #BUT following is being dumped at end of document.
    #push @{ $p->{pspages} }, [["ps","$marginx u $by $marginy sub u translate \n"]];
    #pspages implementation is now an array of strings
    #assume code is...
    ##  foreach my $page (@{$self->{pspages}}) {
    ##    push @$doc, $self->_buildpage($page);


#    $self->SUPER::draw( $p, 0 , -$by );
    $self->SUPER::draw( $g, 0 , 0 );

#    $p->output($output_file);

    
    gv::layout($g, 'dot');
    gv::render($g, 'png', $output_file); #####################
    
    gv::rm($g);

}

1;
