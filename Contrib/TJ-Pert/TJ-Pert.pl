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

use FindBin;
use lib $FindBin::Bin ;
use lib './model';

use postscript::PsProjet;
use graphviz::GvProjet;

use strict;

#use Carp;
#use Data::Dumper;


my $file;
my $input_file;
my $output_file;

my $which_view = "original_postscript";

my $file_format = "eps";


sub usage
{
    print qq 'TJ-Pert.pl <input filename> [-t <fmt>] [-o <out filename>]
-t <output format> - See http://www.graphviz.org/content/output-formats
-o <out filename> - defaults to infilename.<output format>
';
    exit 1;
}







sub processArgs
{
    usage() if (@ARGV == 0);

    $file       = shift @ARGV;
    $input_file = $file;
    #detect original system
    if (@ARGV == 0) 
    {
	return;
    }

    $which_view = "dynamic";	# not using original system
    while (@ARGV)
    {
	my $a = $ARGV[0];
	if (substr($a,0,1) eq "-") #
	{


	    if ($a eq "-o")
	    {
		die "-o <output filename>" if (@ARGV < 2);
		shift @ARGV;
		$output_file = $ARGV[0];
	    }
	    if ($a eq "-t")
	    {
		die "-t <format>" if (@ARGV < 2);
		shift @ARGV;
		$file_format = $ARGV[0];
	    }
	}			#if a - arg
	else 
	{
	    #$offset = $ARGV[0];
	}
	shift @ARGV;
    }				#foreach
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
	$projet = PsProjet->new($projetxml);
    } else
    {
	$projet = GvProjet->new($projetxml);

    }

    # Extract task from xml/perl struct
    $projet->extract_list_task($projetxml);

    $projet->process_tasks;



    print "Creating $output_file\n";

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

	$output_file = $file . "." . $file_format;
    }

    if (!$output_file)
    {
	$output_file = $file . "." . $file_format;
    }

    #arguments to this function are unique to the PsProject object.
    $projet->drawFile($output_file);




