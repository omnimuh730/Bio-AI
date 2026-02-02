# **Bio AI: Financial Infrastructure Analysis**

### **Cost Estimation & Unit Economics Report**

**Date:** February 2026
**Region:** AWS `us-east-1` (N. Virginia)
**Currency:** USD
**Architecture Strategy:** Hybrid (Kubernetes for General Compute, Serverless/On-Demand for GPU)

---

## **1. Executive Summary**

This report breaks down the operational costs of running Bio AI. The cost structure is **bimodal**:

1.  **Fixed Costs (Base Infrastructure):** The cost to keep the lights on (Control planes, Databases, Networking).
2.  **Variable Costs (Unit Economics):** The marginal cost of every user action (taking a photo, syncing health data).

### **Top-Level Metrics**

- **Cost Per "Snap & Log" (Vision + AI):** **$0.0042** / request
- **Cost Per Active User (Monthly):** **$0.68** (at 3 scans/day + syncs)
- **Break-Even Point:** If charging **$12.99/mo** (Pro), margin is **~94%**.

---

## **2. Unit Economics (Cost Per Request)**

This is the micro-analysis of specific user actions. This determines the profitability of the application.

### **A. The "Dragunov" Vision Scan (Per Photo)**

_Workflow: Upload Image $\rightarrow$ GPU Inference (Seg/Depth/VLM) $\rightarrow$ Storage._

| Component             | Resource Detail                  | Cost Calculation           | Cost per Request |
| :-------------------- | :------------------------------- | :------------------------- | :--------------- |
| **Ingress Bandwidth** | AWS Data Transfer In             | Free                       | $0.0000          |
| **Storage (Raw)**     | S3 Standard (10MB, 24h TTL)      | ($0.023/GB ÷ 100) × 10MB   | $0.0002          |
| **GPU Compute**       | **Serverless GPU** (NVIDIA A10G) | 4s Execution @ $0.0008/sec | **$0.0032**      |
| **Storage (Gallery)** | S3 Standard (100KB WebP, Perm)   | Negligible per single req  | $0.00001         |
| **Database Write**    | MongoDB Atlas Write Unit         | 1 WCU                      | $0.00005         |
| **Egress (App)**      | JSON Result Return (5KB)         | Negligible                 | $0.0000          |
| **TOTAL**             |                                  |                            | **~$0.0033**     |

> **Reasoning:** We assume a **Serverless GPU** model (e.g., RunPod or AWS SageMaker Serverless Inference) rather than a 24/7 EC2 instance. This prevents paying for idle GPUs at 3 AM.

### **B. The Bio-Adaptive Advice (Per Meal)**

_Workflow: Context Assembly $\rightarrow$ LLM Token Generation $\rightarrow$ UI Return._

| Component         | Resource Detail                               | Cost Calculation   | Cost per Request |
| :---------------- | :-------------------------------------------- | :----------------- | :--------------- |
| **Vector Search** | MongoDB Atlas Vector Search (RU & index cost) | small RU per query | $0.00005         |
| **LLM Input**     | **GPT Nano** (1,500 Tokens)                   | low-cost small LLM | $0.00003         |
| **LLM Output**    | **GPT Nano** (500 Tokens)                     | low-cost small LLM | $0.00001         |
| **TOTAL**         |                                               |                    | **~$0.00062**    |

> **Reasoning:** We use small footprint LLMs (GPT Nano early-stage) for sentence generation; these are much cheaper than larger LLMs. Vector retrieval is handled by MongoDB Atlas Vector Search to keep operations within a single managed datastore.

---

## **3. Infrastructure Base Costs (Fixed Monthly)**

These costs exist whether you have 1 user or 10,000. They represent the "Minimum Viable Infrastructure."

### **A. Compute Cluster (EKS)**

The Control Plane and General purpose nodes for the API/BFF.

| Service                  | Spec                         | Unit Price     | Monthly Cost |
| :----------------------- | :--------------------------- | :------------- | :----------- |
| **EKS Control Plane**    | AWS Managed K8s              | $0.10/hr       | $73.00       |
| **Node Group (General)** | 2x `t3.medium` (API/Nexus)   | $0.0416/hr x 2 | $60.80       |
| **Node Group (Memory)**  | 1x `r5.large` (Worker/Redis) | $0.126/hr      | $91.98       |
| **Subtotal**             |                              |                | **$225.78**  |

### **B. Networking (The "Hidden" Cost)**

AWS charges significantly for networking components required for high availability.

| Service                       | Spec                         | Unit Price       | Monthly Cost  |
| :---------------------------- | :--------------------------- | :--------------- | :------------ |
| **Application Load Balancer** | 1 ALB (Public Ingress)       | $0.0225/hr + LCU | $16.42        |
| **NAT Gateway**               | 2 Gateways (HA across 2 AZs) | $0.045/hr x 2    | **$65.70**    |
| **Data Transfer**             | Intra-Region (Cross-AZ)      | $0.01/GB         | ~$10.00 (est) |
| **Subtotal**                  |                              |                  | **$92.12**    |

### **C. Managed Databases**

We avoid self-hosting stateful sets to ensure reliability.

| Service                 | Spec                      | Unit Price | Monthly Cost |
| :---------------------- | :------------------------ | :--------- | :----------- |
| **MongoDB Atlas**       | M10 Cluster (General)     | Managed    | $57.00       |
| **Elasticache (Redis)** | `cache.t3.micro` (Queues) | 2 Nodes    | $34.00       |
| **Subtotal**            |                           |            | **$91.00**   |

---

## **4. Scaled Cost Scenarios (Monthly)**

### **Scenario A: Startup Phase (1,000 Active Users)**

- **Traffic:** 3,000 Scans/day.
- **Storage:** Growing by 9GB/month.

| Category                                   | Cost        |
| :----------------------------------------- | :---------- |
| **Fixed Infrastructure**                   | $421.90     |
| **Vision Costs** (3k daily _ 30 _ $0.0033) | $297.00     |
| **LLM Costs** (3k daily _ 30 _ $0.00012)   | $10.80      |
| **Total Monthly Burn**                     | **$729.70** |
| **Cost Per User**                          | **$0.79**   |

### **Scenario B: Growth Phase (50,000 Active Users)**

- **Traffic:** 150,000 Scans/day.
- **Optimization:** We switch from On-Demand to **Spot Instances** and **Reserved Instances** (Savings Plans).

| Category                 | Calculation (Optimized)                      | Cost           |
| :----------------------- | :------------------------------------------- | :------------- |
| **Fixed Infrastructure** | Scaled 5x (Autoscaling) - 30% (Savings Plan) | $1,476.00      |
| **Vision Costs**         | Bulk GPU Pricing (Reserved Nodes)            | $12,500.00     |
| **LLM Costs**            | Fine-Tuned Llama 3 (Self-Hosted)             | $1,200.00      |
| **Total Monthly Burn**   |                                              | **$15,176.00** |
| **Cost Per User**        |                                              | **$0.30**      |

---

## **5. Cost Optimization Strategies (How to lower the bill)**

1.  **Spot Instances for Workers (`bio_worker`):**
    - **Reason:** Background tasks (health sync) are fault-tolerant. If AWS reclaims a Spot instance, the task just stays in Redis and is picked up by another node.
    - **Savings:** ~70% on Compute.

2.  **Intelligent Tiering for S3:**
    - **Reason:** User food logs from 6 months ago are rarely accessed.
    - **Action:** Move objects >30 days old to **S3 Glacier Instant Retrieval**.
    - **Savings:** ~60% on Storage.

3.  **Semantic Caching (Redis):**
    - **Reason:** Many users eat the same things (e.g., "Starbucks Egg Bites").
    - **Action:** Before calling the expensive GPU Vision pipeline, check if the image hash matches a known item.
    - **Impact:** Reduces GPU load by 10-15%.

4.  **Edge Computing (Future):**
    - **Action:** Move the "Segmentation" step (MobileSAM) to the User's iPhone (CoreML).
    - **Impact:** Removes 30% of the Cloud GPU workload, as we only need to calculate Depth/Volume on the server.

---

## **6. Conclusion**

The primary cost driver for Bio AI is **GPU Inference**, not Storage or LLMs.

- **Risk:** If users spam the camera without subscribing, costs mount quickly ($0.0035/click).
- **Mitigation:**
    1.  **Free Tier Limits:** Cap Free users at 3 scans/day.
    2.  **Circuit Breakers:** Stop processing if a user hits 50 scans/hour (abuse).

**Final Verdict:** The architecture is financially viable. With a $12.99 subscription, the break-even usage is massive (a user would need to scan ~3,000 meals a month to make us lose money).
