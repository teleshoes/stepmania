#!/usr/bin/perl
use strict;
use warnings;

sub run(@);

my $repoDir = "$ENV{HOME}/Code/stepmania";
my $installDir = "$ENV{HOME}/Games/stepmania";
my $configDir = "$ENV{HOME}/.stepmania-5.0";

my $threads = 8;

my @deps = qw(
  cmake mesa-common-dev libglu1-mesa-dev libglew1.5-dev libxtst-dev libxrandr-dev
  libpng-dev libjpeg-dev zlib1g-dev libbz2-dev libogg-dev libvorbis-dev libc6-dev
  yasm libasound-dev libpulse-dev binutils-dev libgtk2.0-dev libmad0-dev libudev-dev
  libva-dev nasm

  libjack-jackd2-dev
);

sub main(@){
  chdir $repoDir;

  run "sudo", "apt-get", "install", @deps;

  run "cmake",
    "-DWITH_LIBVA=ON",
    "-DWITH_CRYSTALHD_DISABLED=ON",
    "-DWITH_MINIMAID=OFF",
    ".";

  run "make", "-j$threads";

  install();
}

sub install(){
  my $buildName = "build-" . time;
  my $buildDir = "$installDir/$buildName";
  my @excludes = map {"--exclude=$_"} qw(
    .git/
    _assets/ extern/ Program/ Utils/
    Songs/ Xcode/
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
