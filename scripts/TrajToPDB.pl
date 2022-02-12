#!/usr/bin/perl -w 
use strict;
use warnings;
my ($scriptDirectory) = $0 =~ m/(.*\/)/g;
my $utilDirectory = "/home_e/dor/scripts/util/";

my $schemaFile = $scriptDirectory."/TrajToPDB.prefs.schema";

my $executionPreferencesFile = "./TrajToPDB.prefs";


my $skipEveryXFrame;
my $firstValidFrame;
my $lastValidFrame;
my $trajInputFile;
if (-e $executionPreferencesFile)
{ 
    require $utilDirectory."/ExecutionPreferences.pm";
    my $executionPreferencesRef = ExecutionPreferences::getExecutionPreferences($schemaFile,$executionPreferencesFile);

    $skipEveryXFrame = $executionPreferencesRef->{"SKIP_EVERY_X_FRAME"};
    print "skip every $skipEveryXFrame";
    $firstValidFrame = $executionPreferencesRef->{"FIRST_VALID_FRAME"};
    $lastValidFrame = $executionPreferencesRef->{"LAST_VALID_FRAME"};
    $trajInputFile = $executionPreferencesRef->{"TRAJ_FILE"};
}
else {
    die "usage TrajToPDB.pl trajFile [skipEveryFrame firstValidFrame lastValidFrame]\n" unless (scalar(@ARGV) == 4||scalar(@ARGV) ==2);
    $skipEveryXFrame =1;
    $firstValidFrame  =1;
    $lastValidFrame =1000000000;
    $trajInputFile =$ARGV[0];
    if(scalar(@ARGV) == 4){
      $firstValidFrame=$ARGV[2];
      $lastValidFrame=$ARGV[3];
      $skipEveryXFrame =$ARGV[1];
    }
    if (scalar(@ARGV) == 2){
      $skipEveryXFrame =$ARGV[1];
    }

}
if ($trajInputFile =~ /.bz2/){
    `/home_b/yulian/scripts/bunzip2l.pl $trajInputFile`;
    $trajInputFile =~ s/.bz2//g;
}
#require $utilDirectory."/TrajHandling.pm";
use File::Basename;
my $dirname = dirname(__FILE__);
require $dirname."/TrajHandling.pm";

open (TRAJECTORY_FILE_HANDLE, $trajInputFile) or die "Error reading from $trajInputFile: $!\n";
my $beadsDataRef = TrajHandling::readBeadsData(\*TRAJECTORY_FILE_HANDLE);


writeTrajToPDBFile(\*TRAJECTORY_FILE_HANDLE,$beadsDataRef);

sub writeCurrentCoordinatesToPDB
{
 my ($pdbFileHandleRef,$frameIter,$beadsDataRef,$beadCoordinatesRef) = @_;
  printf $pdbFileHandleRef ("MODEL%8d\n",$frameIter);
    for (my $beadIter =0; $beadIter < scalar(@$beadsDataRef); $beadIter++)
    {
        #next if ($beadsDataRef->[$beadIter]->{"TYPE"} =~ / *S */ || $beadsDataRef->[$beadIter]->{"TYPE"} =~ / *B */);
        printf $pdbFileHandleRef ("ATOM%7d%4s%5s%6d%12.3f%8.3f%8.3f%6.2f%6.2f\n",
                               $beadIter+1,
                               $beadsDataRef->[$beadIter]->{"TYPE"},
                               $beadsDataRef->[$beadIter]->{"RESIDUE_TYPE"},
                               $beadsDataRef->[$beadIter]->{"RESIDUE_ID"},
                               $beadCoordinatesRef->[$beadIter]->{"X"},
                               $beadCoordinatesRef->[$beadIter]->{"Y"},
                               $beadCoordinatesRef->[$beadIter]->{"Z"},
                               1.0,
                               0.0);
    }
    print $pdbFileHandleRef ("ENDMDL\n"); 
}

sub writeTrajToPDBFile
{
  my ($trajFileHandleRef,$beadsDataRef) = @_;
    
  my ($trajFilePrefix) = $trajInputFile =~ m/(.*)\.dat/g;
  open(PDB_FILE_HANDLE, ">",$trajFilePrefix.".pdb") or die "Error opening pdb file for writing: $!\n";

  my $stopReadingTrajFile = 0;
  my $beadCoordinatesRef;
  for (my $frameIter = 1; !$stopReadingTrajFile; $frameIter++)
  {
    $stopReadingTrajFile = 1 if ($frameIter > $lastValidFrame);
    if (($frameIter >= $firstValidFrame) and ($frameIter <= $lastValidFrame) and ($frameIter % $skipEveryXFrame == 0))
    {
      ($stopReadingTrajFile, $beadCoordinatesRef) = TrajHandling::readFrame(\*TRAJECTORY_FILE_HANDLE,$beadsDataRef);

      #print "Processing Frame ".$frameIter."\n";
      writeCurrentCoordinatesToPDB(\*PDB_FILE_HANDLE,$frameIter,$beadsDataRef,$beadCoordinatesRef) unless $stopReadingTrajFile;
    }
    else{
        ($stopReadingTrajFile,$beadCoordinatesRef) = TrajHandling::skipFrame(\*TRAJECTORY_FILE_HANDLE,$beadsDataRef);
    }
  }  
  close(PDB_FILE_HANDLE);
}


