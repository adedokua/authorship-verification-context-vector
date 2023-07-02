#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp;
use Data::Dumper;
use lib '/Users/dolapoadedokun/Desktop/Trinity/Thesis/perl/';
use cvModule qw(getFeatures);
use Math::Trig qw(acos);
my $folder = 'data';
my $n = 2;

my @context_vectors;
my $global_corpus = read_file("global/globalcorpus.txt");
print($global_corpus);

my @files = glob("data/*.txt");
my @vectors;

sub compute_similarity {
    my ($vector1, $vector2, $similarity_type) = @_;
    if ($similarity_type eq "cosine") {
        return cosine_similarity($vector1, $vector2);
    } elsif ($similarity_type eq "euclidean") {
        return euclidean_similarity($vector1, $vector2);
    } else {
        die "Unknown similarity type: $similarity_type\n";
    }
}

sub cosine_similarity {
    my ($vector1, $vector2) = @_;
    my $dot_product = dot_product($vector1, $vector2);
    my $magnitude1 = magnitude($vector1);
    my $magnitude2 = magnitude($vector2);
    return $dot_product / ($magnitude1 * $magnitude2);
}

sub euclidean_similarity {
    my ($vector1, $vector2) = @_;
    my $sum = 0;
    for (my $i=0; $i<@$vector1; $i++) {
        $sum += ($vector1->[$i] - $vector2->[$i]) ** 2;
    }
    return sqrt($sum);
}

sub dot_product {
    my ($vector1, $vector2) = @_;
    my $product = 0;
    for (my $i=0; $i<@$vector1; $i++) {
        $product += $vector1->[$i] * $vector2->[$i];
    }
    return $product;
}

sub magnitude {
    my ($vector) = @_;
    my $sum = 0;
    for (my $i=0; $i<@$vector; $i++) {
        $sum += $vector->[$i] ** 2;
    }
    return sqrt($sum);
}



###
foreach my $file (@files) {
    my $text = read_file($file);
    print($text);
    #toDO
    #implementatoin question, do I aapend all context vectors into one vector?
    my $vector = getFeatures($text,  $global_corpus,$n);
    print($vector)
    #push @vectors, $vector;
}


my @matrix;
for (my $i=0; $i<@vectors; $i++) {
    for (my $j=0; $j<@vectors; $j++) {
        $matrix[$i][$j] = compute_similarity($vectors[$i], $vectors[$j]);
    }
}

# print(Dumper(getFeatures($text1, $text2, $n)));

# my $contextVector1 = getFeatures($text1, $text2, $n);
# my $contextVector2 = getFeatures($text1, $text2, $n);
