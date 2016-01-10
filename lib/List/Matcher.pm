use strict;
use warnings;
use Exception::Class qw( List::Matcher::Exception );

package List::Matcher;

# as safe as quote-meta, but not as free with the slashes
sub _qm_safe {
   join '', map {
          /\f\n\r\t/ ? '\\' . ( ( my $v = $_ ) =~ tr/\f\n\r\t/fnrt/ )
        : /\A[\s\p{Pattern_Syntax}]\z/ ? "\\$_"
        : $_
   } split /([\s\p{Pattern_Syntax}])/, shift;
}

# generate a quoting function from a list of characters to quote
sub _quote_gen {
   my %h = map { (my $c = $_); my $d = $c; $c =~ tr/\f\n\r\t/fnrt/; $d => $c } @_;
   sub {
      join '', map { $h{$_} // $_ } split //, shift;
     }
}

our $quote_cc = _quote_gen qw( [ ] ^ \ - $ ), split //, "\f\n\r\t";

our $quote_x = _quote_gen qw( { } [ ] $ ^ \ . + * < > & % # ), qw{ ( ) },
  split //, "\f\n\r\t ";

sub pattern {

}

sub rx {

}

sub new {
   my ( $class, %args ) = @_;
   $args{symbols} //= {};
   $args{$_} //= 1 for qw( atomic backtracking );
   $args{_bound} = $args{bound};
   $args{strip} ||= $args{normalize_whitespace};
   $args{symbols} = _deep_dup($args{symbols});
   if ( my $name = $args{name} ) {
      eval { qr/(?<$name>.)/ };
      List::Matcher::Exception->throw(
         "$name does not work as the name of a named group")
        if $@;
   }
   if ( my $bound = $args{bound} ) {

   }

   my $self = { _ => \%args };
   bless $self, $class;
}

sub _deep_dup {
   my $ref = shift;
   my $r   = ref $ref;
   if ( $r eq 'HASH' ) {
      [ map { _deep_dup $_ } @$ref ];
   }
   elsif ( $r eq 'ARRAY' ) {
      {
         map { $_ => _deep_dup $r->{$_} } keys %$ref
      };
   }
   else {
      $r;
   }
}

1;
