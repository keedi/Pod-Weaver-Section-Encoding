package Pod::Weaver::Section::Encoding;
use Moose;
with 'Pod::Weaver::Role::Section';
# ENCODING: utf-8
# ABSTRACT: add a encoding pod tag with encoding

use Moose::Autobox;

has 'default' => ( is => 'ro' );

=head1 OVERVIEW
 
This section plugin will produce a hunk of Pod giving the encoding of the document
as well as an encoding, like this:
 
    =encoding utf-8
 
It will look for a comment in this form:
 
    # ENCODING: utf-8

You have to add C<[Encoding]> in your weaver.* configuration file:

    [@CorePrep]
    
    [Encoding]
    
    [Name]
    [Version]
    
    [Region  / prelude]
    
    ...

You can provide a default encoding like so:

    [Encoding]
    default = utf-8

If you do not provide a default encoding and one cannot be found, this module
will throw an error.

I stole this code from L<Pod::Weaver::Section::Name>.
 
=cut

use Pod::Elemental::Element::Pod5::Command;
use Pod::Elemental::Element::Pod5::Ordinary;
use Pod::Elemental::Element::Nested;

sub weave_section {
  my ($self, $document, $input) = @_;

  return unless my $ppi_document = $input->{ppi_document};

  my $filename = $input->{filename} || 'file';

  my ($abstract)
    = $ppi_document->serialize =~ /^\s*#+\s*ENCODING:\s*(.+)$/m;

  defined $abstract or $abstract = $self->default;

  $self->log([ "couldn't find encoding in %s", $filename ]) unless $abstract;
 
  my $name_para = Pod::Elemental::Element::Nested->new({
    command  => 'encoding',
    content  => $abstract,
  });
  
  $document->children->push($name_para);
}

1;
