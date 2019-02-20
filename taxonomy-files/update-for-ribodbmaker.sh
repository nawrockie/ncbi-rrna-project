#!/bin/bash

if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly, e.g.\n'update-for-ribodbmaker.sh'" 1>&2
    exit 1
fi


if [ ! "$VECPLUSDIR" ] ; then
    echo "The VECPLUSDIR environment variable is not set. Please set it to the directory where vecscreen_plus_taxonomy is installed, e.g.:\n'export VECPLUSDIR=/PATH-TO-VECPLUSTAXONOMY/'" 1>&2
    exit 1
fi

cp /am/ftp-private/ncbitax/taxdump_new.tar.gz .
gunzip -f taxdump_new.tar.gz
tar xf taxdump_new.tar
cut -f1,3,5 nodes.dmp > taxonomy_tree.txt
cut -f31 nodes.dmp > specified_column.txt
$VECPLUSDIR/scripts/assign_levels_to_taxonomy.pl --input_taxa taxonomy_tree.txt --outfile taxonomy_tree_wlevels.txt
paste taxonomy_tree_wlevels.txt specified_column.txt > ncbi_taxonomy_tree.ribodbmaker.txt
