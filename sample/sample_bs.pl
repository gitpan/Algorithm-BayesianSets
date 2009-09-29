#!/usr/bin/perl
#
# sample code of Algorithm::BayesianSets
#

use strict;
use warnings;
use FindBin::libs;
use Algorithm::BayesianSets;

use constant {
    MAX_OUTPUT => 20,
};

my $bs = Algorithm::BayesianSets->new(0); # threshold = 0

my $path = shift @ARGV;
my @queries = @ARGV;
die "Usage $0 file query1 query2 .." if !$path || !@queries;

# read input documents
# format: id \t key1 \t val1 \t key2 \t val2 \t ...\n
open my $fh, $path or die "cannot open file: $path";
while (my $line = <$fh>) {
    chomp $line;
    my @arr = split /\t/, $line;
    my $id = shift @arr;
    my %vector = @arr;
    $bs->add_document($id, \%vector);
}

$bs->calc_parameters(2); # c = 2
my $scores = $bs->calc_similarities(\@queries);

# show output
my $cnt = 0;
my @ids = sort { $scores->{$b} <=> $scores->{$a} } keys %{ $scores };
for (my $i = 0; $i < scalar(@ids) && $i < MAX_OUTPUT; $i++) {
    printf "%s\t%.4f\n", $ids[$i], $scores->{$ids[$i]};
}
