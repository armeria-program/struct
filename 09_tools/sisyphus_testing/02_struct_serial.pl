#!/usr/bin/perl -w 

#use strict;

my $top_path  = "/home/ivanam";
my $tfm_table = "sysphus_tfms.csv";
my $struct    = "$top_path/kode/03_struct/struct"; 

foreach ($top_path, $tfm_table, "params", $struct) {
    (-e $_) || die "$_ not found.\n";
}

foreach ("fold", "homologous", "fragment") {
    (-e $_) || `mkdir $_`;
}


my ($alignment_id, $alig_type, $pdb_code, $pdb_chain, $mat11, $mat12, 
 $mat13, $mat21, $mat22, $mat23, $mat31, $mat32, $mat33, 
 $shift1, $shift2, $shift3) = ();


open ( LOG, ">struct.log")  ||
    die "Cno struct.log: $!\n";

open ( IF, "<$tfm_table") ||
    die "Cno $tfm_table: $!\n";

my $home = `pwd`; chomp $home;

my $qryfile = "";
while (<IF>) {

 
    ($alignment_id, $alig_type, $pdb_code, $pdb_chain, $mat11, $mat12, 
     $mat13, $mat21, $mat22, $mat23, $mat31, $mat32, $mat33, 
     $shift1, $shift2, $shift3) = split ();

    next if ($alignment_id =~ /alignment_id/);

    $pdb_code =~ s/\"//g;
    $pdb_chain =~ s/\"//g;
    $alig_type =~ s/\"//g;

    my $is_query    = 0;
    my $current_qry = "";
    if ( /1 0 0 0 1 0 0 0 1 0 0 0/ )  {
	$is_query    = 1;
	$current_qry = "$pdb_code$pdb_chain";
    } 

    print "\n\n\n##############################################\n";
    print "$pdb_code\n";


    chdir $home;
    chdir "$home/$alig_type";
    (-e "pdbchains") ||  die "pdbchains dir not found\n";
    (-e "pdbchains/$current_qry") || die "pdbchains/$current_qry not found\n"; 
    (-e "sys_tfms")  || die "sys_tfms not found\n";


    my $chainfile     = "pdbchains/$current_qry/$pdb_code$pdb_chain.pdb";
    (-e $chainfile) || die "$chainfile not found in".`pwd`;
    (-z $chainfile)  && die "$chainfile empty in".`pwd`;
   
    my $qryfile;
    if ($is_query) {
	$qryfile = $chainfile;
	next;
    }

    ###########################################################
    # tfm according to sysiphus
    my $sys_chainfile_renamed = "pdbchains/$current_qry/$current_qry.to_$pdb_code$pdb_chain.sys.pdb";
    (-e $sys_chainfile_renamed) || next;

    ###########################################################
    ###########################################################
    ###########################################################
    # apply struct to the same problem

    my $cmd = "time $struct  -in1 $qryfile -in2 $chainfile -p ../params";
    if  (system $cmd ) {
	print LOG "Error running $cmd.\n";
	print  "Error running $cmd.\n"; 
	next;
    }
    `rm *.struct_out*`;

    for my  $match_no ( 0 .. 5 ) {
	my $struct_chainfile_orig    = "$current_qry.to_$pdb_code$pdb_chain.$match_no.pdb";
	my $struct_chainfile_renamed = 
	    "pdbchains/$current_qry/$current_qry.to_$pdb_code$pdb_chain.struct.$match_no.pdb";

	if (-e $struct_chainfile_orig) {
	    `mv $struct_chainfile_orig $struct_chainfile_renamed`;

	} else {
	    printf "$struct_chainfile_orig not found after\n$cmd\n";
	    #exit;
	}

    }



}

close IF;


