#!/usr/bin/perl
use strict;
use warnings;

sub ffmpegCompile();
sub run(@);

my $ffmpegUrl = "http://ffmpeg.org/releases";
my $ffmpegVersion = "0.10.2";
my $threads = 8;
my @ffmpegFlags = qw(
  --enable-static --enable-gpl --enable-version3
  --enable-nonfree --enable-libx264 --enable-libfaac
  --enable-libmp3lame --enable-libtheora --enable-libvorbis
  --disable-libvpx --disable-vaapi --enable-libxvid --disable-debug
  --enable-memalign-hack --disable-network --enable-small --disable-encoders
  --disable-ffserver --extra-cflags=-Dattribute_deprecated=
);

sub main(@){
  run "./autogen.sh";

  ffmpegCompile();

  my $buildDir = "_build";
  run "mkdir", "-p", $buildDir;
  chdir $buildDir;

  run "../configure", "--with-ffmpeg",
    "--with-static-ffmpeg=../ffmpeg-$ffmpegVersion/_inst";

  run "make", "-j$threads";
  run "cp", "src/stepmania", "../";
  run "cp", "src/GtkModule.so", "../";
}

sub ffmpegCompile(){
  my $name = "ffmpeg-$ffmpegVersion";
  my $instDir = "$name/_inst";
  my $tar = "$name.tar.bz2";

  if(-d $instDir){
    print "skipping compiled ffmpeg\n";
    return;
  }
  run "wget", "$ffmpegUrl/$tar" if not -e $tar;
  run "rm", "-rf", "$name/";
  run "tar", "-xf", $tar;

  die "no $name/ dir\n" if not -d $name;
  chdir $name;

  run "./configure", "--prefix=\"./_inst\"", @ffmpegFlags;
  run "make", "-j$threads", "install-libs", "install-headers";
  chdir "../";
}

sub run(@){
  print "@_\n";
  system @_;
  die "$_ failed\n" if $? != 0;
}

&main(@ARGV);
