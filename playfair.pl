use strict;
use warnings;

my ($op, $key, $msg) = @ARGV;

# INPUT VALIDATION

unless (scalar @ARGV == 3) {
    die "Error: Must provide three arguments.\n1) An operation, either 'enc' (encipher) or 'dec' (decipher).\n2) A keyword. It must be a single word with no repeat letters.\n3) A text (plaintext or ciphertext) to operate on, with no spaces or punctuation.\n";
}

unless ($op eq "enc" || $op eq "dec") {
    die "Error: First argument must be either 'enc' or 'dec'\n";
}

$key = lc($key);
$key =~ tr/j/i/;
my @keyarray = split(//, $key);
foreach my $char (@keyarray) {
    if (grep(/$char/, @keyarray) > 1) {
        die "Error: Keyword must not contain any repeat letters.\nNote that the letter 'j' is converted into 'i'.\n";
    }
}

# CHECK AND PREPARE MESSAGE

$msg = lc($msg);
$msg =~ tr/j/i/;
my @msgarray = split(//, $msg);
if (grep(!/[a-z]/, @msgarray)) {
    die "Error: Text must only contain letters. No spaces, punctiation, or special characters.\n";
}

my @starttext = ();
my $first = "init";
my $second = "init";
for (my $i = 0; $i < scalar @msgarray;) {
    $first = $msgarray[$i];
    if ($i == (scalar @msgarray) - 1) {
        push(@starttext, $first);
        push(@starttext, "x");
        last;
    }
    $second = $msgarray[$i+1];
    if ($first eq $second) {
        push(@starttext, $first);
        push(@starttext, "x");
        $i += 1;
        next;
    }
    push(@starttext, $first);
    push(@starttext, $second);
    $i += 2;
}
    

# ENCODING / DECODING

my $coder = make_coder($key);

my @endtext = ();
for (my $i = 0; $i < (scalar @starttext) - 1; $i+=2) {
    my $pair = $coder->{$op}($starttext[$i], $starttext[$i+1]);
    push(@endtext, $pair->[0]);
    push(@endtext, $pair->[1]);
}
my $result = join("", @endtext);

print "$result\n";

# FUNCTIONS

sub make_coder {
    my $keyword = shift;

    my @letters = split(//, $keyword);
    my @alpha = split(//, "abcdefghiklmnopqrstuvwxyz");
    for my $letter (@letters) { # for each letter in keyword...
        for (my $i = 0; scalar @alpha; $i++) {
            if ($letter eq $alpha[$i]) { # run through @alpha...
                splice(@alpha, $i, 1); # delete it if it matches
                last;
            }
        }
    }

    my @srettel = reverse @letters;
    foreach(@srettel){
        unshift(@alpha, $_);
    }

    my $grid = [
        [$alpha[0], $alpha[1], $alpha[2], $alpha[3], $alpha[4]],
        [$alpha[5], $alpha[6], $alpha[7], $alpha[8], $alpha[9]],
        [$alpha[10], $alpha[11], $alpha[12], $alpha[13], $alpha[14]],
        [$alpha[15], $alpha[16], $alpha[17], $alpha[18], $alpha[19]],
        [$alpha[20], $alpha[21], $alpha[22], $alpha[23], $alpha[24]],
    ];

    my $find = sub {
        my ($letter) = @_;
        my ($gridrow, $gridcol);
        my $done = 0;
        for (my $row = 0; $row < 5; $row++) {
            if ($done == 1) { last; };
            for (my $col = 0; $col < 5; $col++) {
                if ($letter eq $grid->[$row][$col]) {
                    $gridrow = $row;
                    $gridcol = $col;
                    $done = 1;
                    last;
                }
            }
        }
        return [$gridrow, $gridcol];
    };

    my $incr = sub { # for incrementing grid indexes so they loop
        my ($val) = @_;
        if ($val == 4) {
            return 0;
        }
        return $val + 1;
    };

    my $decr = sub { # for decrementing grid indexes so they loop
        my ($val) = @_;
        if ($val == 0) {
            return 4;
        }
        return $val - 1;
    };

    my $encipher = sub {
        my ($one, $two) = @_;

        my $onepos = $find->($one);
        my $twopos = $find->($two);

        my ($oneenc, $twoenc);

        if ($onepos->[0] == $twopos->[0]) {
            $oneenc = $grid->[$onepos->[0]][$incr->($onepos->[1])];
            $twoenc = $grid->[$twopos->[0]][$incr->($twopos->[1])];
            return [$oneenc, $twoenc];
        }

        if ($onepos->[1] == $twopos->[1]) {
            $oneenc = $grid->[$incr->($onepos->[0])][$onepos->[1]];
            $twoenc = $grid->[$incr->($twopos->[0])][$twopos->[1]];
            return [$oneenc, $twoenc];
        }

        $oneenc = $grid->[$onepos->[0]][$twopos->[1]];
        $twoenc = $grid->[$twopos->[0]][$onepos->[1]];
        return [$oneenc, $twoenc];
    };

    my $decipher = sub {
        my ($one, $two) = @_;

        my $onepos = $find->($one);
        my $twopos = $find->($two);

        my ($onedec, $twodec);

        if ($onepos->[0] == $twopos->[0]) {
            $onedec = $grid->[$onepos->[0]][$decr->($onepos->[1])];
            $twodec = $grid->[$twopos->[0]][$decr->($twopos->[1])];
            return [$onedec, $twodec];
        }

        if ($onepos->[1] == $twopos->[1]) {
            $onedec = $grid->[$decr->($onepos->[0])][$onepos->[1]];
            $twodec = $grid->[$decr->($twopos->[0])][$twopos->[1]];
            return [$onedec, $twodec];
        }

        $onedec = $grid->[$onepos->[0]][$twopos->[1]];
        $twodec = $grid->[$twopos->[0]][$onepos->[1]];
        return [$onedec, $twodec];
    };

    return {
        enc => sub {
            my ($one, $two) = @_;
            return $encipher->($one, $two);
        },
        dec => sub {
            my ($one, $two) = @_;
            return $decipher->($one, $two);
        }
    }

}

