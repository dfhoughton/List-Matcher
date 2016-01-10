use strict;
use warnings;

use List::Matcher;

use Test::More;    # tests => 26;

my $m = List::Matcher->new;

is $m->pattern( [qw( cat dog )] ),                   '(?:cat|dog)';
is $m->pattern( [qw( cat rat )] ),                   '(?:[cr]at)';
is $m->pattern( [qw( cat camel )] ),                 '(?:ca(?:mel|t))';
is $m->pattern( [qw( cat flat sprat )] ),            '(?:(?:c|fl|spr)at)';
is $m->pattern( [qw( catttttttttt )] ),              '(?:cat{10})';
is $m->pattern( [qw( cat-t-t-t-t-t-t-t-t-t )] ),     '(?:ca(?:t-){9}t)';
is $m->pattern( [qw( catttttttttt batttttttttt )] ), '(?:[bc]at{10})';
is $m->pattern( [qw( cad bad dad )] ),               '(?:[b-d]ad)';
is $m->pattern( [qw( cat catalog )] ),               '(?:cat(?:alog)?)';
is $m->pattern( [ 1 .. 31 ] ), '(?:[4-9]|1\d?|2\d?|3[01]?)';
is List::Matcher->pattern( [qw( cat dog )] ), "(?:cat|dog)";
is List::Matcher->rx(      [qw( cat dog )] ), qr/(?:cat|dog)/;
$m = List::Matcher->new(
   normalize_whitespace => 1,
   bound                => 1,
   case_insensitive     => 1,
   multiline            => 1,
   atomic               => 0,
   symbols              => { num => '\d++' }
);
my $m2 = $m->bud( case_insensitive => 0 );
ok !$m2->case_insensitive;
is List::Matcher->pattern( [qw(cat dog)], atomic => 0 ), "cat|dog";
is List::Matcher->pattern( [qw(cat dog)], atomic => 1 ), "(?:cat|dog)";
is List::Matcher->pattern( [qw( cat dog )] ), "(?:cat|dog)";
is List::Matcher->pattern( [qw( cat dog )], backtracking => 0 ), "(?>cat|dog)";
is List::Matcher->pattern( [qw(cat)], bound => 'word' ),   "(?:\\bcat\\b)";
is List::Matcher->pattern( [qw(cat)], bound => 1 ),        "(?:\\bcat\\b)";
is List::Matcher->pattern( [qw(cat)], bound => 'line' ),   "(?:^cat$)";
is List::Matcher->pattern( [qw(cat)], bound => 'string' ), "(?:\\Acat\\z)";
is List::Matcher->pattern( [ 1 ... 1000 ],
   bound => { test => qr/\d/, left => '(?<!\d)', right => '(?!\d)' } ),
  "(?:(?<!\\d)[1-9](?:\\d\\d?)?(?!\\d))";
is List::Matcher->pattern( ['     cat     '] ), "(?:(?:\\ ){5}cat(?:\\ ){5})";
is List::Matcher->pattern( ['     cat     '], strip => 1 ), "(?:cat)";
is List::Matcher->pattern( [qw( Cat cat CAT )] ), "(?:C(?:AT|at)|cat)";
is List::Matcher->pattern( [qw( Cat cat CAT )], case_insensitive => 1 ),
  "(?i:cat)";
is List::Matcher->pattern( [qw(cat)], multiline => 1 ), "(?m:cat)";
is List::Matcher->pattern(
   [ ' cat  walker ', '  dog walker', 'camel  walker' ] ),
  "(?:\\ (?:\\ dog\\ walker|cat\\ \\ walker\\ )|camel\\ \\ walker)";
is List::Matcher->pattern( [ ' cat  walker ', '  dog walker', 'camel  walker' ],
   normalize_whitespace => 1 ),
  "(?:(?:ca(?:mel|t)|dog)\\s++walker)";
is List::Matcher->pattern(
   [ 'Catch 22', '1984', 'Fahrenheit 451' ],
   symbols => { /\d+/ => '\d++' }
  ),
  "(?:(?:(?:Catch|Fahrenheit)\\ )?\\d++)";
is List::Matcher->pattern(
   [ 'Catch foo', 'foo', 'Fahrenheit foo' ],
   symbols => { 'foo' => '\d++' }
  ),
  "(?:(?:(?:Catch|Fahrenheit)\\ )?\\d++)";
is List::Matcher->pattern(
   [ 'Catch foo', 'foo', 'Fahrenheit foo' ],
   symbols => { foo => '\d++' }
  ),
  "(?:(?:(?:Catch|Fahrenheit)\\ )?\\d++)";
is List::Matcher->pattern( [qw(cat)], name => 'cat' ), "(?<cat>cat)";

$m = List::Matcher->new( atomic => 0, bound => 1 );

my $year = $m->pattern( [ 1901 .. 2000 ], name => 'year' );
my $mday = $m->pattern( [ 1 .. 31 ],      name => 'mday' );
my @weekdays = qw( Monday Tuesday Wednesday Thursday Friday Saturday Sunday );
@weekdays = ( @weekdays, map { substr $_, 0, 3 } @weekdays );
my $wday = $m->pattern( \@weekdays, case_insensitive => 1, name => 'wday' );
my @months =
  qw( January February March April May June July August September October November December );
@months = ( @months, map { substr $_, 0, 3 } @months );
my $mo = $m->pattern( \@months, case_insensitive => 1, name => 'mo' );

my $date_20th_century = $m->rx(
   [
      'wday, mo mday',
      'wday, mo mday year',
      'mo mday, year',
      'mo year',
      'mday mo year',
      'wday',
      'year',
      'mday mo',
      'mo mday',
      'mo mday year'
   ],
   normalize_whitespace => 1,
   atomic               => 1,
   bound                => 1,
   symbols              => {
      year => { pattern => $year, atomic => 1, left => '1', right => '1' },
      mday => { pattern => $mday, atomic => 1, left => '1', right => '1' },
      wday => { pattern => $wday, atomic => 1, left => 'a', right => 'a' },
      mo   => { pattern => $mo,   atomic => 1, left => 'a', right => 'a' }
   }
);

ok 'Friday' =~ $date_20th_century;
is $+{wday}, 'Friday';
is $+{year}, undef;
is $+{mo},   undef;
is $+{mday}, undef;
ok 'August 27' =~ $date_20th_century;
is $+{mo},   'August';
is $+{mday}, '27';
is $+{year}, undef;
is $+{wday}, undef;
ok 'May 6, 1969' =~ $date_20th_century;
is $+{mo},   'May';
is $+{mday}, '6';
is $+{year}, '1969';
is $+{wday}, undef;
ok '1 Jan 2000' =~ $date_20th_century;
is $+{mday}, '1';
is $+{mo},   'Jan';
is $+{year}, '2000';
is $+{wday}, undef;
ok 'this is not actually a date' !~ $date_20th_century;
is List::Matcher->pattern(
   [ 'cat and dog', '# is sometimes called the pound symbol' ] ),
  "(?:\\#\\ is\\ sometimes\\ called\\ the\\ pound\\ symbol|cat\\ and\\ dog)";
is List::Matcher->pattern(
   [ 'cat and dog', '# is sometimes called the pound symbol' ],
   not_extended => 1 ),
  "(?-x:cat and dog|# is sometimes called the pound symbol)";
is List::Matcher->pattern( [qw(cat)], bound => 'word_left' ),   "(?:\\bcat)";
is List::Matcher->pattern( [qw(cat)], bound => 'string_left' ), "(?:\\Acat)";
is List::Matcher->pattern( [qw(cat)], bound => 'line_right' ),  "(?:cat$)";
is List::Matcher->pattern( [qw( cat #@% )], bound => 'word' ),
  "(?:\\#@%|\\bcat\\b)";
my $rx = List::Matcher->pattern(
   [qw(dddd ddddddd)],
   bound => 'word',
   symbols =>
     { d => { pattern => '\d', atomic => 1, left => '0', right => '0' } },
   atomic => 0
);
is $rx, '\b\d{4}(?:\d{3})?\b';

done_testing();
