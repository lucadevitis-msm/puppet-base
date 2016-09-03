# This class manages the creation of the specified certificates.
#
# @param entries An hash of value for `create_resources` function to create
#                `ifetoolbelt::define::binary` resources.
class base::ife ($entries = undef)
{
  if $entries != undef {
    include ifetoolbelt

    validate_hash($entries)

    create_resources(ifetoolbelt::define::binary, $entries)
  }
}
