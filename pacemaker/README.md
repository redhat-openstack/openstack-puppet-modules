# Puppet Pacemaker module

This Puppet module is intended to work with the running Pacemaker
cluster to manage its configuration. It can create, update and remove
most of the configuration objects and query their status.

The interface of the Puppet types in the module is loosely based on
**puppetlabs/corosync** types with *cs_* prefix changed to the *pacemaker_*
prefix but it have been significantly reworked and is not compatible.

**puppet-pacemaker** is much more sophisticated then the
**puppetlabs/corosync** module and provides a lot of debugging
features, checks, configuration options and it can work even when
the Puppet is being run on many cluster nodes at the same time and
without neither **crm** nor **pcs** being installed.

## License
Apache 2.0

# Pacemaker types

These types are used to configure Pacemaker object and are the core of 
this module. You can find some "interactive examples" of their usage in
the *examples* folder.

## pacemaker_resource

This is the most important resource type. It creates, updates and
removes Pacemaker primitives.

### Parameters

#### primitive_class

The basic class of this primitive. It could be *ocf*, *lsb*, *systemd*
and some others.
Default: ocf

#### primitive_provider

The provider or vendor of the primitive. For OCF class can be
*pacemaker*, *heartbeat* or vendor-specific values.
Default: pacemaker

#### primitive_type

The actual provider script or service to use. Should be equal to the
OCF file name, or to the service name if other classes are used.
Default: Stateful

#### parameters

The Hash of resource instance attribute names and their values.
These attributes are used to configure the running service and,
usually, only OCF class supports them.

Example:

```puppet
{
  'a' => '1',
  'b' => '2',
},
```

#### operation

This data structure describes this primitive's operations and timeouts.

Example:

```puppet
{
  'monitor' => {
    'interval' => '20',
    'timeout'  => '10'
  },
  'start'   => {
    'timeout' => '30'
  },
  'stop'    => {
    'timeout' => '30'
  },
}
```

Using array and multiple monitors:

```puppet
[
  {
    'name'     => 'monitor',
    'interval' => '10',
    'timeout'  => '10',
  },
  {
    'name'     => 'monitor',
    'interval' => '60',
    'timeout'  => '10',
  },
  {
    'name'    => 'start',
    'timeout' => '30',
  },
  {
    'name'    => 'stop',
    'timeout' => '30',
  },
]
```

#### metadata

This hash can contain names and values of primitive's meta attributes.

Example:

```puppet
{
  'migration-threshold' => '100',
  'failure-timeout'     => '120',
}
```

#### complex_type

A primitive can be either a *simple* one, and run only as a single
instance. Or it can be *clone* and have many instances, or it can be
*master* and be able to have master and slave states.
Default: simple

#### complex_metadata

A hash of complex type related metadata names and values.

Example:

```puppet
{
  'interleave' => true,
  'master-max' => '1',
}
```

#### debug

This option makes supported provides to omit any changes to the system.
Providers will still retrieve the system state, compare it to the desired
state from the catalog and will try to sync state if there are differences.
But it will only show destructive commands that it would be executing in
the normal mode. It's better then Puppet's *noop* mode because it shows
sync actions and is useful for debugging.
Default: false

## pacemaker_location

This type can manage location constraints. Either the node and score
based ones or the rule based ones. This constraints can control the
primitive placement to nodes through priorities or rules.

### Parameters

#### primitive

The name of the Pacemaker primitive of this location.

#### score

The score values for a node/score location.

#### node

The node name of the node/score location.

#### rules

The rules data structure.

Example:

```puppet
[
  {
    'score' => '100',
    'expressions' => [
      {
        'attribute' => 'test1',
        'operation' => 'defined',
      }
    ]
  },
  {
    'score' => '200',
    'expressions' => [
      {
        'attribute' => 'test2',
        'operation' => 'defined',
      }
    ]
  }
]
```

#### debug

Don't actually do changes
Default: false

## pacemaker_colocation

This type manages colocation constraints. If two resources are in a
colocation they will always be on the same node. Note that colocation
implies the start order because the second resource will always start
after the first.

### Parameters

#### first

The name of the first primitive

#### second

The name of the second primitive

#### score

The priority score of this constraint

#### debug

Don't actually do changes
Default: false

## pacemaker_order

This type can manage the order constraints. These constraints controls
the start and stop ordering of resources. Order doesn't imply colocation
and resources can run on different nodes.

### Parameters

#### first

(Mandatory)
The name of the first primitive.

#### second

(Mandatory)
The name of the second primitive.

#### score

The priority score of this constraint.
If greater than zero, the constraint is mandatory.
Otherwise it is only a suggestion.
Used for Pacemaker version 1.0 and below.
Default: undef

#### first_action

The action that the first resource must complete before second action
can be initiated for the then resource.
Allowed values: start, stop, promote, demote.
Default: undef (means start)

#### second_action

The action that the then resource can execute only after the
first action on the first resource has completed.
Allowed values: start, stop, promote, demote.
Default: undef (means the value of the first action)

#### kind

How to enforce the constraint. Allowed values:

* **optional**: Just a suggestion. Only applies if both resources are
  executing the specified actions.
  Any change in state by the first resource will have no effect on
  the then resource.
* **mandatory**: Always. If first does not perform first-action,
  then will not be allowed to performed then-action.
  If first is restarted, then (if running) will be stopped beforehand
  and started afterward.
* **serialize**: Ensure that no two stop/start actions occur
  concurrently for the resources.
  First and then can start in either order, but one must complete
  starting before the other can be started.
  A typical use case is when resource start-up puts a high load on
  the host.

Used only with Pacemaker version 1.1 and above.
Default: undef

#### symmetrical

If true, the reverse of the constraint applies for the opposite action
(for example, if B starts after A starts, then B stops before A stops).

Default: undef (means true)

#### require_all

Whether all members of the set must be active before continuing.

Default: undef (means true)

#### debug

Don't actually do changes
Default: false

## pacemaker_operation_default

This little type controls the default operation properties of the 
cluster resources. For example, you can set the default *timeout*
for every operation without it's own configured *timeout* value.

### parameters

#### name

The default property name

#### value

The default property value

#### debug

Don't actually do changes
Default: false

Example:

```puppet
pacemaker_operation_default { 'timeout' : value => '30' }
```

## pacemaker_resource_default

This little type controls the default meta-attributes of all resources
without their own defined values.

### parameters

#### name

The default property name

#### value

The default property value

#### debug

Don't actually do changes
Default: false

Example:

```puppet
pacemaker_resource_default { 'resource-stickiness' : value => '100' }
```

## pacemaker_property

This tiny type can the the cluster-wide properties.

### parameters

#### name

The property name

#### value

The property value

#### debug

Don't actually do changes
Default: false

Example:

```puppet
pacemaker_property { 'stonith-enabled' :
  value => false,
}
pacemaker_property { 'no-quorum-policy' :
  value => 'ignore',
}
```


## pacemaker_online

This little resource can wait until the cluster have settled and ready
to be configured. It can be useful in some cases, perhaps as an anchor,
but most other type's *xml* providers can wait for cluster on their own. 

Example:

```puppet
pacemaker_online { 'setup-finished' :}
```

## service (pacemaker provider)

This type uses the standard *service* type from the Puppet distribution
but implements the custom *pacemaker* provider. It can be used to start
and stop Pacemaker services the same way the Puppet starts and stops
system services.

It can query the service status, either on the entire cluster or on the
local node, start and stop single, cloned and master services.

There are also two special features:
- Adding location constraints. This provider can add the location
  constraint to enable the run of the primitive on the current node.
  It's needed in the asymmetric cluster configuration where services
  are not allowed to start anywhere unless explicitly allowed to.
- Disabling the basic service. For example, you have the *apache*
  primitive service in your cluster and are using an OCF script
  to manage it. In this can you will not want another instance of
  *apache* to start by the system init scripts or startup service.
  The provider will detect the running basic service and will stop
  and disable it's auto-run before trying to start the cluster service.

## pacemaker_nodes

This type is very special and designed to add and remove corosync 2 nodes
without restarting the service by providing the data structure like
this:

```puppet
{
  'node-1' => { 'id' => '1', 'ip' => '192.168.0.1'},
  'node-2' => { 'id' => '2', 'ip' => '192.168.0.2'},
}
```

Most likely you should never use this type.

## Pacemaker providers

Each *pacemaker_* type may have up to three different providers:

- *xml* provider. This provider is based on the *pacemaker* library
  XML parsing and generating capabilities and in most canes require
  only *cibadmin* to download XML CIB and apply patches, but can
  use *crm_attribute* too. These tools are written in C and are the
  core parts of the Pacemaker project and most likely will be present
  on every system.

- *pcs* provider. These provides are designed around the *pcs* cluster
  management tool usually found on Red Hat family systems. They should 
  not be as complex as *xml* providers, but *pcs* may not be available
  on you distribution. Currently it's implemented only for few types
  and they disabled because there is no reason to actually use them.

- *noop* provider. These providers do absolutely nothing completely
  disabling the resource if the provider is manually set to *noop*.
  This resource will not fail even if there is no Pacemaker installed.
  It can be useful if you want to turn off several resources.
  Puppet's *noop* meta-attribute will not do the same this because it
  still does the retrieve phase and will fail if the state cannot be
  obtained.

## pacemaker::wrapper

This definition can be applied to any Puppet managed service, even from
a third party module, and make this service a Pacemaker managed service
without modifying the Puppet code.

Wrapper can also create the OCF script from a Puppet file or template,
or the script can be obtained elsewhere. Actually, wrappers are only
practical for OCF managed services, because lsb, systemd or upstart
services can be managed directly by the cluster.

It can also create *ocf_handlers*. The OCF handler is a special shell
script that can call the OCF script with all environment variables
and parameters set. The handler can be used to take manual control
over the pacemaker managed service and start and stop them without
the cluster. It can be useful for debugging or during the
disaster recovery.

### Parameters

#### ensure
(optional) Create or remove the files
Default: present

#### ocf_root_path
(optional) Path to the ocf folder
Default: /usr/lib/ocf

#### primitive_class
(optional) Class of the created primitive
Default: ocf

#### primitive_provider
(optional) Provider of the created primitive
Default: pacemaker

#### primitive_type
(optional) Type of the created primitive. Set this to your OCF script.
Default: Stateful

#### prefix
(optional) Use p_ prefix for the Pacemaker primitive. There is no
need to use it since the service provider can disable the basic
service on its own.
Default: false

#### parameters
(optional) Instance attributes hash of the primitive
Default: undef

#### operations
(optional) Operations hash of the primitive
Default: undef

#### metadata
(optional) Primitive meta-attributes hash
Default: undef

#### complex_metadata
(optional) Meta-attributes of the complex primitive
Default: undef

#### complex_type
(optional) Set this to 'clone' or 'master' to create a
complex primitive
Default: undef

#### use_handler
(optional) Should the handler script be created
Default: true

#### handler_root_path
(optional) Where the handler should be placed
Default: /usr/local/bin

#### ocf_script_template
(optional) Generate the OCF script from this template
Default: undef

#### ocf_script_file
(optional) Download the OCF script from this file
Defaults: undef

#### create_primitive
(optional) Should the Pacemaker primitive be created
Defaults: true

#### service_provider
(optional) The name of Pacemaker service provider
to be set to this service.
Default: pacemaker

For example, if you have a simple service:

```puppet
service { 'apache' :
  ensure => 'running',
  enable => true,
}
```

You can convert it to the Pacemaker service just by adding this
definition:

```puppet
pacemaker:wrapper { 'apache' :
  primitive_type => 'apache',
  parameters => {
    'port' => '80',
  },
  operations => {
    'monitor' => {
      'interval' => '10',
    },
  },
}
```

Provided there is the ocf:pacemaker:apache script with the port
parameter, the *apache* Pacemaker primitive will be created and
started and the basic *apache* service will be disabled and stopped.

## STONITH

STONITH manifests are auto generated from the XML source
files by the generator script.

```bash
rake generate_stonith
```

The generated defined types can be found in *manifests/stonith*.
Every STONITH implementation has different parameters.

Example:

```puppet
class { "pacemaker::stonith::ipmilan" :
  address  => "10.10.10.100",
  username => "admin",
  password => "admin",
}
```

# Development

## Library structure

You can find these folders inside the **lib**:

- *facter* contains the fact **pacemaker_node_name**. It is equal to the 
  node name from the Pacemaker point of view. May be equal to either
  $::hostname of $::fqdn.

- *pacemaker* contains the Pacemaker library files. The Pacemaker
  module functions are split to submodules according to their role.
  There are also *xml* and *pcs* groups of files related to either
  *pcs* or *xml* provider and several common files.
  
- *puppet* contains Puppet types and provider. They are using the
  functions from the Pacemaker library.
  
- *serverspec* contains the custom ServerSpec types to work with
  Pacemaker. They are using the same library Puppet types and providers
  do. These types are used in the Acceptance tests to validate that
  Pacemaker have really be configured and its configuration contains
  the desired elements and parameters.

- *tools* contains two interactive tools: console and status. Console
  can be used to manually run the library functions either to debug them
  or to configure the cluster by hand. Status uses the library functions
  to implement something like pcs or crm status command to see the
  current cluster status.

## Data flow

When the catalog is being compiled the instance of each type will
be created and properties and parameters values will be assigned.

At this stage the values can be validated. If the property has
the *validate* function it will be called to check if the value is
correct or the exception can be raised. After tha validation the 
*munge* function will be called if the values need to be changed or
converted somehow. If the property accepts the array value every
elements will be validated and then munged separately.

When the catalog is compiled and delivered to the node Puppet will
start to apply it.

### Data retrieval

Puppet type will try to retrieve the current state first. It will
either use *prefetch* mechanics if it's enabled or will simply walk
through every resource in the catalog calling *exists?* functions
and then other getter functions to determine the current system state.

If prefetch is used, it will assign every provider, generated by the
*instances* function to the corresponding resource in the catalog.
During the transaction the resource will be able to use already
acquired data speeding the Puppet run up a little. Without prefetch
each provider will receive the system state when its resource is
processed separately.

#### Complex providers

Providers: pacemaker_resource, pacemaker_location, pacemaker_colocation, pacemaker_order.

This providers use *retrieve_data* function to get the configuration
and status data from the library and convert it to the form used
in the Puppet type by filling the *property_hash*. This happens
either during prefetch or when the *exists?* function is called.
Other getter function will just take their values from the
*property_hash* after it was filled with data.

#### Simple providers

Providers: pacemaker_property, pacemaker_resource_default,
pacemaker_operation_default, pacemaker_online.

These providers are much more simple. There is no *retrieve_data*
function and the values are just passed as the property_hash to
the provider from *instances* if the prefetch is used and then
are taken from this hash by the getter functions. If there is no
prefetch and *property_hash* is empty the values are retrieved
from the library directly by the getters. Actually there is only one
getter for *value* and an implicit getter for *ensure* or no getter
at all for the not ensurable *pacemaker_online*.

#### Library

Both complex and simple providers are using the library functions to
get the current state of the system. There is the *main data structure*
for each entity the library can work with. For example, the resources
use the *primitives* structure.

Every provider can either take the values directly from this structure
or it can use one of the many values helpers and predicate functions
such as *primitive_type* or *primitive_is_complex?*. Most of these
helper functions are taking the resource name as an argument and try to
find the asked values in the data structure and return it.

The main data structures are formed by functions and their values are
memorised and returned from the cache every time they are called again.
Sometimes, when the new values should be acquired from the system this
memoization can be dropped by calling the *cib_reset* function.
 
Every data structure get its values by parsing the CIB XML. This xml
is got by calling the *cibaqmin -Q* command. Then the *REXML* document
is created with this data and saved too. It can be accessed by the
*cib* function, or, you can even set the new XML text to using
the *cib=* function if you want the library to use the prepared XML
data instead of receiving the new one.

Data structures are formed by using CIB section filter functions like
*cib_section_primitives* which return the requested part of the CIB.
Then these objects are parsed into the data structures.

For a library user is most cases there is no need to work with
anything but main data structures and helper getters and predicates.

These are the main data structures:

- **primitives** The list of primitives and their configurations.
- **node_status** The current primitive status by node.
- **constraints** All types of constraints and their parameters.
- **constraint_colocations** Filtered colocation constraints.
- **constraint_locations** Filtered location constraints.
- **constraint_orders** Filtered order constraints.
- **nodes** Cluster nodes ands their ids.
- **operation_defaults** Defined operation defaults and their values.
- **resource_defaults** Defined resource defaults and their values.
- **cluster_properties** Defined cluster properties and their values.

PCS based versions of the data structures:

- **pcs_operation_defaults** Defined operation defaults and their values.
- **pcs_resource_defaults** Defined resource defaults and their values.
- **pcs_cluster_properties** Defined cluster properties and their values.

### Data matching

After the provider have retrieved the current system state one way or
another and it's getters are able to return the values the types
starts to check is these values are equal to the desired ones.

For every property the value will be retrieved by it's getter function
in the provider and the value will be compared to the value the type
got from the catalog using the *insync?* function. Usually there is
not need to change it's behaviour and this function can be left
unimplemented and taken from the parent implementation, but in some
cases this comparison should use a special function to check
if the data structures are equal if the conversion or filtering
is required and a the custom *insync?* should somehow determine is
*is* is equal to *should* or not. Function *is_to_s* and *should_to_s*
will be used to format the property change message in the puppet log.

### Data syncing

If the retrieved data for the property was different from the desired
one or if the resource doesn't exist at all the type will try to sync
the values.

If the resource was found not to exist the *create* method will be 
called. It should create the new resource with all parameters or fill
the property hash with them. If the resource should be removed the
*destroy* function will be called. If should either actually destroy
the resource or clear the property hash and set ensure to absent.

If the resource exists and should not be removed but has incorrect
parameter values the setters will be used to set properties to the
desired values. Each setter can either set the value directly or
modify the property hash.

Finally, the *flush* function will be called if it's defined. This
function should use the values from the property hash to actually
change the system state by creating, removing or updating the resource.
If getters and setters are not using the property hash and are making
changes directly there is not need for the *flush* function.

#### Complex providers

Complex providers are using the property hash to set the values and
the flush function to modify the pacemaker configuration.
When the *property_hash* is formed by using the *create* function or
setter function the *flush* method should convert the values from the
property hash to the library friendly data structure. Then the XML
generator function can be called to convert this structure to the 
XML patch that can be applied to the CIB, and the the *cibadmin --patch*
command will be called to apply it. If the resource should be removed
the small XML patch can be applied by the remove function directly.

All command calls that are changing the system should be run as their
safe versions. They will not be executed if the debug parameter is 
enabled and will be just shown in the log.

#### Simple providers

Simple providers are not using the *flush* function and setters are
modifying the system directly. XML generator are not used too and
the values are set using the *crm_attribute* command calls.
Service provider can also use *crm_attribute* to change the service
status.

PCS versions of these providers are using the *pcs* command calls for
the same purpose. PCS providers should be using their own main
data structures and are designed to be as simple as possible.

### Special providers

The providers of *service* and *pacemaker_nodes* types are working very
differently from other.

Service provider is not ensurable and cannot create services but can
control their status. It will use the library to get the status of the
service's primitive, try to start or stop it, and then will wait
for this action to succeed. It is also capable of adding the service
location constraints using the special library function and stopping
and disabling the basic service using another provider instance. 

Pcmk_nodes provider uses the *nodes* structure but work mostly
with corosync nodes using the *corosync-cmapctl* of the Corosync2
installation. It will match the exiting nodes to the desired node list
and will remove all extra corosync nodes and add the missing ones.
It can also remove the extra Pacemaker nodes but adding new nodes is
not required because Pacemaker will handle it on its own and therefore
should be disabled.

## Custom configuration

Some aspects of the providers behaviour can be controlled by the
*options.yaml*. This file can be found at *lib/pacemaker/options.yaml*
and contains all set options and their descriptions.

## Testing and debugging

### Specs

Most of the code base in the library has Ruby specs as well as Puppet
types and providers.

- *unit/puppet* Contains the specs for Puppet types and providers
  as well as the spec for the whole Pacemaker library and the fixture
  XML file. Most of the library, type and provider function are
  tested here.

- *unit/serverspec* Contains the specs for the ServerSpec types. They
  are used to check that these types are working correctly as well
  as indirectly checking the library too. 

- *classes* and *defined* have rspec-puppet tests for
  the classes and definitions.

- *acceptance* These tests are using the ServerSpec types to check
  that the module is actually configuring the cluster correctly on the
  virtual system. First, the corosync and pacemaker is being installed
  on the newly created system, then the test manifests in the *examples*
  folder are applied to check if the resources can be successfully
  created, updated and removed. Every time the specs look into the 
  pacemaker configuration to ensure that the resources are present
  and have the correct properties.
  
### ServerSpec types

- Pcmk_resource
- Pcmk_location
- Pcmk_colocation
- Pcmk_order
- Pcmk_property
- Pcmk_resource_default
- Pcmk_operation_default

You can find the description of the properties in the actual type files
and examples in the *spec/serverspec* and *spec/acceptance*.

### Manual testing

The library provides debug checkpoints for a lot of function calls and
their output can be seen in the Puppet debug log.
 
Service provider uses the *cluster_debug_report* function to output
the formatted report of the current cluster state.

    Pacemaker debug block start at 'test'
    -> Clone primitive: 'p_neutron-plugin-openvswitch-agent-clone'
       node-1: START (L) | node-2: STOP | node-3: STOP
    -> Simple primitive: 'p_ceilometer-alarm-evaluator'
       node-1: STOP | node-2: STOP (F) | node-3: STOP (F)
    -> Simple primitive: 'p_heat-engine'
       node-1: START (L) | node-2: STOP | node-3: STOP
    -> Simple primitive: 'p_ceilometer-agent-central'
       node-1: STOP | node-2: STOP (F) | node-3: STOP (F)
    -> Simple primitive: 'vip__management'
       node-1: START (L) | node-2: STOP (L) | node-3: STOP (L)
    -> Clone primitive: 'ping_vip__public-clone'
       node-1: START (L) | node-2: START (L) | node-3: START (L)
    -> Clone primitive: 'p_neutron-l3-agent-clone'
       node-1: START (L) | node-2: STOP | node-3: STOP
    -> Clone primitive: 'p_neutron-metadata-agent-clone'
       node-1: START (L) | node-2: STOP | node-3: STOP
    -> Clone primitive: 'p_mysql-clone'
       node-1: START (L) | node-2: START (L) | node-3: STOP
    -> Simple primitive: 'p_neutron-dhcp-agent'
       node-1: START (L) | node-2: STOP | node-3: STOP
    -> Simple primitive: 'vip__public'
       node-1: START (L) | node-2: STOP (L) | node-3: STOP (L)
    -> Clone primitive: 'p_haproxy-clone'
       node-1: START (L) | node-2: START (L) | node-3: STOP
    -> Master primitive: 'p_rabbitmq-server-master'
       node-1: MASTER (L) | node-2: START (L) | node-3: STOP
    * symmetric-cluster: false
    * no-quorum-policy: ignore
    Pacemaker debug block end at 'test'

- (L) The location constraint for this resource is created in this node
- (F) This resource have failed on this node
- (M) This resource is not managed

Inserting this function into other providers can be helpful if you need
to se the status of all surrounding resources.

Using the **debug** property of most resources can help you to debug
the providers without damaging the system configuration.

## Links

- [Pacemaker Explained](http://clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Pacemaker_Explained/)
- [Pacemaker Cluster from Scratch](http://clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Clusters_from_Scratch/)
- [Puppet Types and Providers](https://docs.puppetlabs.com/guides/complete_resource_example.html)
- [RSpec Puppet Test](http://rspec-puppet.com/)
- [ServerSpec Tests](http://serverspec.org/)
- [RSpec-Beaker Acceptance Tests](https://github.com/puppetlabs/beaker-rspec)

