while($line = <>) { 
  if($line =~ m/^\>/) { 
    chomp $line;
    #gi|449431822|gb|JX185690.1|
    if($line =~ /^\>gi\|\d+\|\S+\|(\S+)\|\S*\s+(.+)$/) { 
      print ">" . $1 . " $2\n";
    }
    else { 
      die "couldn't parse header $line"; 
    }
  }
  else { 
    print $line;
  }
}
