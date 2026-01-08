# Network Security Group (NSG) Rules

> **Critical Security Documentation**  
> These rules define the network isolation between the Deception Plane and Production Systems.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      AZURE VNET                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────────────┐    ┌─────────────────────┐       │
│   │  HONEYPOT SUBNET    │    │  MANAGEMENT SUBNET  │       │
│   │  10.0.1.0/24        │    │  10.0.2.0/24        │       │
│   │                     │    │                     │       │
│   │  NSG: hp-nsg        │    │  NSG: mgmt-nsg      │       │
│   │  Access: OPEN       │    │  Access: RESTRICTED │       │
│   └─────────────────────┘    └─────────────────────┘       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 1. Honeypot VM NSG (`hp-nsg`)

**Purpose:** Allow all traffic to reach the honeypot for capture and analysis.

| Priority | Name | Port | Protocol | Source | Action | Description |
|----------|------|------|----------|--------|--------|-------------|
| 100 | SSH_Management | 64295 | TCP | Any | **Allow** | Custom SSH port for secure management |
| 110 | TPot_WebUI | 64297 | TCP | Any | **Allow** | T-Pot Kibana/Web Dashboard |
| 120 | Honeypot_AllPorts | 0-64000 | Any | Any | **Allow** | ⚠️ **Open to Internet for capture** |
| 130 | Financial_Decoy | 8085 | TCP | Any | **Allow** | Custom Python Decoy Application |

### Important Notes:

- **Ports 0-64000 are intentionally open** to attract attackers
- Management ports (64295, 64297) use high port numbers to avoid honeypot interference
- All traffic on these ports is logged and analyzed

---

## 2. Management VM NSG (`mgmt-nsg`)

**Purpose:** Strict lockdown - only admin IP can access.

| Priority | Name | Port | Protocol | Source | Action | Description |
|----------|------|------|----------|--------|--------|-------------|
| 100 | SSH_AdminOnly | 22 | TCP | Admin IP | **Allow** | SSH restricted to admin IP only |
| 4096 | DenyAllInbound | Any | Any | Any | **Deny** | Block all other inbound traffic |

### Important Notes:

- Replace "Admin IP" with your actual public IP address
- Update this rule if your IP changes
- **No public services should run on this VM**

---

## 3. Inter-Subnet Rules

| Direction | Source | Destination | Action | Reason |
|-----------|--------|-------------|--------|--------|
| Inbound | Honeypot Subnet | Management Subnet | **Deny** | Prevent lateral movement |
| Outbound | Management Subnet | Honeypot Subnet | **Allow** | Enable admin access |
| Outbound | Honeypot Subnet | Internet | **Allow** | Log shipping to SIEM |

---

## 4. Rule Logic: "Legitimacy is Knowledge"

```
┌──────────────────────────────────────────────────────────┐
│                    TRAFFIC FLOW                          │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  LEGITIMATE USER                                         │
│  ┌─────────┐                                             │
│  │ Browser │ ──► DNS Lookup ──► Production Server  ✅    │
│  └─────────┘     (bookmarked)   (Never hits decoy)       │
│                                                          │
│  ─────────────────────────────────────────────────────   │
│                                                          │
│  ATTACKER                                                │
│  ┌─────────┐                                             │
│  │ Scanner │ ──► IP Range ──► Discovers Decoy ──► 🚨    │
│  └─────────┘     Scan          ALERT TRIGGERED           │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Conclusion:** Any interaction with the honeypot is **unauthorized by definition** because:
1. The decoy IPs are not in DNS
2. Legitimate users use bookmarks/known URLs
3. Only scanners and attackers discover hidden IPs

---

## 5. Azure CLI Commands

### Create Honeypot NSG Rule (Example)
```bash
az network nsg rule create \
    --resource-group HP-NETWORKSECURITY \
    --nsg-name hp-nsg \
    --name Honeypot_AllPorts \
    --priority 120 \
    --access Allow \
    --protocol '*' \
    --direction Inbound \
    --source-address-prefixes '*' \
    --destination-port-ranges 0-64000
```

### Create Management NSG Rule (Example)
```bash
az network nsg rule create \
    --resource-group HP-NETWORKSECURITY \
    --nsg-name mgmt-nsg \
    --name SSH_AdminOnly \
    --priority 100 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --source-address-prefixes "YOUR_ADMIN_IP" \
    --destination-port-ranges 22
```

---

## 6. Security Considerations

| Consideration | Implementation |
|---------------|----------------|
| **Isolation** | No route from honeypot to production |
| **Logging** | All traffic logged via T-Pot/ELK |
| **Alerting** | Any interaction triggers alert |
| **Forensics** | WORM storage for immutable logs |
