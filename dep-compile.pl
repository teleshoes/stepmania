#!/usr/bin/perl
use strict;
use warnings;

my @smDeps = qw(
  libasound2-dev libpulse-dev libmad0-dev libtheora-dev libvorbis-dev libpng-dev
  libswscale-dev libavutil-dev libavformat-dev libavcodec-dev
  libjpeg-dev libglu1-mesa-dev libgl1-mesa-dev libgtk2.0-dev xorg-dev libxrandr-dev libbz2-dev
  libglew1.5-dev automake1.10 build-essential curl g++
);

my @ffmpegLibs = qw(
  liba52-dev libdts-dev libgsm1-dev libvorbis-dev
  libxvidcore4 libxvidcore-dev libdc-dev libfaac-dev libfaad-dev
  libmp3lame-dev libx264-dev libtheora-dev libsdl1.2-dev
);

sub run(@){
  print "@_\n";
  system @_;
  die "$_ failed\n" if $? != 0;
}

sub main(@){
  run "sudo", "apt-get", "install", @smDeps;
  run "sudo", "apt-get", "install", @ffmpegLibs;
  run "sudo", "apt-get", "build-dep", "ffmpeg";

  my $libfaacDir = "libfaac";
  run "rm", "-rf", $libfaacDir;
  run "mkdir", "-p", $libfaacDir;
  chdir $libfaacDir;
  run "sudo", "apt-get", "build-dep", "libfaac-dev";
  run "sudo", "apt-get", "install", "fakeroot";
  run "apt-get", "source", "--compile", "libfaac-dev";
  run "sudo dpkg -i *.deb";
  chdir "../";
  run "rm", "-rf", $libfaacDir;
}

&main(@ARGV);
