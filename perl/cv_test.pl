#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use FindBin qw($RealBin);
use lib "$RealBin/lib";
use cvModule qw(getFeatures);

local $Data::Dumper::Terse = 1;
local $Data::Dumper::Indent = 0;


# Test cases
my @test_cases = (
    {
        text1 => "I love programming in Perl",
        text2 => "Programming is fun and I love Perl",
        n     => 2,
    },
    {
        text1 => "This is a test case",
        text2 => "Different words here",
        n     => 2,
    },
    {
        text1 => "This is a Test, with Punctuation!",
        text2 => "Another test, with Different Punctuation!!!",
        n     => 2,
    },
    {
        text1 => "This is a test case",
        text2 => "This is a test case",
        n     => 2,
    },
    {
        text1 => "",
        text2 => "",
        n     => 2,
    },
    {
        text1 => "This is a test case",
        text2 => "This is another test case",
        n     => 0,
    },
    {
        text1 => "This is a test case",
        text2 => "This is another test case",
        n     => 1,
    },
    {
        text1 => "This is a test case",
        text2 => "This is another test case",
        n     => 10,
    },
);
sub append_arrays {
    my %hash = @_;
    my @result;

    foreach my $key (sort {$a <=> $b} keys %hash) {
        push @result, @{$hash{$key}};
    }

    return @result;
}

# Run test cases
for my $test_case (@test_cases) {
    print "\nRunning test case: ", Dumper($test_case), "\n";
    my %contextHash=getFeatures($test_case->{text1}, $test_case->{text2}, $test_case->{n});
    my @context_vector = append_arrays(%contextHash);
    print(Dumper(getFeatures($test_case->{text1}, $test_case->{text2}, $test_case->{n})), "\n");
    print("\n", "Exppected");
    print(Dumper(@context_vector), "\n");
}