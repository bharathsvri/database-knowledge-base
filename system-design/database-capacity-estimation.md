# Database Capacity Estimation Framework

> **Category:** Database System Design  
> **Target Audience:** Solutions Architects, Engineering Candidates, Tech Leads

---

## 1. The Core Estimation Equation Cheat Sheet

### 1.1 QPS (Queries Per Second) & Write Throughput
$$\text{Seconds in a Day} \approx 86{,}400 \approx 100{,}000 \text{ (Interview Approximation)}$$
- If an application processes **10 Million transactions per day**:
  $$\text{Average QPS} = \frac{10{,}000{,}000}{86{,}400} \approx 115 \text{ writes/sec}$$
- Peak traffic is typically **2x to 5x** the daily average:
  $$\text{Peak Write QPS} \approx 115 \times 4 \approx 460 \text{ writes/sec}$$

---

### 1.2 Storage Growth Calculation
$$\text{Daily Storage} = \text{Daily Records} \times \text{Average Row Bytes} \times (1 + \text{Index Overhead (0.5)}) \times (1 + \text{Metadata/Bloat (0.3)})$$

- **Example Problem:** 50 Million photo upload records/day. Average row metadata = 400 bytes.
  - Raw Data = $50{,}000{,}000 \times 400 \text{ bytes} = 20 \text{ GB/day}$.
  - Index & Bloat Multiplier $\approx 1.8$.
  - Daily Ingestion = $20 \text{ GB} \times 1.8 \approx 36 \text{ GB/day}$.
  - **Annual Storage Required:**
    $$36 \text{ GB/day} \times 365 \approx 13.1 \text{ TB/year}$$

---

### 1.3 Memory (RAM) Buffer Pool Sizing: The 80/20 Rule
Pareto principle dictates that **80% of read traffic accesses 20% of the dataset** (the hot active working set).
- If total 1-year data volume is **13.1 TB**:
  $$\text{Hot Working Set} = 13.1 \text{ TB} \times 0.20 \approx 2.6 \text{ TB}$$
- If you retain 30 days of data on the hot database cluster:
  $$\text{30-Day Working Set} = 30 \times 36 \text{ GB} \times 0.20 \approx 216 \text{ GB of RAM}$$
- A database primary with **256 GB or 512 GB of RAM** will easily keep 100% of the active working set pinned in the buffer pool, maintaining a > 99% cache hit ratio.

---

## 2. Bandwidth / Network Throughput
$$\text{Network Outbound} = \text{Read QPS} \times \text{Average Response Size}$$
- If Read QPS is 5,000 requests/sec, and average response JSON payload is 10 KB:
  $$\text{Bandwidth} = 5{,}000 \times 10 \text{ KB} = 50{,}000 \text{ KB/sec} = 50 \text{ MB/sec} = 400 \text{ Mbps}$$
- Requires at least 1 Gbps to 10 Gbps dedicated cloud network interfaces (AWS ENA).

---

## 3. Authoritative References
- [System Design Primer (Donna)](https://github.com/donnemartin/system-design-primer)
