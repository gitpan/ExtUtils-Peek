#!/usr/bin/perl -w

use ExtUtils::Peek qw(:ALL);
#use ExtUtils::Peek qw(
#		Dump SvREFCNT SvREFCNT_inc SvREFCNT_dec
#);

$x = [0, 1, {'two' => 22, 2 => 222}, [3, "three"]];

Dump $x;
print "Refcount of \$x is ", SvREFCNT($x), "\n";
SvREFCNT_inc($x);
print "After increment refcount of \$x is ", SvREFCNT($x), "\n";
SvREFCNT_dec($x);
print "After decrement refcount of \$x is ", SvREFCNT($x), "\n";

print "Refcount of \$x is ", SvREFCNT($x), "\n";
print "After increment refcount of \$x is ", SvREFCNT(SvREFCNT_inc($x)), "\n";
print "After previous increment refcount of \$x still is ", SvREFCNT($x), "\n";
print "After decrement refcount of \$x is ", SvREFCNT(SvREFCNT_dec($x)), "\n";
print "After previous decrement refcount of \$x still is ", SvREFCNT($x), "\n";
my $sub = sub {'aaa'};
$closure = sub {$sub};
sub subr {1}
sub closure {$sub}
Dump($sub);
Dump($closure);
Dump(\&subr);
Dump(\&closure);
Dump(\*closure);
Dump ($x, 10);
