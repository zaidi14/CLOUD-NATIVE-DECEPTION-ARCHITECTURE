# Cloud-Native Deception Architecture for Financial Systems

> **"The Perimeter is Dead. Long live the Decoy."**

[![Azure](https://img.shields.io/badge/Cloud-Microsoft%20Azure-0089D6?logo=microsoft-azure)](https://azure.microsoft.com)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?logo=python&logoColor=white)](https://python.org)
[![T-Pot](https://img.shields.io/badge/Honeypot-T--Pot-red)](https://github.com/telekom-security/tpotce)
[![ELK](https://img.shields.io/badge/Observability-Elastic%20Stack-005571?logo=elastic)](https://elastic.co)

---

## 📖 Project Overview

Most cloud security failures today don't start with malware—they start with **valid credentials**. Traditional perimeter defenses are designed to block; this project is designed to **attract, engage, and expose**.

This project implements a **Cloud-Native Deception Architecture** that deploys realistic financial system decoys to detect unauthorized access with **zero false positives**. Unlike signature-based detection, any interaction with these hidden systems is **proof of malicious intent**.

### Key Innovation
```
Traditional Security: "Block everything suspicious"  →  High false positives
Deception Security:   "Attract and analyze intent"  →  Zero false positives
```

---

## 🏗 Architecture & Strategy

This system operates on the **"Legitimacy is Knowledge"** principle to eliminate false positives:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        AZURE VIRTUAL NETWORK                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────────────────┐        ┌─────────────────────┐               │
│   │   DECEPTION PLANE   │        │  OBSERVABILITY PLANE │              │
│   │   (The Trap)        │        │  (The Eyes)          │              │
│   │                     │        │                      │              │
│   │  ┌───────────────┐  │        │  ┌────────────────┐  │              │
│   │  │  T-Pot VM     │──┼────────┼─▶│ Elasticsearch  │  │              │
│   │  │  (Multi-HP)   │  │        │  │ + Kibana       │  │              │
│   │  └───────────────┘  │        │  └────────────────┘  │              │
│   │                     │        │          ▲           │              │
│   │  ┌───────────────┐  │        │          │           │              │
│   │  │  Financial    │──┼────────┼──────────┘           │              │
│   │  │  Decoy (Flask)│  │   Filebeat                    │              │
│   │  └───────────────┘  │        │                      │              │
│   │                     │        │  ┌────────────────┐  │              │
│   │  ┌───────────────┐  │        │  │  WORM Storage  │  │              │
│   │  │  Honeytokens  │  │        │  │  (Forensics)   │  │              │
│   │  │  (AWS Keys)   │  │        │  └────────────────┘  │              │
│   │  └───────────────┘  │        │                      │              │
│   └─────────────────────┘        └──────────────────────┘              │
│                                                                         │
│   ════════════════════════════════════════════════════════════════════ │
│                          ⛔ NO ROUTE EXISTS ⛔                          │
│   ════════════════════════════════════════════════════════════════════ │
│                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │                      PRODUCTION PLANE                            │  │
│   │                   (Completely Isolated)                          │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Three-Plane Design

| Plane | Purpose | Components |
|-------|---------|------------|
| **Production Plane** | Completely isolated; no route exists from decoys | Real systems (out of scope) |
| **Deception Plane** | Attract and engage attackers | T-Pot Honeypot, Financial Decoy, Honeytokens |
| **Observability Plane** | Collect and analyze telemetry | Elastic Stack (ELK), WORM Storage |

---

## 📊 Impact & Results

### 14-Day Live Fire Simulation on Azure Public IP Space

| Metric | Generic Honeypot | Financial Decoy | Impact |
|--------|------------------|-----------------|--------|
| **Dwell Time** | 18 seconds | **131 seconds** | **~7x Increase** |
| **False Positives** | Low | **0%** | Zero Noise |
| **Interaction Type** | Automated Scanning | Human/Manual | High-Value Intel |

### Why Zero False Positives?

The decoy IPs were **never published in DNS**. Therefore:

```
Employee Path:  Bookmark → DNS → Production Server  ✅ Never touches decoy
Attacker Path:  IP Scan → Random Discovery → Decoy  🚨 ALERT: Proof of Malice
```

**"Legitimacy is Knowledge"** — Anyone who finds the decoy was actively searching for vulnerabilities.

---

## 🔧 Technology Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **Cloud** | Microsoft Azure | VNet Segmentation, NSGs, VM Deployment |
| **Application** | Python, Flask, Gunicorn | Custom Financial Decoy |
| **Honeypot** | T-Pot (Deutsche Telekom) | Multi-honeypot platform (SSH, Telnet, HTTP) |
| **Telemetry** | Filebeat → Elasticsearch → Kibana | Log shipping, indexing, visualization |
| **Forensics** | WORM Storage | Immutable log retention |

---

## 📁 Repository Structure

```
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
│   │   ├── azure-cli/                  # Infrastructure as Code
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

- Azure CLI installed and authenticated
- Ubuntu 20.04+ VM (minimum 8GB RAM for T-Pot)
- Python 3.8+

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

A high-interaction web honeypot simulating a banking portal:

- **Login Page** — Captures credential stuffing attempts
- **Dashboard** — Simulates authenticated access
- **API Endpoint** — Detects parameter manipulation attacks

```python
@app.route("/api/transfer", methods=["GET", "POST"])
def transfer():
    # Capture API manipulation attempts
    log_event("TRANSFER_ATTEMPT", f"amount={amount} to={to}")
```

### Network Isolation (NSG Rules)

| VM Type | Open Ports | Access |
|---------|------------|--------|
| Honeypot | 0-64000 (all) | **Internet** (intentional) |
| Management | 22 only | **Admin IP only** |

### Kibana Runtime Fields

Custom Painless scripts extract structured data from raw logs:

- `attacker_ip` — Extracts source IP from log messages
- `http_method` — Identifies GET/POST request types
- `credential_pair` — Parses attempted username/password combinations

---

## 📈 Observed Attack Patterns

During the 14-day simulation, the following behaviors were captured:

| Attack Type | Frequency | Example |
|-------------|-----------|---------|
| **Credential Stuffing** | High | `admin/admin`, `root/password` |
| **API Manipulation** | Medium | Negative transfer amounts |
| **Path Traversal** | Low | `/../../../etc/passwd` |
| **SQL Injection** | Medium | `' OR '1'='1` in login fields |

---

## 🛡 Defense Philosophy

### The "Perimeter Paradox"

Traditional security requires **100% success** from defenders (one miss = breach).

Deception security **flips the asymmetry**:

```
Attacker must be 100% correct  →  One interaction with decoy = Exposed
Defender needs ONE detection   →  Game over for attacker
```

### Why This Works for Financial Systems

1. **High-value target simulation** increases attacker engagement
2. **API endpoints** attract sophisticated manual attacks (not just bots)
3. **Zero legitimate traffic** means every alert is actionable

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [Threat Model](Documentation/threat-model.md) | Architecture decisions and defense logic |
| [Attack Telemetry](Documentation/attack-telemetry.md) | Detailed metrics and observed behaviors |
| [NSG Rules](Code/infrastructure/network-security/nsg-rules.md) | Network isolation configuration |
| [Runtime Fields](Code/observability/kibana/runtime-fields.md) | Kibana Painless scripts |

---

## 🤝 Contributing

This project was developed as a capstone demonstration of cloud-native deception techniques. Contributions welcome:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Mojiz** 

---

> *"The best trap is one that looks too valuable to ignore."*
