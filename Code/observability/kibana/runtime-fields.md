# Kibana Runtime Fields (Painless Scripting)

> **Purpose:** Parse raw log messages into structured, searchable fields in Kibana Discover.

---

## Overview

The Financial Decoy logs are stored as raw text in the `message` field. These Painless scripts extract structured data for analysis without re-indexing.

**Log Format:**
```
2024-01-15 10:23:45 192.168.1.100 | LOGIN_ATTEMPT | username=admin password=admin123 | UA: Mozilla/5.0
```

---

## Runtime Field Configurations

### 1. `attacker_ip`

**Purpose:** Extract the source IP address from log messages.

**Kibana Path:** Stack Management → Data Views → Select Index → Add Runtime Field

```painless
if (params._source.containsKey('message')) {
    def msg = params._source.message;
    if (msg != null) {
        def m = /(\d{1,3}(?:\.\d{1,3}){3})/.matcher(msg);
        if (m.find()) {
            emit(m.group(1));
        }
    }
}
```

**Field Type:** `keyword`

**Use Cases:**
- Group attacks by source IP
- GeoIP enrichment
- Threat intelligence correlation

---

### 2. `event_type`

**Purpose:** Extract the event type (LOGIN_ATTEMPT, TRANSFER_ATTEMPT, etc.)

```painless
if (params._source.containsKey('message')) {
    def msg = params._source.message;
    if (msg != null) {
        def m = /\|\s*([A-Z_]+)\s*\|/.matcher(msg);
        if (m.find()) {
            emit(m.group(1));
        }
    }
}
```

**Field Type:** `keyword`

**Use Cases:**
- Filter by attack type
- Build event type dashboards
- Alert on specific events (SQL_INJECTION_ATTEMPT)

---

### 3. `http_method`

**Purpose:** Extract HTTP method from web server logs.

```painless
if (params._source.containsKey('message')) {
    def msg = params._source.message;
    if (msg != null) {
        def m = /(GET|POST|PUT|DELETE|HEAD|OPTIONS|PATCH)\s+/.matcher(msg);
        if (m.find()) {
            emit(m.group(1));
        }
    }
}
```

**Field Type:** `keyword`

**Use Cases:**
- Identify API abuse (POST to /api/transfer)
- Detect scanning patterns (HEAD requests)

---

### 4. `attempted_username`

**Purpose:** Extract usernames from login attempts.

```painless
if (params._source.containsKey('message')) {
    def msg = params._source.message;
    if (msg != null) {
        def m = /username=([^\s]+)/.matcher(msg);
        if (m.find()) {
            emit(m.group(1));
        }
    }
}
```

**Field Type:** `keyword`

**Use Cases:**
- Identify credential stuffing patterns
- Track common username attempts (admin, root, test)

---

### 5. `attempted_password`

**Purpose:** Extract passwords for threat intelligence (password pattern analysis).

```painless
if (params._source.containsKey('message')) {
    def msg = params._source.message;
    if (msg != null) {
        def m = /password=([^\s|]+)/.matcher(msg);
        if (m.find()) {
            emit(m.group(1));
        }
    }
}
```

**Field Type:** `keyword`

**Use Cases:**
- Identify common password patterns
- Detect leaked credential usage
- Build password wordlists for defense

---

### 6. `user_agent`

**Purpose:** Extract User-Agent string for tool identification.

```painless
if (params._source.containsKey('message')) {
    def msg = params._source.message;
    if (msg != null) {
        def m = /UA:\s*(.+)$/.matcher(msg);
        if (m.find()) {
            emit(m.group(1));
        }
    }
}
```

**Field Type:** `keyword`

**Use Cases:**
- Identify automated tools (curl, python-requests, sqlmap)
- Detect spoofed user agents
- Track attacker toolkits

---

### 7. `transfer_amount`

**Purpose:** Extract transfer amounts from API manipulation attempts.

```painless
if (params._source.containsKey('message')) {
    def msg = params._source.message;
    if (msg != null) {
        def m = /amount=([^\s&]+)/.matcher(msg);
        if (m.find()) {
            emit(m.group(1));
        }
    }
}
```

**Field Type:** `keyword`

**Use Cases:**
- Detect negative amount attacks
- Identify large transfer attempts
- Track API parameter fuzzing

---

## Setup Instructions

### Step 1: Access Runtime Fields
1. Open Kibana → Stack Management
2. Navigate to Data Views (Index Patterns)
3. Select `financial-decoy-*` index

### Step 2: Add Runtime Field
1. Click "Add field"
2. Select "Runtime" as field type
3. Enter field name (e.g., `attacker_ip`)
4. Select output type (`keyword`)
5. Paste Painless script
6. Click "Save"

### Step 3: Verify in Discover
1. Open Kibana Discover
2. Select `financial-decoy-*` index
3. Add new runtime field to columns
4. Verify data extraction

---

## Sample Kibana Queries

### Find SQL Injection Attempts
```kql
event_type: "SQL_INJECTION_ATTEMPT"
```

### Find Login Attempts from Specific IP
```kql
attacker_ip: "192.168.1.100" AND event_type: "LOGIN_ATTEMPT"
```

### Find High-Value Transfer Attempts
```kql
event_type: "TRANSFER_ATTEMPT" AND transfer_amount: >10000
```

### Find Automated Tools
```kql
user_agent: (*curl* OR *python* OR *sqlmap*)
```

---

## Dashboard Recommendations

| Visualization | Fields Used | Purpose |
|---------------|-------------|---------|
| Pie Chart | `event_type` | Attack type distribution |
| Data Table | `attacker_ip`, `event_type`, count | Top attackers |
| Time Series | `@timestamp`, `event_type` | Attack trends |
| Tag Cloud | `attempted_username` | Common usernames |
| Map | `attacker_ip` (with GeoIP) | Attack origins |
