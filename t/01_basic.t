use strict;
use warnings;
use Algorithm::BayesianSets;
use Test::More tests => 4;

my $bs = Algorithm::BayesianSets->new;
can_ok($bs, 'new');
can_ok($bs, 'add_document');
can_ok($bs, 'calc_parameters');
can_ok($bs, 'calc_similarities');
