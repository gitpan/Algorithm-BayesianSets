use strict;
use warnings;
use Algorithm::BayesianSets;
use Test::More tests => 374;

use constant {
    NUM_DOCUMENT => 10,
    NUM_KEY      => 30,
};

my $threshold = 0.1;
my $bs = Algorithm::BayesianSets->new($threshold);
foreach my $id (0 .. NUM_DOCUMENT-1) {
    my %vector;
    foreach my $key (0 .. NUM_KEY-1) {
        $vector{$key} = rand(1);
    }
    $bs->add_document($id, \%vector);

    ## check add_document
    while (my ($key, $val) = each %vector) {
        if ($val >= $threshold) {
            is($bs->{vectors}{$id}{$key}, 1);
        }
        else {
            ok(!exists $bs->{vectors}{$id}{$key});
        }
    }
}
is(scalar(keys %{ $bs->{vectors} }), NUM_DOCUMENT);

my $c = 2;
$bs->calc_parameters($c);
is(scalar(keys %{ $bs->{alpha} }), NUM_KEY);
is(scalar(keys %{ $bs->{beta} }), NUM_KEY);
foreach my $key (0 .. NUM_KEY-1) {
    ok(exists $bs->{alpha}{$key});
    ok(exists $bs->{beta}{$key});
}

my @queries = (1, 2);
my $scores = $bs->calc_similarities(\@queries);
ok($scores);
foreach my $id (0 .. NUM_DOCUMENT-1) {
    ok(exists $scores->{$id});
}
