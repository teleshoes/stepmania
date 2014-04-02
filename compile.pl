#!/usr/bin/perl
use strict;
use warnings;

sub run(@);

my $repoDir = "$ENV{HOME}/Code/stepmania";
my $installDir = "$ENV{HOME}/Desktop/Games/stepmania";
my $configDir = "$ENV{HOME}/.stepmania-5.0";

my $threads = 8;

sub main(@){
  chdir $repoDir;
  run "./autogen.sh";

  run "./configure", "--with-ffmpeg";

  run "make", "-j$threads";

  install();
}

sub install(){
  my $buildName = "build-" . time;
  my $buildDir = "$installDir/$buildName";
  my @excludes = map {"--exclude=$_"} qw(
    .git/
    _assets/ extern/ Program/ Utils/
    Songs/ Themes/ Xcode/
  );
  run "mkdir", "-p", $installDir;
  run "rsync", "-avP", @excludes, "./", $buildDir;
  run "ln", "-s", "$configDir/Songs", "$buildDir/Songs";
  run "mkdir", "-p", "$buildDir/Songs";
  run "rm", "-f", "$installDir/latest";
  run "ln", "-s", $buildName, "$installDir/latest";
}

sub run(@){
  print "@_\n";
  system @_;
  die "@_ failed\n" if $? != 0;
}

&main(@ARGV);
