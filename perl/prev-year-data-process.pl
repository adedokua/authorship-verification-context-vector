#!/usr/bin/perl
use JSON;
use IO::Handle;

sub createDataset {
    open(my $json_file, '<', '../pan/pan-demo-smalll.jsonl') or die $!;
    open(my $truth_file, '<', '../pan/pan-demo-small-truth.jsonl') or die $!;
    my @truth_list = <$truth_file>;
    open(my $cases, '>>', 'truthvalues.txt') or die $!;
    my @json_list = <$json_file>;
    my $i = 0;
    my $pair_num = 0;
    foreach my $entry (@json_list) {
        my $js = $entry;
        my $result = decode_json($js);
        my @textPair = @{$result->{'pair'}};
        open(my $f1, '>', "../data/$i.txt") or die $!;
        print {$f1} "$textPair[0]";
        close($f1);
        $i++;
        open(my $f2, '>', "../data/$i.txt") or die $!;
        print {$f2} "$textPair[1]";
        close($f2);
        $i++;
        my $truthjs = $truth_list[$pair_num];
        $pair_num++;
        my $tresult = decode_json($truthjs);
        my $ans = 0;
        if ($tresult->{'same'} == 1) {
            $ans = 1;
        }
        print {$cases} "$i-2.txt $i-1.txt $ans\n";
    }
    close($cases);
}

createDataset();