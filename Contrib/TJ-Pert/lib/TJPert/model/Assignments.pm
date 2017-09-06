######################################################################## 
# Copyright (c) 2017 by Toby Chaloner toby.chaloner+github@gmail.com
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

Format of the MSProject XML produced by TJ

This is only a partial - where I need it.
       'Resource' => [
            {
           'Name' => 'Albert',
           'OvertimeRate' => '0.0',
           'Initials' => 'al',
           'StandardRate' => '0.0',
           'CalendarUID' => '1',
           'Type' => '1',
           'UID' => '1',
           'MaxUnits' => '1.0'
            },
...

    'Assignments' => {
         'Assignment' => [
             {
            'finish' => '2017-08-21T17:00:00',
            'Units' => '1.0',
            'UID' => '0',
            'WorkContour' => '8',
            'Cost' => '100.0',
            'TimephasedData' => {
                 'Finish' => '2017-08-21T16:59:59',
                 'Type' => '1',
                 'UID' => '0',
                 'Start' => '2017-08-21T09:00:00',
                 'Unit' => '2',
                 'Value' => 'PT8H0M0S'
                  },
            'ResourceUID' => '1',
            'TaskUID' => '1',
            'PercentWorkComplete' => '0',
            'start' => '2017-08-21T09:00:00'
             },

...

=cut





#use XML::Simple;



use strict;



#use TJPert::model::Task qw(set_lin add_lin);



package TJPert::model::Assignments;


use Carp;
use Data::Dumper;


#use vars qw(@ISA);
#@ISA = qw( TJPert::model::Task );



=pod

Passed in a reference to the MSP MS Project raw XML

=cut

sub new {
    my ( $class, $ref ) = @_;


    my $this->{xml}     = $ref;
    $this->{taskResource} = {}; #lookup task to assignment
    bless $this, $class;

    $this->load_cache();

    return $this;
}


=pod 

returns the name of the entities assigned to this task id

The task to assignment looks like
$this->{taskAssignment}->{$taskId}->"Resource(s)"
If the task already has a resource, the new one is added to the end, comma separated 


=cut

sub get_assignment
{
    my $this = shift;
    my $taskUID = shift;
    return $this->{taskAssignment}->{$taskUID};
}


###########################

=pod

walk the xml and grab interesting info links

=cut

sub load_cache
{
    my $this = shift;
    #get the taskId to assignment refs

    #load the resources into a hash
    #only need them temporarily in a hash
    my %resources;
    #foreach is working on an array of hashes
    #each hash is the ref I want
    #there is one hash per resource.
    foreach my $resource ( @{ $this->{xml}->{Resources}->{Resource} } )
    {
	$resources{$resource->{UID}} = $resource->{Name};
    }
#    print (Dumper(%resources));
    


    #foreach is working on an array of hashes
    #each hash is the ref I want
    #there is one hash per task.  Each identifies its resource
    #WEAKNESS what if multiple resources assigned
    foreach my $assignment ( @{ $this->{xml}->{Assignments}->{Assignment} } )
    {
	print (Dumper($assignment));
	$this->add_taskToResource($assignment->{TaskUID}, $resources{$assignment->{ResourceUID}} );
    }
}


=pod

The task to assignment looks like
$this->{taskAssignment}->{$taskId}->"Resource(s)"
If the task already has a resource, the new one is added to the end, comma separated 

=cut

sub add_taskToResource
{
    my $this = shift;
    my ($taskUID, $resourceName) = (@_);
    print "tr $taskUID, $resourceName\n";
    if (exists $this->{taskAssignment}->{$taskUID})
    {
	$this->{taskAssignment}->{$taskUID} .= ",".$resourceName;
    }
    else
    {
	$this->{taskAssignment}->{$taskUID} = $resourceName;
    }
    print "tr- ".$this->{taskAssignment}->{$taskUID}."\n";
    
}


1;
