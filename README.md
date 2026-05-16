# Cloud-Native Deception Architecture for Financial Systems

---

## 📖 Project Overview

This repository implements a cloud-native deception architecture that deploys high-interaction financial system decoys. The primary objective is to detect unauthorized access, scanning, and credential-based attacks by routing threat actors into strictly monitored, isolated environments. Because these decoy systems are unpublished and segregated from legitimate traffic, any interaction yields high-fidelity telemetry, minimizing false-positive alerts.

---

## 🏗 Architecture & Infrastructure

The environment relies on strict network segmentation, isolating the deception plane entirely from any production workloads.

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                        AZURE VIRTUAL NETWORK                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────────────────┐        ┌─────────────────────┐                │
│   │   DECEPTION PLANE   │        │  OBSERVABILITY PLANE│                │
│   │                     │        │                     │                │
│   │  ┌───────────────┐  │        │  ┌────────────────┐ │                │
│   │  │  T-Pot VM     │──┼────────┼─▶│ Elasticsearch  │ │                │
│   │  │  (Multi-HP)   │  │        │  │ + Kibana       │ │                │
│   │  └───────────────┘  │        │  └────────────────┘ │                │
│   │                     │        │          ▲          │                │
│   │  ┌───────────────┐  │        │          │          │                │
│   │  │  Financial    │──┼────────┼──────────┘          │                │
│   │  │  Decoy (Flask)│  │  Filebeat                    │                │
│   │  └───────────────┘  │        │                     │                │
│   │                     │        │  ┌────────────────┐ │                │
│   │  ┌───────────────┐  │        │  │  WORM Storage  │ │                │
│   │  │  Honeytokens  │  │        │  │  (Forensics)   │ │                │
│   │  │  (AWS Keys)   │  │        │  └────────────────┘ │                │
│   │  └───────────────┘  │        │                     │                │
│   └─────────────────────┘        └─────────────────────┘                │
│                                                                         │
│   ════════════════════════════════════════════════════════════════════  │
│                          ⛔ NO ROUTE EXISTS ⛔                          │
│   ════════════════════════════════════════════════════════════════════  │
│                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                      PRODUCTION PLANE                           │   │
│   │                   (Completely Isolated)                         │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

```

### Three-Plane Segmentation

| Plane | Purpose | Components |
| --- | --- | --- |
| **Production Plane** | Simulated real workloads (completely isolated) | Out of scope / No routing to deception environment |
| **Deception Plane** | Attract and log malicious interaction | T-Pot Honeypot, Flask Decoy, Honeytokens |
| **Observability Plane** | Telemetry ingestion, analysis, and retention | Elastic Stack (ELK), WORM Storage |

---


### Detection Efficacy

The decoy infrastructure intentionally omits DNS records and legitimate internal routing paths.

* **Legitimate Traffic:** Benign users navigate via standard DNS to production servers, never touching the decoy space.
* **Malicious Traffic:** Attackers operating via IP scanning or unauthorized discovery mechanisms engage with the decoy, providing immediate, actionable alerts.

---

## 🔧 Technology Stack

| Category | Technology | Purpose |
| --- | --- | --- |
| **Cloud** | Microsoft Azure | VNet Segmentation, NSGs, VM Deployment |
| **Application** | Python, Flask, Gunicorn | Custom high-interaction financial decoy |
| **Honeypot** | T-Pot (Deutsche Telekom) | Multi-honeypot platform (SSH, Telnet, HTTP) |
| **Telemetry** | Filebeat → Elasticsearch → Kibana | Log shipping, indexing, visualization |
| **Forensics** | WORM Storage | Immutable log retention |

---

## 📁 Repository Structure

```text
CLOUD-HONEYPOT/
├── README.md                           # This file
├── .gitignore
│
├── Code/
│   ├── src/
│   │   ├── financial-decoy/            # Custom Python honeypot
│   │   │   ├── app.py                  # Flask application
│   │   │   ├── requirements.txt        # Python dependencies
│   │   │   ├── templates/
│   │   │   │   └── index.html          # Banking portal UI
│   │   │   └── systemd/
│   │   │       └── financial-decoy.service
│   │   │
│   │   └── honeypot/
│   │       └── tpot-install.sh         # T-Pot installation script
│   │
│   ├── infrastructure/
│   │   ├── azure-cli/                  # Deployment scripts
│   │   │   ├── deploy-tpot-vm.sh       # Honeypot VM deployment
│   │   │   └── deploy-mgmt-vm.sh       # Management VM deployment
│   │   │
│   │   └── network-security/
│   │       └── nsg-rules.md            # NSG isolation rules
│   │
│   └── observability/
│       ├── filebeat/
│       │   └── financial-decoy-filebeat.yml
│       │
│       └── kibana/
│           └── runtime-fields.md       # Painless parsing scripts
│
└── Documentation/
    ├── threat-model.md                 # Architecture & defense logic
    └── attack-telemetry.md             # Results & observed behaviors

```

---

## 🚀 Deployment Guide

### Prerequisites

* Azure CLI installed and authenticated
* Ubuntu 20.04+ VM (minimum 8GB RAM for T-Pot)
* Python 3.8+

### Step 1: Deploy Infrastructure

```bash
# Deploy the honeypot VM
chmod +x Code/infrastructure/azure-cli/deploy-tpot-vm.sh
./Code/infrastructure/azure-cli/deploy-tpot-vm.sh

# Deploy the management VM (restricted access)
chmod +x Code/infrastructure/azure-cli/deploy-mgmt-vm.sh
./Code/infrastructure/azure-cli/deploy-mgmt-vm.sh

```

### Step 2: Install T-Pot Honeypot

```bash
# SSH into the honeypot VM
ssh -p 64295 mojiz@<HONEYPOT_PUBLIC_IP>

# Run the T-Pot installer
chmod +x tpot-install.sh
./tpot-install.sh

```

### Step 3: Deploy Financial Decoy

```bash
# Clone and setup
cd /home/hpmojiz
git clone <this-repo> financial-decoy
cd financial-decoy/Code/src/financial-decoy

# Create virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Enable systemd service
sudo cp systemd/financial-decoy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now financial-decoy

```

### Step 4: Configure Log Shipping

```bash
# Install Filebeat
sudo apt-get install filebeat

# Copy configuration
sudo cp observability/filebeat/financial-decoy-filebeat.yml /etc/filebeat/filebeat.yml

# Start Filebeat
sudo systemctl enable --now filebeat

```

---

## 🔍 Key Components Deep Dive

### Financial Decoy (Custom Flask Application)

A high-interaction web honeypot simulating a banking portal designed to capture actionable intel:

* **Login Page** — Captures credential stuffing attempts.
* **Dashboard** — Simulates authenticated access to increase dwell time.
* **API Endpoint** — Detects parameter manipulation and application-layer attacks.

```python
@app.route("/api/transfer", methods=["GET", "POST"])
def transfer():
    # Capture API manipulation attempts
    log_event("TRANSFER_ATTEMPT", f"amount={amount} to={to}")

```

### Network Isolation (NSG Rules)

| VM Type | Open Ports | Access |
| --- | --- | --- |
| Honeypot | 0-64000 (all) | **Internet** (purposely exposed) |
| Management | 22 only | **Admin IP only** |

### Kibana Runtime Fields

Custom Painless scripts are utilized to extract structured data from raw application logs:

* `attacker_ip` — Extracts source IP from log messages.
* `http_method` — Identifies GET/POST request types.
* `credential_pair` — Parses attempted username/password combinations.

---

## 📈 Observed Attack Patterns

During the initial 14-day data collection period, the following behaviors were logged and categorized:

| Attack Type | Frequency | Example Payload |
| --- | --- | --- |
| **Credential Stuffing** | High | `admin/admin`, `root/password` |
| **API Manipulation** | Medium | Negative transfer amounts |
| **Path Traversal** | Low | `/../../../etc/passwd` |
| **SQL Injection** | Medium | `' OR '1'='1` in login fields |

---

## 🛡 Architecture Rationale

The deployment of deception networks offers specific technical advantages over traditional perimeter alerting:

1. **Increased Dwell Time:** Simulating a high-value financial target increases attacker engagement, providing more extensive telemetry than generic honeypots.
2. **Application-Layer Visibility:** Custom API endpoints attract and log sophisticated manual attacks, bypassing the noise of simple network scanners.
3. **Alert Fidelity:** Because the architecture operates entirely outside of legitimate user workflows, any triggered alert can be classified as highly actionable.

---

## 📚 Documentation

| Document | Description |
| --- | --- |
| [Threat Model](https://www.google.com/search?q=Documentation/threat-model.md) | Architecture decisions, threat actors, and defense logic |
| [Attack Telemetry](https://www.google.com/search?q=Documentation/attack-telemetry.md) | Detailed metrics and observed behaviors from initial deployment |
| [NSG Rules](https://www.google.com/search?q=Code/infrastructure/network-security/nsg-rules.md) | Network isolation configuration |
| [Runtime Fields](https://www.google.com/search?q=Code/observability/kibana/runtime-fields.md) | Kibana Painless scripts for log parsing |

---

## 🤝 Contributing

Contributions to expand the deception framework or optimize log parsing are welcome:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE]() file for details.

---

## 👤 Author

**Mojiz**
