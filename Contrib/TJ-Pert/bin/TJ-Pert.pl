#!/usr/bin/perl
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
use 5.008;
use strict;


BEGIN {

our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION = '3.0';
}


use FindBin;
use lib $FindBin::Bin ;
#use lib './model';

use TJPert::postscript::PsProjet;
use TJPert::graphviz::GvProjet;

use strict;

#use Carp;
use Data::Dumper;


my $file;
my $input_file;
my $output_file;

my $which_view = "original_postscript";

my $file_format = "eps";


sub usage
{
    print qq 'TJ-Pert.pl [-t <fmt>] [-o <out filename>] <input filename>
-t <output format> - See http://www.graphviz.org/content/output-formats
-o <out filename> - defaults to infilename.<output format>
';
    exit 1;
}







sub processArgs
{
    usage() if (@ARGV == 0);

    #detect original system
    if (@ARGV == 1)
    {
	$file       = shift @ARGV;
	$input_file = $file;
	return;
    }

    $which_view = "dynamic";	# not using original system
    #
    # Go through all but the last argument which is the file to process
    #
    while (@ARGV-1)
    {
	my $found = 0;
	my $a = $ARGV[0];
	if (substr($a,0,1) eq "-") #
	{


	    if ($a eq "-o")
	    {
		die "-o <output filename>" if (@ARGV < 2);
		shift @ARGV;
		$output_file = $ARGV[0];
		$found++;
	    }
	    if ($a eq "-t")
	    {
		die "-t <format>" if (@ARGV < 2);
		shift @ARGV;
		$file_format = $ARGV[0];
		$found++;
	    }
	}			#if a - arg
	#detect an unsupported argument
	usage() if (!$found);
	shift @ARGV;
    }				#foreach
    #if the last arg was eaten, by eg -t, then there is an issue
    usage() if (@ARGV == 0);

    #Last arg is the filename
    $file       = shift @ARGV;
    $input_file = $file;
}


processArgs();





    my $projetxml =
    XMLin( $input_file, forcearray => [ "Task", "TaskID", "Previous" ] );

    #print Dumper($projetxml);
    #exit;

    # create project
    print "Analysing $input_file\n";

    my $projet;
    if ($which_view eq "original_postscript")
    {
	$projet = TJPert::postscript::PsProjet->new($projetxml);
    } else
    {
	$projet = TJPert::graphviz::GvProjet->new($projetxml);

    }

    # Extract task from xml/perl struct
    $projet->extract_list_task($projetxml);

    $projet->process_tasks;




    if ($which_view eq "original_postscript")
    {
	# New suffix for xml file: tjx
	# keep the old one in case...
	if ($file =~ /tjx$/)
	{
	    $file =~ s/tjx$//;
	} else
	{
	    $file =~ s/xml$//;
	}

	$output_file = $file . $file_format;
    }

    if (!$output_file)
    {
	$output_file = $file . "." . $file_format;
    }

    print "Creating $output_file\n";

    #arguments to this function are unique to the PsProject object.
    $projet->drawFile($output_file);




__END__

=head1 NAME

    TJ-Pert.pl - Illustrate a MSP XML format file from TaskJuggler to a pert diagram

=head1 SYNOPSIS

    TJ-Pert.pl [-t <fmt>] [-o <out filename>] <input filename>


     Options:
      -t <output format> - See http://www.graphviz.org/content/output-formats
      -o <out filename> - defaults to infilename.<output format>


=head1 OPTIONS

=over 8

=item B<-t output_format>

    Sets the output format eg png or plain

=item B<-o out_filename>

    Sets the output file path and filename

=back

=head1 DESCRIPTION

    TJ-Pert.pl will take the input file and create a pert chart with it.  A pert chart is a project diagram showing the task dependencies as linked nodes.  The XML format is written by TaskJuggler in its Microsoft(tm) Project XML format (MSP).

=pod


An example TaskJuggler file to produce the output is:-

 project k2 "a sequence"  2016-07-19 +3m {
 timeformat "%d-%m-%Y"
 now 2016-07-25
 }

 resource al "Albert"
 resource be "Bertie"

 task none "FirstTask" {
     start 2016-07-20
     end 2016-07-20
     complete 48
 }


 task middle "50% complete" {
     effort 1d
     depends none
     allocate al
     complete 49
 }

 export pertexportn "simpleTasksTestData.msp" {
  formats mspxml
  hideresource 0
 }


=cut
