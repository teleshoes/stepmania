#!/usr/bin/perl
use strict;
use warnings;

sub ffmpegCompile();
sub run(@);

my $repoDir = "$ENV{HOME}/Code/stepmania";
my $installDir = "$ENV{HOME}/Desktop/Games/stepmania";

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
  chdir $repoDir;
  run "./autogen.sh";

  ffmpegCompile();

  run "./configure", "--with-ffmpeg",
    "--with-static-ffmpeg=./ffmpeg-$ffmpegVersion/_inst";

  run "make", "-j$threads";

  install();
}

sub install(){
  my $buildName = "build-" . time;
  my $buildDir = "$installDir/$buildName";
  my @excludes = map {"--exclude=$_"} qw(
    .git/
    _assets/ extern/ Program/ Utils/
    ffmpeg-*/
    ffmpeg-*.tar.bz2
    Songs/ Themes/ Xcode/
  );
  run "mkdir", "-p", $installDir;
  run "rsync", "-avP", @excludes, "./", $buildDir;
  run "mkdir", "-p", "$buildDir/Songs";
  run "rm", "-f", "$installDir/latest";
  run "ln", "-s", $buildName, "$installDir/latest";
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
  die "@_ failed\n" if $? != 0;
}

&main(@ARGV);
