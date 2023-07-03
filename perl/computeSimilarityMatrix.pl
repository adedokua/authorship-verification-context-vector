#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp;
use Data::Dumper;
use lib '/Users/dolapoadedokun/Desktop/Trinity/Thesis/perl/';
use FindBin qw($RealBin);
use lib "$RealBin/lib";
use cvModule qw(getFeatures);
use Math::Trig qw(acos);
my $folder = 'data';
my $n = 2;
local $Data::Dumper::Terse = 1;
local $Data::Dumper::Indent = 0;

my @context_vectors;
my $global_corpus = read_file("global/globalcorpus.txt");

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

    # Check that inputs are defined and are array references
    unless (defined $vector1 && ref $vector1 eq 'ARRAY' &&
            defined $vector2 && ref $vector2 eq 'ARRAY') {
        die "Both inputs must be array references.";
    }

    # Check that both arrays have the same number of elements
    unless (@$vector1 == @$vector2) {
        die "Both input arrays must have the same number of elements.";
    }

    # Calculate dot product and magnitudes
    my $dot_product = dot_product($vector1, $vector2);
    my $magnitude1 = magnitude($vector1);
    my $magnitude2 = magnitude($vector2);

    # Check if magnitudes are zero (which would make the division undefined)
    if ($magnitude1 == 0 || $magnitude2 == 0) {
        die "At least one of the input vectors has zero magnitude, which is not allowed.";
    }

    return $dot_product / ($magnitude1 * $magnitude2);
}

sub euclidean_similarity {
    my ($vector1, $vector2) = @_;
    
    # Check that inputs are defined and are array references
    unless (defined $vector1 && ref $vector1 eq 'ARRAY' &&
            defined $vector2 && ref $vector2 eq 'ARRAY') {
        die "Both inputs must be array references.";
    }
    
    # Check that both arrays have the same number of elements
    unless (@$vector1 == @$vector2) {
        die "Both input arrays must have the same number of elements.";
    }
    
    my $sum = 0;
    for (my $i = 0; $i < @$vector1; $i++) {
        # Check that both array elements are defined
        unless (defined $vector1->[$i] && defined $vector2->[$i]) {
            die "Undefined element at index $i.";
        }
        
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

#helper function to append context vectors to one list
sub append_arrays {
    my %hash = @_;
    my @result;

    foreach my $key (sort {$a <=> $b} keys %hash) {
        push @result, @{$hash{$key}};
    }

    return @result;
}
#add all files to global corpus
foreach my $file (@files) {
    my $text = read_file($file);
    #print($text);
    $global_corpus .= $text;
}

###
foreach my $file (@files) {
    my $text = read_file($file);
    #print($text);
    
    
    my %contextHash = getFeatures($text,  $global_corpus,$n);
    #print(Dumper(%contextHash));
    my @context_vector = append_arrays(%contextHash);
    my $lengthContext = scalar @context_vector;
    print "The length of the context vector is: $lengthContext\n";

    #print(Dumper(@context_vector), "\n");
    push @vectors,\@context_vector;
}


#print(Dumper(@vectors));
my $length = scalar @vectors;

print "The length of the vector is: $length\n";
my @matrix;
for (my $i=0; $i<@vectors; $i++) {
    for (my $j=0; $j<@vectors; $j++) {
        $matrix[$i][$j] = compute_similarity($vectors[$i], $vectors[$j],"euclidean");
    }
}
print("\n", "MATRIX");
print(Dumper(@matrix));

# print(Dumper(getFeatures($text1, $text2, $n)));

# my $contextVector1 = getFeatures($text1, $text2, $n);
# my $contextVector2 = getFeatures($text1, $text2, $n);
