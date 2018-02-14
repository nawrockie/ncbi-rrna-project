#!/usr/bin/perl -w
# the first line of perl code has to be as above
#
# Author: Alejandro Schaffer
#
#
# Code to record which taxonomy ancestor representatives are covered in a set of sequences  
# 
# 
#
# Usage: summarize_taxonomy_representatives.pl \
#        --input_summary <input file> \
#        --input_taxa <input file with NCBI's taxonomy tree as a list of edges>  \
#        --input_reps <taxonomy representatives whose pesence we want to detect> \
#        --outfile <output file with representative for each taxid>
#        --out_summary <output file with counts for each taxon> 

use strict;
use warnings;
use Getopt::Long;

require "epn-options.pm";


# input/output file names
my $input_file;                #input file that summarizes vecscreen matches 
my $input_taxa_file;           #input file with taxonomy in a tab-delimited four-column format 
                               #(taxid, parent taxid, rank, depth where the depth of the root is 1)
my $input_reps;                #input file of representative taxids
my $output_file;               #output file with one column added showing the name of taxonomy ancestor at the specified level
my $output_summary_file;       #output file with counts for each taxon

# variables used in processing input
my $nextline;  #one line of an input file
my $m;         #loop index
my @fields;    #entries in one row
my $accession; #accession part of an identifier  

# The following five column indices are for the $input_file with 
# vecscreen matches passed in as the argument --input_summary
my $ACC_COLUMN          = 0; #the column with the identifier
my $TAXID_COLUMN        = 1; #the column with the taxid of the sequence represented by the identifier
my $NAME_COLUMN         = 2; #the column with the name of the taxid

# special taxon constants
my $TAXONOMY_ROOT        = 1;     #taxon to use as a default when no other taxon fits the situation
my $BACTERIA_TAXON       = 2;     #taxon that is the root of all Bacteria

# variables used in constructing output
my $output_taxid;        # taxonomic ancestor of interest as a number
my $output_taxon_name;   # name of output_taxid

# data structures for keeping track of information on taxids and counts
my %genome_match_taxon;        # hash of results seen before
my %taxid_to_name;             #hash to map a taxid of a representative to its biological name
my %taxid_to_index;            #hash to map a taxid to inices in the following arrays  
my @taxid_numbers;             #stores numerical taxids in order
my @taxid_names;               #stores taxids by name in order
my @taxid_counts;              #stores count of sequences for each taxid in order
my $num_taxids = 0;            #number of distinct representatives
my $i;                         #loop index

# hashes mapping taxon to other information
my %taxonomy_parent;              # hash, maps a taxon to its parent
my %taxonomy_level;               # hash, maps a taxon to its level (a.k.a. depth) in the tree, where the level of the root is 1
my %rank_hash;                    # hash, maps each taxon to its taxonomic rank (e.g., phylum)
my %belongs_in_bacteria;          # hash, maps each taxon to 0 or 1 depending on whether it belongs in bacteria (1)

# variables used for processing the main input file, the vecscreen summary file
my $num_columns_input = 3;  # number of columns in input 
my $one_taxid;              # taxid (in the taxonomy tree) of one query sequence in vecscreen summary
my $one_name;               # name of taxid

my @taxonomy_ranks = ("superkingdom","kingdom","phylum","class","order","family","tribe","genus"); #these are the ranks for which matches to UniVec entries have been collected

my $num_taxonomy_ranks = scalar(@taxonomy_ranks); # size of @taxonomy_ranks
my $rank_index;        #loop index for iteration in @taxonomy_ranks
my $one_rank;          #entry in @taxonomy_ranks

# variables used in special debugging mode
my $DEBUG             = 0;  # set to 1 to enter debug mode

# variables for dealing with options (epn-options.pm)
my %opt_HH           = ();
my @opt_order_A      = ();
my %opt_group_desc_H = ();

# Add all options to %opt_HH and @opt_order_A.
# This section needs to be kept in sync (manually) with the &GetOptions call below
# The opt_Add() function is the way we add options to %opt_HH.
# It takes values of for each of the 2nd dim keys listed above.
$opt_group_desc_H{"1"} = "basic options";
#       option                         type      default group   requires incompat preamble-outfile                                                                help-outfile
opt_Add("-h",                          "boolean",0,          0,    undef, undef,   undef,                                                                          "display this help",                                       \%opt_HH, \@opt_order_A);
opt_Add("--input_summary",             "string", undef,      1,    undef, undef,   "input file of identifiers",                                                    "File name <s> of identifiers",                      \%opt_HH, \@opt_order_A);
opt_Add("--input_taxa",                "string", undef,      1,    undef, undef,   "input file with NCBI's taxonomy",                                              "File name <s> with NCBI's taxonomy",         \%opt_HH, \@opt_order_A);
opt_Add("--input_reps",               "string", undef,      1,    undef, undef,   "input file of representative taxids",                                           "File <s> of desired taxonomy epresetatives", \%opt_HH, \@opt_order_A);
opt_Add("--outfile",                   "string", undef,      1,    undef, undef,   "output file to create",                                                        "Name <s> of output file to create",                       \%opt_HH, \@opt_order_A);
opt_Add("--out_summary",                   "string", undef,      1,    undef, undef,   "output file for summary",                                                        "Name <s> of output file for summary",                       \%opt_HH, \@opt_order_A);


my $synopsis = "summarize_taxonomy_representatives.pl: Find which ancestor taxids of interest are covered in a set of input sequences\n";
my $usage    = "Usage:\n\n"; 
$usage      .= "\tsummarize_taxonomy_representatives.pl \\\n";
$usage      .= "\t--input_summary <input file of identifiers> \\\n"; 
$usage      .= "\t--input_taxa <input file with NCBI's taxonomy> \\\n";
$usage      .= "\t--input_reps <file of desired taxonomy representatives> \\\n";
$usage      .= "\t--outfile <output file for each sequence>\\\n";
$usage      .= "\t--out_summary <output file for each representative>\n\n";
$usage      .= "\nFor example:\n";
$usage      .= "summarize_taxonomy_representatives.pl --input_summary test_accessions.txt "; 
$usage      .= "--input_taxa taxonomy.txt ";
$usage      .= "--input_reps reps.txt ";
$usage      .= "--outfile output_by_sequence.txt\n";
$usage      .= "--out_summary output_by_taxon.txt\n";

# This section needs to be kept in sync (manually) with the opt_Add() section above
my %GetOptions_H = ();
my $options_okay =
    &GetOptions('h'                            => \$GetOptions_H{"-h"},
                'input_summary=s'              => \$GetOptions_H{"--input_summary"},
                'input_taxa=s'                 => \$GetOptions_H{"--input_taxa"},
                'input_reps=s'                 => \$GetOptions_H{"--input_reps"},
                'outfile=s'                    => \$GetOptions_H{"--outfile"},
                'out_summary=s'                => \$GetOptions_H{"--out_summary"});

# print help and exit if necessary
if((! $options_okay) || ($GetOptions_H{"-h"})) {
    opt_OutputHelp(*STDOUT, $synopsis . $usage, \%opt_HH, \@opt_order_A, \%opt_group_desc_H);
    if(! $options_okay) { die "ERROR, unrecognized option;"; }
    else                { exit 0; } # -h, exit with 0 status
}

# set options in %opt_HH
opt_SetFromUserHash(\%GetOptions_H, \%opt_HH);

# validate options (check for conflicts)
opt_ValidateSet(\%opt_HH, \@opt_order_A);

# define file names
$input_file        = opt_Get("--input_summary", \%opt_HH);
$input_taxa_file           = opt_Get("--input_taxa", \%opt_HH);
$input_reps                = opt_Get("--input_reps", \%opt_HH);
$output_file               = opt_Get("--outfile", \%opt_HH);
$output_summary_file       = opt_Get("--out_summary", \%opt_HH);

# die if any of the required options were not used
my $errmsg = undef;
if(! defined $input_file)        { $errmsg .= "ERROR, --input_summary option not used.\n"; }
if(! defined $input_taxa_file)   { $errmsg .= "ERROR, --input_taxa option not used.\n"; }
if(! defined $input_reps)        { $errmsg .= "ERROR, --input_reps option not used.\n"; }
if(! defined $output_file)       { $errmsg .= "ERROR, --outfile option not used.\n"; }
if(! defined $output_summary_file)       { $errmsg .= "ERROR, --out_summary option not used.\n"; }
if(defined $errmsg) { 
  die $errmsg . "\n$usage\n";
}


# open output files
open(SUMMARY, "<", $input_file) or die "Cannot open 1 $input_file for input\n"; 
open(OUTPUT,  ">", $output_file)        or die "Cannot open 2 $output_file for output\n";
open(COUNTS,  ">", $output_summary_file)        or die "Cannot open 3 $output_summary_file for output\n"; 

# process input files and store the relevant information 
$num_taxids = process_representatives($input_reps);
process_taxonomy_tree($input_taxa_file);


######################################################################
#
# Process the summary input file, one line at a time. 
#
$nextline = <SUMMARY>; #skip header
while(defined($nextline = <SUMMARY>)) {
    chomp($nextline);
    # default initialization of three output fields
    $output_taxid = $TAXONOMY_ROOT;
    @fields = split /\t/, $nextline;
    $accession   = $fields[$ACC_COLUMN];
    $one_taxid   = $fields[$TAXID_COLUMN];
    $one_name = $fields[$NAME_COLUMN];

    # output original information from input summary file ($input_file)
    for($i = 0; $i < $num_columns_input; $i++) {
	print OUTPUT "$fields[$i]\t";
    }
    check_print_reps($one_taxid);
}
close (SUMMARY);
close (OUTPUT);
for ($i=1; $i <= $num_taxids; $i++) {
    print COUNTS "$taxid_numbers[$i]\t$taxid_names[$i]\t$taxid_counts[$i]\n";
}
close (COUNTS);
     

################################################
# SUBROUTINES
################################################
# 
#
# List of subroutines:
# process_taxonomy_tree();
# process_representatives();
# 
# check_print_reps(): 
#
################################################
# Subroutine: process_taxonomy_tree()
# Synopsis: reads a file that includes NCBI's taxonomy information in four columns (taxon, parent taxon, rank, level)
#
# Args: $taxonomy_information_file
#
# Returns: nothing

sub process_taxonomy_tree {

    my $sub_name = "process_taxonomy_tree()";
    my $nargs_exp = 1;
    if(scalar(@_) != $nargs_exp) { die "ERROR $sub_name entered with wrong number of input args"; }

    my ($local_taxonomy_file) = @_;
    my $local_nextline; #one line of taxonomy information
    my @local_fields;   #split of one line of taxonomy information
    my $local_TAXID_COLUMN       = 0;
    my $local_PARENT_COLUMN      = 1;
    my $local_FORMAL_RANK_COLUMN = 2;
    my $local_LEVEL_COLUMN       = 3;
    my $local_BACTERIA_COLUMN       = 4;

    open(TAXONOMY, "<", $local_taxonomy_file) or die "Cannot open $local_taxonomy_file for input in $sub_name\n"; 
    
    while(defined($local_nextline = <TAXONOMY>)) {
	chomp($local_nextline);
	@local_fields = split /\t/, $local_nextline;
	$taxonomy_parent{$local_fields[$local_TAXID_COLUMN]} = $local_fields[$local_PARENT_COLUMN];
	$taxonomy_level{$local_fields[$local_TAXID_COLUMN]}  = $local_fields[$local_LEVEL_COLUMN];
	$belongs_in_bacteria{$local_fields[$local_TAXID_COLUMN]}  = $local_fields[$local_BACTERIA_COLUMN];
        $rank_hash{$local_fields[$local_TAXID_COLUMN]} = $local_fields[$local_FORMAL_RANK_COLUMN];
    }
    close(TAXONOMY);
}

################################################
# Subroutine: process_representatives()
# Synopsis: reads a file that includes two columns (taxon, name) and stores that mapping in the hash taxid_to_name
#
# Args: $taxonomy_rep_file
#
# Returns: nothing

sub process_representatives {

    my $sub_name = "process_representatives()";
    my $nargs_exp = 1;
    if(scalar(@_) != $nargs_exp) { die "ERROR $sub_name entered with wrong number of input args"; }

    my ($local_reps_file) = @_;
    my $local_nextline; #one line of taxonomy information
    my @local_fields;   #split of one line of taxonomy information
    my $local_TAXID_COLUMN       = 0;
    my $local_NAME_COLUMN      = 1;
    my $local_num_taxids = 0;
    
    open(REPS, "<", $local_reps_file) or die "Cannot open $local_reps_file for input in $sub_name\n"; 
    
    while(defined($local_nextline = <REPS>)) {
	chomp($local_nextline);
	@local_fields = split /\t/, $local_nextline;
        $local_num_taxids++;
	$taxid_to_name{$local_fields[$local_TAXID_COLUMN]} = $local_fields[$local_NAME_COLUMN];
	$taxid_to_index{$local_fields[$local_TAXID_COLUMN]} = $local_num_taxids;
	$taxid_numbers[$local_num_taxids] = $local_fields[$local_TAXID_COLUMN];
	$taxid_names[$local_num_taxids] = $local_fields[$local_NAME_COLUMN];
	$taxid_counts[$local_num_taxids] = 0;
    }
    close(REPS);
    return($local_num_taxids);
}



# Subroutine: check_print_reps()
# Synopsis: given a taxon, find and print any representatives that are ancestors;
#           it returns number of representatives found
#
# Args: $local_taxon
#       
#
# Returns: the number of representatives found

sub check_print_reps {

    my $sub_name = "check_print_reps()";
    my $nargs_exp = 1;
    if(scalar(@_) != $nargs_exp) { die "ERROR $sub_name entered with wrong number of input args"; }

    my ($local_taxon) = @_;
    my $local_ancestor; #one line of taxonomy information
    my $local_num_found = 0;
    
    if (!defined($taxonomy_parent{$local_taxon})) {
        print STDERR "Taxid $local_taxon is not in the taxonomy tree, the tree likely needs to be updated\n";
	return(0);
    }
    $local_ancestor = $local_taxon;
    while ((1 != $local_ancestor)) {
	if (defined($taxid_to_name{$local_ancestor})) {
	    print OUTPUT "$taxid_to_name{$local_ancestor}\n";
	    $taxid_counts[$taxid_to_index{$local_ancestor}]++;
	    $local_num_found++;
	    last; #exit out of while loop
	}
        $local_ancestor = $taxonomy_parent{$local_ancestor};
    }
    if (0 == $local_num_found) {
	print OUTPUT "Unrecognized\n";
    }
    return($local_num_found);
}        


    
