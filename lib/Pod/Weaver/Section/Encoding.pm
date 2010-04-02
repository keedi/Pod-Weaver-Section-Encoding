package Pod::Weaver::Section::Encoding;
use Moose;
with 'Pod::Weaver::Role::Section';
# ENCODING: utf-8
# ABSTRACT: add a encoding pod tag with encoding

use Moose::Autobox;

=head1 OVERVIEW
 
This section plugin will produce a hunk of Pod giving the encoding of the document
as well as an encoding, like this:
 
    =encoding utf-8
 
It will look for the first package declaration, and for a comment in this form:
 
    # ENCODING: utf-8

You have to add C<[Encoding]> in your weaver.* configuration file:

    [@CorePrep]
    
    [Encoding]
    
    [Name]
    [Version]
    
    [Region  / prelude]
    
    ...

I stole this code from L<Pod::Weaver::Section::Name>.
 
=cut

use Pod::Elemental::Element::Pod5::Command;
use Pod::Elemental::Element::Pod5::Ordinary;
use Pod::Elemental::Element::Nested;

sub weave_section {
  my ($self, $document, $input) = @_;

  return unless my $ppi_document = $input->{ppi_document};
  my $pkg_node = $ppi_document->find_first('PPI::Statement::Package');

  my $filename = $input->{filename} || 'file';

  Carp::croak sprintf "couldn't find package declaration in %s", $filename
    unless $pkg_node;

  my $package = $pkg_node->namespace;

  my ($abstract)
    = $ppi_document->serialize =~ /^\s*#+\s*ENCODING:\s*(.+)$/m;

  $self->log([ "couldn't find encoding in %s", $filename ]) unless $abstract;
 
  my $name_para = Pod::Elemental::Element::Nested->new({
    command  => 'encoding',
    content  => $abstract,
  });
  
  $document->children->push($name_para);
}

1;
