#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use lib '/Users/dolapoadedokun/Desktop/Trinity/Thesis/perl/';
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

# Run test cases
for my $test_case (@test_cases) {
    print "\nRunning test case: ", Dumper($test_case), "\n";
    print Dumper(getFeatures($test_case->{text1}, $test_case->{text2}, $test_case->{n})), "\n";
}