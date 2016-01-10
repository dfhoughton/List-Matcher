use strict;
use warnings;

use List::Matcher;
use List::MoreUtils;

package List::Matcher::Test::Exception;
use base qw(Test::Class);
use Test::More;
use Test::Fatal;

sub test_bad_symbol : Test(2) {
   my $e = exception {
      List::Matcher->pattern( [qw(cat)], symbols => { foo => undef } );
   };
   ok $e && $e->isa('List::Matcher::Error');
   like $e->message, 'symbol foo requires a pattern';
}

sub test_bad_name : Test(2) {
   my $e = exception {
      List::Matcher->pattern( [qw(cat)], name => [] );
   };
   ok $e && $e->isa('List::Matcher::Error');
   is $e->message, 'name must be a string or symbol';
}

sub test_bad_bound_symbol : Test(2) {
   my $e = exception {
      List::Matcher->pattern( qw(cat), bound => 'foo' );
   };
   ok $e && $e->isa('List::Matcher::Error');
   is $e->message, 'unfamiliar value for :bound option: :foo';
}

sub test_bad_bound_no_test : Test(2) {
   my $e = exception {
      List::Matcher->pattern( [qw(cat)], bound => { left => '.' } );
   };
   ok $e && $e->isa('List::Matcher::Error');
   is $e->message, 'no boundary test provided';
}

sub test_bad_bound_neither : Test(2) {
   my $e = exception {
      List::Matcher->pattern( [qw(cat)], bound => { test => '.' } );
   };
   ok $e && $e->isa('List::Matcher::Error');
   is $e->message, 'neither bound provided';
}

sub test_bad_bound_strange_test : Test(2) {
   my $e = exception {
      List::Matcher->pattern( [qw(cat)], bound => { test => [], left => '.' } );
   };
   ok $e && $e->isa('List::Matcher::Error');
   is $e->message, 'test must be Regexp or String';
}

sub test_bad_bound_not_string : Test(2) {
   my $e = exception {
      List::Matcher->pattern( [qw(cat)], bound => { test => /./, left => [] } );
   };
   ok $e && $e->isa('List::Matcher::Error');
   is $e->message, 'bounds must be strings';
}

sub test_bad_symbol_no_pattern : Test(2) {
   my $e = exception {
      List::Matcher->pattern( [qw(cat)], symbols => { foo => {} } );
   };
   ok $e && $e->isa('List::Matcher::Error');
   is $e->message, 'symbol foo requires a pattern';
}

sub test_bad_group_name : Test(2) {
   my $e = exception {
      List::Matcher->pattern( [qw(cat)], name => '3' );
   };
   ok $e && $e->isa('List::Matcher::Error');
   is $e->message, '3 does not work as the name of a named group';
}

sub test_bad_symbol_key : Test(2) {
   my $e = exception {
      List::Matcher->pattern( [qw(cat)], symbols => { [] => 'foo' } );
   };
   ok $e && $e->isa('List::Matcher::Error');
   is $e->message,
     'symbols variable [] is neither a string, a symbol, nor a regex';
}

sub test_vetting : Test(2) {
   my $e = exception {
      List::Matcher->pattern( [qw(cat)], symbols => { foo => '++' }, vet => 1 );
   };
   ok $e && $e->isa('List::Matcher::Error');
   is $e->message, 'the symbol foo has an ill-formed pattern: ++';
}
