# Database Capacity Planning and Growth Modeling

> **Category:** Database Performance  
> **Target Audience:** Systems Architects, Database Administrators, Engineering Leads

---

## 1. What is Database Capacity Planning?
Database capacity planning is the proactive discipline of estimating future storage, memory, CPU, disk IOPS, and network throughput demands to ensure the database tier maintains performance SLAs without incurring unnecessary cloud infrastructure costs or suffering sudden outages.

---

## 2. Quantitative Sizing Models

### 2.1 Storage Growth Estimation Formula
$$\text{Annual Storage} = (\text{Daily Row Ingestion} \times \text{Avg Row Bytes}) \times 365 \times \text{Index Multiplier} \times \text{Safety Buffer}$$

- **Example Calculation:**
  - Ingestion: 5,000,000 orders/day.
  - Average row size (including TOAST): 600 bytes.
  - Daily raw data: $5{,}000{,}000 \times 600 \text{ bytes} = 3.0 \text{ GB/day}$.
  - Index Multiplier: 1.6 (indexes typically consume 40%–80% of raw table size).
  - Safety Buffer: 1.3 (accounting for WAL archiving, autovacuum work space, and bloat).
  - Annual Storage Required:
    $$3.0 \text{ GB} \times 365 \times 1.6 \times 1.3 \approx 2{,}277 \text{ GB} \approx 2.3 \text{ TB/year}$$

---

### 2.2 RAM & Buffer Pool Sizing (The Working Set Rule)
$$\text{Target RAM} \ge \text{Size of Active Working Set (Hot Data)} + \text{Total Indexes on Active Tables}$$
- In healthy OLTP systems, **99%+ of reads must be satisfied from RAM (Buffer Cache)** without hitting disk.
- If total table size is 5 TB, but 90% of queries target data created within the last 30 days (500 GB) and active indexes total 80 GB, a database instance with **768 GB of RAM** will deliver sub-millisecond p99 latency without needing to store all 5 TB in memory.

---

### 2.3 Disk IOPS Estimation
- **Baseline Write IOPS:**
  $$\text{Write IOPS} = (\text{Writes/sec} \times \text{Index Count}) + \text{WAL IOPS}$$
- **Read IOPS:** Depends directly on cache hit ratio. A drop from 99.5% cache hit ratio to 97% cache hit ratio represents a **600% increase in physical disk read IOPS!**

---

## 3. Capacity Alarm Triggers
| Metric | Warning Threshold | Critical Alert Threshold | Action Required |
| :--- | :---: | :---: | :--- |
| **Disk Storage Used** | 70% | 85% | Expand cloud storage volume; detach historical partitions. |
| **CPU Utilization (Sustained)** | 65% | 85% | Scale vertically; tune queries; offload reads to standbys. |
| **Buffer Cache Hit Ratio** | < 99.0% | < 97.0% | Increase memory (`shared_buffers`); eliminate table scans. |
| **Transaction ID Age (Postgres)** | 500,000,000 | 1,000,000,000 | Aggressive vacuum to avoid transaction ID wraparound shutdown. |

---

## 4. Authoritative References
- [AWS Storage Capacity Planning Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)
- [PostgreSQL Resource Consumption Settings](https://www.postgresql.org/docs/current/runtime-config-resource.html)
