package Algorithm::BayesianSets;

use strict;
use warnings;

our $VERSION = '0.02';

use constant DEFAULT_THRESHOLD => 0;
use constant DEFAULT_C         => 2;

sub new {
    my ($class, $threshold) = @_;
    $threshold = DEFAULT_THRESHOLD if !defined $threshold;
    my $self = {
        threshold => $threshold,
        vectors   => {},
        alpha     => {},
        beta      => {},
    };
    bless $self, $class;
    return $self;
}

sub add_document {
    my ($self, $id, $vector) = @_;
    return if !defined $id || !$vector;

    my %binary_vector;
    while (my ($key, $val) = each %{ $vector }) {
        $binary_vector{$key} = 1 if $val >= $self->{threshold};
    }
    $self->{vectors}{$id} = \%binary_vector;
}

sub calc_parameters {
    my ($self, $c) = @_;
    $c = DEFAULT_C if !defined $c;

    my $average_vector = $self->_average_vector($self->{vectors});
    my (%alpha, %beta);
    while (my ($key, $val) = each %{ $average_vector }) {
        $alpha{$key} = $c * $val;
        $beta{$key}  = $c * (1 - $val);
    }
    $self->{alpha} = \%alpha;
    $self->{beta}  = \%beta;
}

sub calc_similarities {
    my ($self, $queries) = @_;
    return if !$queries;

    my %query_vector;
    my $num_query;
    foreach my $query (@{ $queries }) {
        next if !exists $self->{vectors}{$query};
        while (my ($key, $val) = each %{ $self->{vectors}{$query} }) {
            $query_vector{$key} += $val;
        }
        $num_query++;
    }
    return if !%query_vector;

    my %weight_vector;
    while (my ($key, $val) = each %query_vector) {
        my $val_alpha = $self->{alpha}{$key} ?
            log(1 + $val / $self->{alpha}{$key}) : 0;
        my $val_beta  = $self->{beta}{$key} ?
            log(1 + ($num_query - $val) / $self->{beta}{$key}) : 0;
        $weight_vector{$key} = $val_alpha - $val_beta;
    }
    my %score;
    while (my ($doc_id, $vector) = each %{ $self->{vectors} }) {
        $score{$doc_id} = $self->_inner_product(\%weight_vector, $vector);
    }
    return \%score;
}

sub _average_vector {
    my ($self, $vectors) = @_;
    return if !$vectors;

    my %average_vector;
    my $num_vector = 0;
    while (my ($doc_id, $vector) = each %{ $vectors }) {
        while (my ($key, $val) = each %{ $vector }) {
            $average_vector{$key} += $val;
        }
        $num_vector++;
    }
    map { $average_vector{$_} /= $num_vector } keys %average_vector;
    return \%average_vector;
}

sub _inner_product {
    my ($self, $v1, $v2) = @_;
    return 0 if !$v1 || !$v2;

    my @keys = scalar(keys %{ $v1 }) < scalar(keys %{ $v2 }) ?
        keys %{ $v1 } : keys %{ $v2 };
    my $prod = 0;
    foreach my $key (@keys) {
        $prod += $v1->{$key} * $v2->{$key} if $v1->{$key} && $v2->{$key};
    }
    return $prod;
}

1;

__END__

=head1 NAME

Algorithm::BayesianSets - perl implementation of Bayesian Sets

=head1 SYNOPSIS

  use Algorithm::BayesianSets;
  
  my $bs = Algorithm::BayesianSets->new;

  # add documents
  my %documents = (
      apple  => {
          fruit => 1,
          red   => 1,
      },
      banana => {
          fruit  => 1,
          yellow => 1,
      },
      cherry => {
          fruit => 1,
          pink  => 1,
      },
  );
  foreach my $id (keys %documents) {
      $bs->add_document($id, $documents{$id});
  }
  
  # calc alpha/beta parameters
  $bs->calc_parameters();
  
  # get similar documents
  my @queries = qw(apple);
  my $scores = $bs->calc_similarities(\@queries);
  
  # show output
  foreach my $id (keys %{ $scores }) {
      printf "%s\t%.4f\n", $id, $scores->{$id};
  }

=head1 DESCRIPTION

Algorithm::BayesianSets is a perl implementation of Bayesian Sets algorithm.

=head1 METHODS

=head2 new($threshold)

Create a new instance.

$threshold parameter is the threshold of the degree of document features. In add_document method, if the degree of the feature is less than the threshold, the feature isn't used.

=head2 add_document($id, $vector)

Add an input document to the instance of Algorithm::BayesianSets. $id parameter is the identifier of a document, and $vector parameter is the feature vector of a document. $vector parameter must be a hash reference, each key of $vector parameter is the identifier of the feature of documents and each value of $vector is the degree of the feature.

=head2 calc_parameters($c)

Calculate the alpha and beta parameters which are used in Bayesian Sets algorithm. $c parameter must be a real number (Default: 2.0).

=head2 calc_similarities($queries)

Calculate the similarities between the queries and input documents using Bayesian Sets algorithm. $queries parameter must be array reference, and each query in $queries needs to be included in the identifiers of input documents.

The output of this method is a hash reference, each key of the hash reference is the identifier of an input document and each value is the similarity between the queries and an input document.

=head2 _average_vector($vectors)

Get the average vector of input vectors.

=head2 _inner_product($vector1, $vector2)

Calculate the inner product value of input vectors.

=head1 AUTHOR

Mizuki Fujisawa E<lt>fujisawa@bayon.ccE<gt>

=head1 SEE ALSO

=over

=item Bayesian Sets (Paper)

http://www.gatsby.ucl.ac.uk/~heller/bsets.pdf

=item bsets, The Bayesian Sets Algorithm (Matlab code)

http://chasen.org/~daiti-m/dist/bsets/

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
