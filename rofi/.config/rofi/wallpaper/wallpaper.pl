#!/usr/bin/env perl
use strict;
use warnings;

my $wallpaper_dir = "$ENV{HOME}/wallpaper";
my $current_link  = "$wallpaper_dir/wallpaper.png";
my $script        = "$ENV{HOME}/.config/scripts/wallpaper.sh";

if (!@ARGV) {
    print "\0use-hot-keys\x1ftrue\n";
    opendir(my $dh, $wallpaper_dir) or die "Cannot open $wallpaper_dir: $!";
    while (my $file = readdir($dh)) {
        next unless $file =~ /\.(jpg|jpeg|png|webp)$/i;
        next if $file eq 'wallpaper.png';
        my $full_path = "$wallpaper_dir/$file";
        print "$file\0icon\x1f$full_path\n";
    }
    closedir($dh);
} else {
    my $selection = "$wallpaper_dir/$ARGV[0]";
    symlink($selection, "$current_link.tmp") and rename("$current_link.tmp", $current_link);
    open(STDOUT, '>', '/dev/null');
    open(STDERR, '>', '/dev/null');
    exec "setsid", $script;
}
