use strict;
use warnings;
use List::Util qw(first);
use List::MoreUtils qw(uniq);
use Data::Dumper;

sub sort_dict_by_value {
    my ($hashref, $reverse) = @_;
    my @sorted = sort { $hashref->{$a} <=> $hashref->{$b} } keys %$hashref;
    return $reverse ? reverse @sorted : @sorted;
}

sub generateFeatures {
    my ($text1, $text2, $n) = @_;

    # Process Texts
    my $processed_text1 = $text1;
    my $processed_text2 = $text2;

    # Clean strings and lowercase
    $processed_text1 =~ s/[^\w\s]//g;
    $processed_text2 =~ s/[^\w\s]//g;
    $processed_text1 = lc($processed_text1);
    $processed_text2 = lc($processed_text2);

    # Tokenize texts
    my @text1_tokens = split(/\s+/, $processed_text1);
    my @text2_tokens = split(/\s+/, $processed_text2);

    # Create hash of token frequencies in both texts
    my %frequency_hash;
    foreach my $token (@text1_tokens, @text2_tokens) {
        $frequency_hash{$token}++;
    }

    # Sort hash by frequency
    my @sorted_frequency_keys = sort_dict_by_value(\%frequency_hash);

    # Create hash of token indexes in sorted_frequency_hash
    my %index_hash;
    foreach my $i (0..$#sorted_frequency_keys) {
        my $token = $sorted_frequency_keys[$i];
        $index_hash{$token} = $i;
    }

    # Create hash of token indexes and tokens
    my %index_token_hash;
    foreach my $i (0..$#sorted_frequency_keys) {
        my $token = $sorted_frequency_keys[$i];
        $index_token_hash{$i} = $token;
    }

    # Add missing tokens from corpus to frequency hash with 0 frequency
    foreach my $token (uniq(@text1_tokens, @text2_tokens)) {
        if (!exists $frequency_hash{$token}) {
            $frequency_hash{$token} = 0;
        }
    }

    # Create context vectors and ranking hash
    my @context_vectors;
    my %ranking_hash;
    foreach my $i (0..$#text1_tokens) {
        my @before_context_vector = (0) x scalar(@sorted_frequency_keys);
        my @after_context_vector = (0) x scalar(@sorted_frequency_keys);

        foreach my $j ($i - $n .. $i - 1) {
            if ($j >= 0) {
                my $before_token = $text1_tokens[$j];
                if (exists $frequency_hash{$before_token}) {
                    $before_context_vector[$index_hash{$before_token}]++;
                }
            }
        }

        foreach my $j ($i + 1 .. $i + $n) {
            if ($j < scalar(@text1_tokens)) {
                my $after_token = $text1_tokens[$j];
                if (exists $frequency_hash{$after_token}) {
                    $after_context_vector[$index_hash{$after_token}]++;
                }
            }
        }

        my @context_vector = (@before_context_vector, @after_context_vector);
        push @context_vectors, \@context_vector;

        $ranking_hash{$text1_tokens[$i]} = $frequency_hash{$text1_tokens[$i]};
    }

    foreach my $i (0..$#text2_tokens) {
        my @before_context_vector = (0) x scalar(@sorted_frequency_keys);
        my @after_context_vector = (0) x scalar(@sorted_frequency_keys);

        foreach my $j ($i - $n .. $i - 1) {
            if ($j >= 0) {
                my $before_token = $text2_tokens[$j];
                if (exists $frequency_hash{$before_token}) {
                    $before_context_vector[$index_hash{$before_token}]++;
                }
            }
        }

        foreach my $j ($i + 1 .. $i + $n) {
            if ($j < scalar(@text2_tokens)) {
                my $after_token = $text2_tokens[$j];
                if (exists $frequency_hash{$after_token}) {
                    $after_context_vector[$index_hash{$after_token}]++;
                }
            }
        }

        my @context_vector = (@before_context_vector, @after_context_vector);
        push @context_vectors, \@context_vector;

        $ranking_hash{$text2_tokens[$i]} = $frequency_hash{$text2_tokens[$i]};
    }

    return (\@context_vectors, \%frequency_hash, \%index_token_hash);
}

# Example usage
my $text1 = "This is text one.";
my $text2 = "This is text two.";
my $n = 2;

my ($context_vectors, $frequency_hash, $index_token_hash) = generateFeatures($text1, $text2, $n);

print Dumper($context_vectors);
print Dumper($frequency_hash);
print Dumper($index_token_hash);
