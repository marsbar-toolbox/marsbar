#!/usr/bin/perl -w
# Make release script for marsbar example data
#
# $Id$

die 'Need release name' unless @ARGV;
$release_name = shift;

$module_name = 'marsbar_example_data';
$mn_full = "$module_name-$release_name";
$data_tgz = "~/marsbar-devel/$module_name/eg_data.tgz";
system("cvs -d:ext:matthewbrett\@cvs.sourceforge.net:/cvsroot/marsbar export -D tomorrow $module_name");

chdir($module_name);
unlink ".cvsignore";
unlink "release.pl";
system("tar zxvf $data_tgz");
chdir("..");
system("mv $module_name $mn_full");
system("tar zcvf $mn_full.tar.gz $mn_full");
system("rm -rf $mn_full");