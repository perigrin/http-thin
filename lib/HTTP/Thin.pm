package HTTP::Thin;
use 5.12.1;
use warnings;
use parent qw(HTTP::Tiny);
use Safe::Isa;
use Class::Method::Modifiers;
use HTTP::Response;

our $VERSION = $HTTP::Tiny::VERSION;

around request => sub {
        my ($next, $self, @args) = @_;
        if (@args == 1 && $args[0]->$_isa('HTTP::Request')) {
                my $options = {};
                $options->{headers} = \%{ $args[0]->headers } if $args[0]->headers->as_string;
                $options->{content} = $args[0]->content if $args[0]->content;
                @args = ( 
                        $args[0]->method,
                        $args[0]->uri,
                        ( keys %$options ? $options : () ),
                );
        }
        my $res =  $self->$next(@args);
        return HTTP::Response->new(
                $res->{status},
                $res->{reason},
                [ %{ $res->{headers} } ],
                $res->{content},
        );
};

1;
