# From the Deep

In this problem, you'll write freeform responses to the questions provided in the specification.

## Random Partitioning

Random partitioning ensures that observations are spread evenly across all boats regardless of when they were collected, which prevents any single boat from becoming a bottleneck under uneven workloads. However, because each observation could land on any boat, a range-based query (such as "find all observations between midnight and 1am") must be executed on every boat to guarantee completeness, making such queries expensive and slow.

## Partitioning by Hour

Partitioning by hour makes range queries on time windows very efficient, since all observations within a given time range are guaranteed to reside on a single, predictable boat. However, because AquaByte most actively collects data between midnight and 1am, Boat A will receive a disproportionately large share of observations, creating a "hot" partition that could become overloaded while the other boats sit underutilized.

## Partitioning by Hash Value

Hash partitioning distributes observations evenly across all boats regardless of collection time, avoiding the hot-partition problem that arises with time-based partitioning, and it allows a point lookup on a specific timestamp to be routed to exactly one boat. The trade-off is that range queries (e.g., all observations between midnight and 1am) must be broadcast to every boat, because consecutive timestamps are scattered across arbitrary hash values with no preserved ordering.
