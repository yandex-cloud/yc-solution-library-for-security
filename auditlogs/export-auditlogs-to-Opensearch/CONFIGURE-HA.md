# Recommendations for high data availability

In terms of high data availability, the following mechanisms are used:
- Multiple nodes for data.
- Multiple replicas for indexes.
- Indexes roll over according to the recommended schema:
    - When the index reaches 50GB, a new index is created;
    - A new index is created every thirty days.
- The data is sent to the alias linked to the active index, that is, the index rollover must not affect operability of the schema in the example.

## Index rollover

Index rollover uses the following Elasticsearch  entities:
- Indexes and index aliases.
- Index template.
- Index lifecycle policy.

The first index in the example is created with a numeric suffix. This is to ensure that a new index with a modified suffix is created as a result of rollover.

An alias is assigned to the created index, and this alias is then assigned to the new index at rollover.

## Index template

An index template contains all the necessary parameters to create a new index as a result of the rollover:
- Index pattern. Newly created indexes that meet the pattern are automatically created with the template parameters.
- Index settings. In our case, this is the name of the index rollover policy, the number of data replicas, and the `rollover_alias`, that is, the alias that will be moved to the new index.

```
{
  "index": {
    "lifecycle": {
      "name": "audit-trails-ilm",
      "rollover_alias": "audit-trails-index"
    },
    "number_of_replicas": "2"
  }
}
```
- Mapping parameters.

## Index lifecycle policy

The index lifecycle policy tracks the lifecycle of our data.
As the data becomes older, you can move it to lower-end servers or disks, and, finally, delete them, after a certain period.

In our example, we configured only the hot phase, with only default metrics for the rollover procedure enabled.

But for production deployment, we recommended to plan for the process of data obsolescence (that is, moving it to "slow" nodes), and deletion.

It is recommended to enable data deletion when you have no other phase but the hot one.

After a certain period, indexes with obsolete data will be deleted.
If you have set up data snapshots, you can enable the delete option only if a snapshot is present. In this case, specify the name of the snapshot policy.
