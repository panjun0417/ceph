#!/usr/bin/perl

use strict;

my $xaxis = shift @ARGV;
my @vars;
while (@ARGV) {
	$_ = shift @ARGV;
	last if ($_ eq '-');
	push(@vars, $_);
}
my @dirs;
while (@ARGV) {
	$_ = shift @ARGV;
	last if ($_ eq '-');
	push(@dirs, $_) if -d $_;
}
my @filt = @ARGV;
push( @filt, '.' ) unless @filt;

print "#xaxis $xaxis
#vars @vars
#dirs @dirs
#filt @filt
";

sub load_sum {
	my $fn = shift @_;

	open(I, "$fn");
	my $k = <I>;
	chomp($k);
	my @k = split(/\s+/,$k);
	shift @k;

	my $s;
	while (<I>) {
		chomp;
		s/^\#//;
		next unless $_;
		my @l = split(/\s+/,$_);
		my $k = shift @l;
		for my $f (@k) {
			$s->{$k}->{$f} = shift @l;
		}
	}		
	return $s;
}


my %res;
my @key;
my %didkey;
for my $f (@filt) {
	my @reg = split(/,/, $f);
	#print "reg @reg\n";
   	for my $d (@dirs) {
		if ($f ne '.') {
			my $r = (split(/\//,$d))[-1];
			my @db = split(/,/, $r);
			#print "db @db\n";
			my $ok = 1;
			for my $r (@reg) {
				
				$ok = 0 unless grep {$_ eq $r} @db;
			}
			next unless $ok;
		}
		#next if ($f ne '.' && $d !~ /$reg/);			
		#print "$d\n";
		my ($x) = $d =~ /$xaxis=(\d+)/;
		
		for my $v (@vars) {
			my ($what, $field) = split(/\./, $v);
			my $s = &load_sum("$d/sum.$what");
			
			#print "\t$v";
			push( @{$res{$x}}, $s->{'avgval'}->{$field} );
			push( @key, "$f.$field" ) unless $didkey{"$f.$field"};
			$didkey{"$f.$field"} = 1;
		}
	}
}

print join("\t", "#", @key) . "\n";
for my $x (sort {$a <=> $b} keys %res) {
	print join("\t", $x, @{$res{$x}}) . "\n";
}
