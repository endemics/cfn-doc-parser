cfn-doc-parser.rb
=================

A script to extract from AWS documentation the effects of resource properties updates via CloudFormation.

This is a quick hack that I needed for another project in order to evaluate what side-effect the application of a cloudformation stack update would have.

requirements
------------

Ruby (works on my machineTM with ruby 1.9) and the following gems: 'nokogiri', 'open-uri', 'json'

usage
-----

This script is meant to be used to dump the informations as a hash affected to global variable $cfn_rsc_chng.

So you would do:
`./cfn-doc-parser.rb > result.rb`

Then you would require the file result.rb and use the $cfn_rsc_chng variable directly.

The hash of hash of hash has the following structure:

```
    {
      "CFN resource type" =>
        {
          "Property name" =>
            {
              ":unknown|:nointerruption|:someinterruption|:replacement" => "Extracted string"
            }
        }
    }

```

Hence you can check what side effect the modification of the property "Property name" of the resource type "CFN resource type" would cause by (trying) to access $cfn_rsc_chng["CFN resource type"]["Property name"] and check the value of its key.

If it's :unknown, the script was unable to retrieve a replacement mode for that property. Most likely, it depends on the context. For more information, read the value of $cfn_rsc_chng["CFN resource type"]["Property name"][:unknown].

If it's :nointerruption, it means there won't be any interruption when the change will be applied.

If it's :someinterruptions, it means there will be interruptions when the change will be applied.

If it's :replacement, then the resource will be destroyed/recreated.

If it's :nointerruption, it means there won't be any interruption when the change will be applied.

