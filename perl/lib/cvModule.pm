package cvModule;

use strict;
use warnings;
use List::Util qw(sum);
use Data::Dumper;
use Tie::IxHash;
use Exporter qw(import);

our @EXPORT_OK = qw(getFeatures);

sub sort_hash_by_value {
    my ($hash_ref, $reverse) = @_;
    tie my %sorted, 'Tie::IxHash';
    %sorted = map  { $_->[0] => $hash_ref->{$_->[0]} }
        sort {
            $reverse ? $b->[1] <=> $a->[1] || $a->[2] cmp $b->[2] 
                     : $a->[1] <=> $b->[1] || $a->[2] cmp $b->[2]
        }
        map { [$_, $hash_ref->{$_}, $_] } keys %$hash_ref;
    return \%sorted;
}

sub getFeatures {
    my ($text1, $text2, $n) = @_;
    
    $text1 =~ s/[^\w\s]//g;
    $text2 =~ s/[^\w\s]//g;

    my $pat = qr/[^a-zA-Z ]+/;
    $text1 =~ s/$pat//g;
    $text2 =~ s/$pat//g;
    $text1 = lc $text1;
    $text2 = lc $text2;

    tie my %tokens, 'Tie::IxHash';
    tie my %hashFrequency, 'Tie::IxHash';
    tie my %hashTokenRanking, 'Tie::IxHash';
    tie my %hashRankingToken, 'Tie::IxHash';

    my $nbTokensInText1 = 0;

    my @splitText1 = split(' ', $text1);
    foreach my $word (@splitText1) {
        $tokens{$word} = 1;
        if (exists $hashFrequency{$word}) {
            $hashFrequency{$word}++;
        } else {
            $hashFrequency{$word} = 1;
        }
    }
    $nbTokensInText1 = keys %tokens;

    my @splitText2 = split(' ', $text2);
    foreach my $word (@splitText2) {
        $tokens{$word} = 1;
        if (!exists $hashFrequency{$word}) {
            $hashFrequency{$word} = 0;
        }
    }

    my $sortedHashFreq = sort_hash_by_value(\%hashFrequency, 1);

    my $i = 1;
    foreach my $token (keys %$sortedHashFreq) {
        $hashTokenRanking{$token} = $i;
        $hashRankingToken{$i} = $token;
        $i++;
    }

    tie my %after, 'Tie::IxHash';
    tie my %before, 'Tie::IxHash';

    for my $index (0..$#splitText1) {
        my $word = $splitText1[$index];
        my $targetWordIndex = $hashTokenRanking{$word};

        for my $position (1..$n) {
            if ($index + $position < scalar @splitText1) {
                my $contextWord = $splitText1[$index + $position];
                my $contextWordIndex = $hashTokenRanking{$contextWord};

                if (exists $after{$targetWordIndex}) {
                    my $positionDict = $after{$targetWordIndex};

                    if (exists $positionDict->{$position}) {
                        my $relFreqAtPositionJ = $after{$targetWordIndex}->{$position};
                        $relFreqAtPositionJ->[$contextWordIndex - 1]++;
                    } else {
                        my @relFreqAtPositionJ = ((0) x scalar keys %tokens);
                        $relFreqAtPositionJ[$contextWordIndex - 1] = 1;
                        $positionDict->{$position} = \@relFreqAtPositionJ;
                    }
                } else {
                    my @relFreqAtPositionJ = ((0) x scalar keys %tokens);
                    $relFreqAtPositionJ[$contextWordIndex - 1] = 1;
                    $after{$targetWordIndex} = {$position => \@relFreqAtPositionJ};
                }
            }
            
            if ($index - $position >= 0) {
                my $contextWord = $splitText1[$index - $position];
                my $contextWordIndex = $hashTokenRanking{$contextWord};

                if (exists $before{$targetWordIndex}) {
                    my $positionDict = $before{$targetWordIndex};

                    if (exists $positionDict->{$position}) {
                        my $relFreqAtPositionJ = $before{$targetWordIndex}->{$position};
                        $relFreqAtPositionJ->[$contextWordIndex - 1]++;
                    } else {
                        my @relFreqAtPositionJ = ((0) x scalar keys %tokens);
                        $relFreqAtPositionJ[$contextWordIndex - 1] = 1;
                        $positionDict->{$position} = \@relFreqAtPositionJ;
                    }
                } else {
                    my @relFreqAtPositionJ = ((0) x scalar keys %tokens);
                    $relFreqAtPositionJ[$contextWordIndex - 1] = 1;
                    $before{$targetWordIndex} = {$position => \@relFreqAtPositionJ};
                }
            }
        }
    }

    tie my %contextVectorHash, 'Tie::IxHash';
    foreach my $rank (values %hashTokenRanking) {
        $contextVectorHash{$rank} = [];

        for my $negativePos (reverse 1..$n) {
            if (!exists $before{$rank}) {
                push @{$contextVectorHash{$rank}}, ((0) x scalar keys %tokens);
            } else {
                if (!exists $before{$rank}->{$negativePos}) {
                    push @{$contextVectorHash{$rank}}, ((0) x scalar keys %tokens);
                } else {
                    push @{$contextVectorHash{$rank}}, @{$before{$rank}->{$negativePos}};
                }
            }
        }
        
        for my $positivePos (1..$n) {
            if (!exists $after{$rank}) {
                push @{$contextVectorHash{$rank}}, ((0) x scalar keys %tokens);
            } else {
                if (!exists $after{$rank}->{$positivePos}) {
                    push @{$contextVectorHash{$rank}}, ((0) x scalar keys %tokens);
                } else {
                    push @{$contextVectorHash{$rank}}, @{$after{$rank}->{$positivePos}};
                }
            }
        }
    }
    
    tie my %notNormalized, 'Tie::IxHash', %contextVectorHash;
    foreach my $rank (values %hashTokenRanking) {
        $contextVectorHash{$rank} = [map { $_ / $nbTokensInText1 } @{$contextVectorHash{$rank}}];
    }
    
    #return (\%notNormalized, \%hashFrequency, \%hashTokenRanking);
    return  %contextVectorHash;
}
1;  