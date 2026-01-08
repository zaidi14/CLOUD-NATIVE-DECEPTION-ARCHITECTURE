# Threat Model & Defense Strategy

> **"The Perimeter Paradox: Traditional defenses require 100% success; deception requires ONE detection."**

---

## 1. The Problem Statement

### Traditional Security Limitations

| Approach | Requirement | Reality |
|----------|-------------|---------|
| **Firewall** | Block all malicious traffic | Cannot identify valid credentials used maliciously |
| **IDS/IPS** | Detect known signatures | Zero-day attacks bypass signatures |
| **SIEM** | Alert on anomalies | High false positive rate drowns analysts |

**The Core Issue:** Most cloud breaches start with **valid credentials**, not malware. Traditional perimeter defenses are blind to:
- Credential stuffing with leaked passwords
- Insider threats with legitimate access
- Compromised service accounts

---

## 2. The Deception Solution

### Flipping the Asymmetry

```
TRADITIONAL DEFENSE                    DECEPTION DEFENSE
─────────────────────                  ─────────────────────
Defender must be                       Attacker must be
100% successful                        100% successful
                                       
One miss = Breach                      One interaction = Detection
Attacker advantage                     Defender advantage
```

### Logic Gate: "Legitimacy is Knowledge"

The fundamental insight:

| Actor | Path to System | Behavior |
|-------|----------------|----------|
| **Employee** | Bookmark → DNS → Production | Direct, purposeful |
| **Attacker** | IP Scan → Discovery → Probe | Exploratory, scanning |

**Conclusion:** Anyone who finds a hidden decoy was actively searching for vulnerabilities.

---

## 3. Architecture Decisions

### Three-Plane Isolation

```
┌─────────────────────────────────────────────────────────────┐
│                    CLOUD ENVIRONMENT                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐    │
│  │  PRODUCTION  │   │  DECEPTION   │   │ OBSERVABILITY│    │
│  │    PLANE     │   │    PLANE     │   │    PLANE     │    │
│  │              │   │              │   │              │    │
│  │ Real Assets  │   │  Decoys &    │   │  ELK Stack   │    │
│  │              │   │  Honeypots   │   │  WORM Logs   │    │
│  └──────────────┘   └──────────────┘   └──────────────┘    │
│         │                  │                  │             │
│         │    ═══════════════════════════     │             │
│         │       ⛔ NO ROUTE EXISTS ⛔        │             │
│         │    ═══════════════════════════     │             │
│         │                  │                  │             │
│         └──────────────────┼──────────────────┘             │
│                            │                                │
│                      Logs Only (One-Way)                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Key Design Principles

| Principle | Implementation | Rationale |
|-----------|----------------|-----------|
| **Isolation** | No route from decoy to production | Compromised decoy cannot pivot |
| **Realism** | Financial portal with API endpoints | Increases attacker dwell time |
| **Observability** | All interactions logged | Every touch is evidence |
| **Immutability** | WORM storage for logs | Forensic integrity |

---

## 4. Attack Surface Analysis

### What We Expose (Intentionally)

| Component | Exposed Port | Purpose |
|-----------|--------------|---------|
| T-Pot Honeypot | 0-64000 | Catch automated scans (SSH, Telnet, HTTP) |
| Financial Decoy | 8085 | Attract targeted financial attacks |
| Fake API | 8085/api/* | Detect API manipulation attempts |

### What We Protect

| Component | Protection | Method |
|-----------|------------|--------|
| Production Systems | Complete isolation | Separate VNet, no peering |
| Management Access | IP whitelist | NSG restricted to admin IP |
| Log Integrity | WORM storage | Write-once, tamper-evident |

---

## 5. Threat Scenarios

### Scenario 1: Opportunistic Bot

```
Attacker: Automated scanner
Target: Any SSH/Telnet service
Detection: T-Pot (Cowrie honeypot)
Response: Log & block IP range
Value: Botnet infrastructure intel
```

### Scenario 2: Targeted Financial Attack

```
Attacker: Manual operator with leaked credentials
Target: Banking portal
Detection: Financial Decoy (login attempt)
Response: Alert + full session capture
Value: Credential intelligence, TTPs
```

### Scenario 3: API Exploitation

```
Attacker: Skilled attacker testing for logic flaws
Target: /api/transfer endpoint
Detection: Financial Decoy (parameter manipulation)
Response: Capture full request, analyze intent
Value: Attack methodology documentation
```

---

## 6. Detection Logic

### Alert Triggers

| Trigger | Severity | Action |
|---------|----------|--------|
| Any interaction with decoy IP | **CRITICAL** | Immediate alert |
| SQL injection pattern detected | **HIGH** | Log + analyst review |
| Multiple login attempts (>5/min) | **MEDIUM** | Rate limit + log |
| API parameter fuzzing | **HIGH** | Full session capture |

### Why Zero False Positives?

1. **No DNS Entry:** Decoys are not discoverable through normal means
2. **No Bookmarks:** Employees have no reason to visit these IPs
3. **No Links:** No legitimate system references the decoy
4. **Proof of Scanning:** Only IP scanners find these systems

---

## 7. MITRE ATT&CK Mapping

| Technique | ID | Detection Method |
|-----------|-----|------------------|
| Active Scanning | T1595 | T-Pot port interaction |
| Valid Accounts | T1078 | Credential stuffing on Financial Decoy |
| Exploitation of Public-Facing App | T1190 | API manipulation attempts |
| Credential Stuffing | T1110.004 | Login attempt patterns |

---

## 8. Operational Considerations

### Maintenance Requirements

| Task | Frequency | Purpose |
|------|-----------|---------|
| Log review | Daily | Identify new attack patterns |
| IP reputation update | Weekly | Update blocklists |
| Decoy content refresh | Monthly | Maintain realism |
| System patching | Quarterly | Security hygiene |

### Incident Response Integration

```
DETECTION                    RESPONSE
─────────────────────        ─────────────────────
Decoy interaction    ──►     Alert to SOC
                     ──►     Automatic IP logging
                     ──►     Session capture
                     ──►     Threat intel enrichment
                     ──►     Block at perimeter (optional)
```

---

## 9. Limitations & Mitigations

| Limitation | Mitigation |
|------------|------------|
| Decoy must stay realistic | Regular content updates |
| Sophisticated attackers may detect | Layer multiple decoy types |
| Resource consumption | Right-size VM for expected load |
| Log storage growth | Implement retention policies |

---

## 10. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| False Positive Rate | 0% | Alerts without scanning evidence |
| Detection Coverage | 100% of decoy interactions | Logged events vs network flows |
| Mean Time to Alert | <5 minutes | Detection to SOC notification |
| Dwell Time Increase | >5x vs generic honeypot | Session duration comparison |
