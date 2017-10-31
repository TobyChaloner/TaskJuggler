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

use TJPert::graphviz::GvTaskList;
use TJPert::model::Projet;


package TJPert::graphviz::GvProjet;



# Inheritance
# GvTaskList is before Projet so its functions override the non Specialised functions



use vars qw(@ISA);
@ISA = qw( TJPert::graphviz::GvTaskList TJPert::model::Projet   );



# Because of the multiple inheritance, the hashes of both superclasses need to be joined.
# Currently the joining order is not critical.



sub new {
    my ( $class, $ref ) = @_;
    my $projet = TJPert::model::Projet->new($ref);
    my $psTaskList = TJPert::graphviz::GvTaskList->new($ref);
    #join the two class hashes into one.
    my $this = {( %{$psTaskList}, %{$projet} )};
    $this->{format} = 'png'; #default
    return bless $this, $class;
}






# takes a string which is a valid graphviz format name eg
# png, plain
sub set_format
{
    my $self = shift;
    ($self->{format}) = @_;
}









# The drawing in this routine are default bottom left orientated.
# However the y axis is reversed, before the pert components are laid
# out.  If they are not visible, its becaus they're below the page.
#
# The arguments to this function are different to the 'draw' function arguments, so
# this should be named differently.

sub drawFile {
    my $self = shift;

    my $output_file = shift;
    my $rhOutputFlags = shift;


    my $g=gv::graph('gg');

    gv::setv($g, 'rankdir', "LR");


    #draw cartouche
    my $cartouche_text = "";
    $cartouche_text .= $self->get_name().", version ".$self->get_version()."\n";


    # start, end , now
    $cartouche_text .= "Start: ". $self->get_plan_start()."\n";
    $cartouche_text .= "Now: ". $self->get_plan_now()."\n";
    $cartouche_text .= "End: ". $self->get_plan_end()."\n";
    my $node = gv::node($g, "top-node");
    gv::setv($node, 'label',$cartouche_text);
    gv::setv($node, 'shape','box');
#    gv::setv($node, 'color','blue');

# a ajouter : nom du projet + info du projet voir dtd

    $self->SUPER::draw( $g, 0 , 0 , $rhOutputFlags);

    my $format = $self->{format};
    gv::layout($g, 'dot');
    gv::render($g, $format, $output_file);
    gv::rm($g);

}

1;
