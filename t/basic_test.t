use strict;
use warnings;

use List::Matcher;

package List::Matcher::Test::Basic;
use base qw(Test::Class);
use Test::More;
use Test::Exception;

sub test_simple : Test(3) {
   my @words = qw(cat dog camel);
   my $rx    = List::Matcher->rx( \@words );
   for my $w (@words) {
      like $w, $rx;
   }
}

sub test_word_chars : Tests {
   my @word = grep /\w/, map chr, ( 1 .. 255 );
   my @chars = ( @word, '+' );
   my $rx = List::Matcher->pattern( \@chars );
   is $rx, '[+\w]';
   $rx = qr/$rx/;
   for my $c (@chars) {
      like $c, $rx;
   }
   @chars = ( @word, '@' );
   $rx = List::Matcher->pattern( \@chars );
   is $rx, '[@\w]';
   $rx = qr/$rx/;
   for my $c (@chars) {
      like $c, $rx;
   }
}

sub test_word_chars_case_insensitive : Tests {
   my @word = grep /\w/, map chr, ( 1 .. 255 );
   my @chars = ( @word, '+' );
   my $rx = List::Matcher->pattern( \@chars, case_insensitive => 1 );
   is $rx, '(?i:[+\w])';
   $rx = qr/$rx/;
   for my $c (@chars) {
      like $c, $rx;
   }
}

sub test_num_chars : Tests {
   my @words = 0 .. 9;
   my $rx    = List::Matcher->pattern( \@words );
   is $rx, '\d';
   $rx = qr/$rx/;
   for my $w (@words) {
      like $w, $rx;
   }
}

sub test_space_chars : Tests {
   my @words = grep /\s/, map chr, ( 1 .. 255 );
   my $rx = List::Matcher->pattern( \@words );
   is $rx, '\s';
   $rx = qr/$rx/;
   for my $w (@words) {
      like $w, $rx;
   }
}

sub test_bounds : Tests {
   my @words = qw(cat dog);
   my $rx = List::Matcher->pattern( \@words, bound => 1 );
   is $rx, '(?:\b(?:cat|dog)\b)';
   $rx = qr/$rx/;
   for my $w (@words) {
      like $w, $rx;
   }
}

sub test_repeats : Test(2) {
   my $rx = List::Matcher->pattern( [qw(aaaaaaaaaa)] );
   is $rx, '(?:a{10})';
   $rx = List::Matcher->pattern( [qw(bbbaaaaaaaaaabbbaaaaaaaaaa)] );
   is $rx, '(?:(?:bbba{10}){2})';
}

sub test_opt_suffix : Test(3) {
   my @words = qw(the them);
   my $rx    = List::Matcher->pattern( \@words );
   is $rx, '(?:them?)';
   $rx = qr/$rx/;
   for my $w (@words) {
      like $w, $rx;
   }
}

sub test_opt_prefix : Test(3) {
   my @words = qw(at cat);
   my $rx    = List::Matcher->pattern(@words);
   is $rx, '(?:c?at)';
   $rx = qr/$rx/;
   for my $w (@words) {
      like $w, $rx;
   }
}

sub test_symbols_string : Test(2) {
   my $words = ['cat dog'];
   my $rx = List::Matcher->pattern( $words, symbols => { ' ' => '\s++' } );
   is $rx, '(?:cat\s++dog)';
   $rx = qr/$rx/;
   for my $w (@$words) {
      like $w, $rx;
   }
}

sub test_symbols_rx : Test(4) {
   my @words = qw(year year2000 year1999);
   my $rx =
     List::Matcher->pattern( \@words,
      symbols => { qr/(?<!\d)\d{4}(?!\d)/ => undef } );
   is $rx, '(?:year(?-mix:(?<!\d)\d{4}(?!\d))?)';
   $rx = qr/$rx/;
   for my $w (@words) {
      like $w, $rx;
   }
}

sub test_fancy_rx : Test(3) {
   my $words = ['   cat   dog  '];
   my $good  = ['the cat  dog is an odd beast'];
   my $bad   = [
      'the catdog is an odd beast',
      'the cat doggy is an odd beast',
      'the scat dog is an odd beast'
   ];
   my $rx =
     List::Matcher->pattern( $words, bound => 1, normalize_whitespace => 1 );
   is $rx, '(?:\bcat\s++dog\b)';
   $rx = qr/$rx/;
   ok( ( all { $_ =~ $rx } @$good ), 'not bothered by odd space' );
   ok( ( none { $_ =~ $rx } @$bad ), 'needs interior space and boundaries' );
}

sub test_symbols_borders : Test(2) {
   my @words = 1 .. 31;
   my $rx =
     List::Matcher->rx( \@words,
      bound => { test => /\d/, left => '(?<!\d)', right => '(?!\d)' } );
   my @good = map { "a${_}b" } @words;
   my @bad  = map { "0${_}0" } @words;
   ok all { $_ =~ $rx } @good;
   ok none { $_ =~ $rx } @bad;
}

sub test_string_bound : Test(4) {
   my $rx = List::Matcher->pattern( ['cat'], bound => 'string' );
   is $rx, '(?:\Acat\z)';
   $rx = qr/$rx/;
   like 'cat',        $rx, 'matches whole string';
   unlike "cat\ndog", $rx, 'line breaks do not suffice';
   unlike ' cat ',    $rx, 'word boundaries do not suffice';
}

sub test_string_left_bound : Test(1) {
   my $rx = List::Matcher->pattern( ['cat'], bound => 'string_left' );
   is $rx, '(?:\Acat)';
}

sub test_string_right_bound : Test(1) {
   my $rx = List::Matcher->pattern( ['cat'], bound => 'string_right' );
   is $rx, '(?:cat\z)';
}

sub test_line_bound : Test(4) {
   my $rx = List::Matcher->pattern( ['cat'], bound => 'line' );
   is $rx, '(?:^cat$)';
   $rx = qr/$rx/;
   like 'cat',      $rx, 'matches whole string';
   like "cat\ndog", $rx, 'line breaks suffice';
   unlike ' cat ',  $rx, 'word boundaries do not suffice';
}

sub test_line_left_bound : Test(1) {
   my $rx = List::Matcher->pattern( ['cat'], bound => 'line_left' );
   is $rx, '(?:^cat)';
}

sub test_line_right_bound : Test(1) {
   my $rx = List::Matcher->pattern( ['cat'], bound => 'line_right' );
   is $rx, '(?:cat$)';
}

sub test_word_bound : Test(1) {
   my $rx = List::Matcher->pattern( qw( cat dog ), bound => 'word' );
   is $rx, '(?:\b(?:cat|dog)\b)';
}

sub test_word_left_bound : Test(1) {
   my $rx = List::Matcher->pattern( qw( cat dog ), bound => 'word_left' );
   is $rx, '(?:\b(?:cat|dog))';
}

sub test_word_right_bound : Test(1) {
   my $rx = List::Matcher->pattern( qw( cat dog ), bound => 'word_right' );
   is $rx, '(?:(?:cat|dog)\b)';
}

sub test_dup_atomic : Test(1) {
   my $m = List::Matcher->new( atomic => 1 );
   my $rx = $m->pattern( qw( cat dog ), atomic => 0 );
   is $rx, "cat|dog";
}

sub test_dup_backtracking : Test(1) {
   my $m = List::Matcher->new( backtracking => 1 );
   my $rx = $m->pattern( qw( cat dog ), backtracking => 0 );
   is $rx, "(?>cat|dog)";
}

sub test_dup_bound : Test(1) {
   my $m = List::Matcher->new( bound => 0, atomic => 0 );
   my $rx = $m->pattern( qw( cat dog ), bound => 1 );
   is $rx, '\b(?:cat|dog)\b';
}

sub test_dup_bound_string : Test(1) {
   my $m = List::Matcher->new( bound => 0, atomic => 0 );
   my $rx = $m->pattern( qw( cat dog ), bound => 'string' );
   is $rx, '\A(?:cat|dog)\z';
}

sub test_dup_bound_line : Test(1) {
   my $m = List::Matcher->new( bound => 0, atomic => 0 );
   my $rx = $m->pattern( qw( cat dog ), bound => 'line' );
   is $rx, '^(?:cat|dog)$';
}

sub test_dup_bound_fancy : Test(1) {
   my $m = List::Matcher->new( bound => 0, atomic => 0 );
   my $rx = $m->pattern( qw( 1 2 ),
      bound => { test => /\d/, left => '(?<!\d)', right => '(?!\d)' } );
   is $rx, '(?<!\d)[12](?!\d)';
}

sub test_dup_strip : Test(1) {
   my $m = List::Matcher->new( atomic => 0 );
   my $rx = $m->pattern( ['cat'], strip => 1 );
   is $rx, 'cat';
}

sub test_dup_case_insensitive : Test(1) {
   my $m = List::Matcher->new;
   my $rx = $m->pattern( qw(cat), case_insensitive => 1 );
   is $rx, '(?i:cat)';
}

sub test_dup_normalize_whitespace : Test(1) {
   my $m = List::Matcher->new( atomic => 0 );
   my $rx = $m->pattern( ['  cat     dog  '], normalize_whitespace => 1 );
   is $rx, 'cat\s++dog';
}

sub test_dup_symbols : Test(1) {
   my $m = List::Matcher->new( atomic => 0 );
   my $rx = $m->pattern( ['cat dog'], symbols => { ' ' => '\s++' } );
   is $rx, 'cat\s++dog';
}

sub test_multiline : Test(1) {
   my $rx = List::Matcher->pattern( [qw( cat dog )], multiline => 1 );
   is $rx, '(?m:cat|dog)';
}

sub test_dup_multiline : Test(1) {
   my $m = List::Matcher->new( atomic => 0 );
   my $rx = $m->pattern( [qw( cat dog )], multiline => 1 );
   is $rx, '(?m:cat|dog)';
}

sub test_name : Test(1) {
   my $m = List::Matcher->new( name => 'foo' );
   my $rx = $m->pattern([qw( cat dog )]);
   is $rx, '(?<foo>cat|dog)';
}

sub test_vetting_good : Test(1) {
   List::Matcher->pattern( [qw(cat)], symbols => { foo => 'bar' }, vet => 1 );
   ok 'good regexen are vetted appropriately';
}

sub test_vetting_bad : Test(1) {
   throws_ok {
      List::Matcher->pattern( [qw(cat)], symbols => { foo => '+' }, vet => 1 );
   }
   'List::Matcher::Error';
}

sub test_not_extended : Test(3) {
   my $m = List::Matcher->new( not_extended => 1 );
   my $rx = $m->pattern( [ ' ', '#' ] );
   is $rx, '(?-x:#| )';
   $rx = qr/$rx/;
   like ' ', $rx;
   like '#', $rx;
}

sub test_symbol_bound : Test(1) {
   my $rx = List::Matcher->pattern(
      [qw(1 2 3 d)],
      bound   => 'word',
      symbols => { d => { pattern => '\d{4}', left => '0', right => '0' } },
      atomic  => 0
   );
   is $rx, '\b(?:[1-3]|\d{4})\b';
}

sub test_symbol_bound_left : Test(1) {
   my $rx = List::Matcher->pattern(
      [qw(1 2 3 d)],
      bound   => 'word_left',
      symbols => { d => { pattern => '\d{4}', left => '0', right => '0' } },
      atomic  => 0
   );
   is $rx, '\b(?:[1-3]|\d{4})';
}

sub test_symbol_bound_right : Test(1) {
   my $rx = List::Matcher->pattern(
      [qw(1 2 3 d)],
      bound   => 'word_right',
      symbols => { d => { pattern => '\d{4}', left => '0', right => '0' } },
      atomic  => 0
   );
   is $rx, '(?:[1-3]|\d{4})\b';
}

sub test_sort_bound_word : Test(1) {
   my $rx = List::Matcher->pattern( [qw(a)], bound => 'word', atomic => 0 );
   is $rx, '\ba\b';
}
