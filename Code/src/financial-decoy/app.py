"""
Financial Decoy Honeypot
========================
A high-interaction web honeypot simulating a banking portal.
All interactions are logged for threat intelligence analysis.

Author: Mojiz
Part of: Cloud-Native Deception Architecture
"""

from flask import Flask, request, render_template, redirect, url_for
import logging
from datetime import datetime

app = Flask(__name__)

# Log directly to the file monitored by Filebeat
LOG_FILE = "/var/log/financial-decoy.log"

logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s %(message)s"
)

def log_event(event_type, details):
    """
    Log security events in a structured format.
    Format matches Kibana grok patterns for parsing.
    """
    client_ip = request.remote_addr
    user_agent = request.headers.get('User-Agent', 'Unknown')
    logging.info(f"{client_ip} | {event_type} | {details} | UA: {user_agent}")

@app.route("/", methods=["GET"])
def index():
    """Serve the fake banking login page."""
    log_event("VISIT", "Homepage Access")
    return render_template("index.html")

@app.route("/login", methods=["POST"])
def login():
    """
    Capture login attempts for threat intel.
    All credentials are logged for password analysis.
    """
    username = request.form.get("username", "")
    password = request.form.get("password", "")
    
    # Detect potential injection attempts
    injection_patterns = ["'", '"', "--", ";", "OR", "AND", "DROP", "SELECT"]
    is_injection = any(pattern.lower() in (username + password).lower() 
                       for pattern in injection_patterns)
    
    event_type = "SQL_INJECTION_ATTEMPT" if is_injection else "LOGIN_ATTEMPT"
    log_event(event_type, f"username={username} password={password}")
    
    return redirect(url_for("dashboard"))

@app.route("/dashboard", methods=["GET"])
def dashboard():
    """Simulated authenticated dashboard."""
    log_event("DASHBOARD_ACCESS", "Successful Auth Simulation")
    return """
    <html>
    <head><title>Account Dashboard</title></head>
    <body>
        <h2>Account Overview</h2>
        <p><strong>Account Holder:</strong> John Smith</p>
        <p><strong>Account Number:</strong> ****4582</p>
        <p><strong>Available Balance:</strong> $24,870.12</p>
        <hr>
        <h3>Recent Transactions</h3>
        <ul>
            <li>01/05 - Direct Deposit: +$3,200.00</li>
            <li>01/03 - Amazon.com: -$89.99</li>
            <li>01/02 - Transfer to Savings: -$500.00</li>
        </ul>
        <br>
        <a href="/api/transfer?amount=100&to=1234567890">Quick Transfer</a>
    </body>
    </html>
    """

@app.route("/api/transfer", methods=["GET", "POST"])
def transfer():
    """
    Fake API endpoint to capture manipulation attempts.
    Attackers often try negative amounts, excessive values, etc.
    """
    amount = request.args.get("amount") or request.form.get("amount", "0")
    to_account = request.args.get("to") or request.form.get("to", "unknown")
    
    # Log the attempt with all details
    log_event("TRANSFER_ATTEMPT", f"amount={amount} to={to_account}")
    
    return {
        "status": "success",
        "message": "Transfer initiated",
        "transaction_id": "TX-" + datetime.utcnow().strftime("%Y%m%d%H%M%S"),
        "amount": amount,
        "recipient": to_account
    }

@app.route("/api/balance", methods=["GET"])
def balance():
    """Another API endpoint for reconnaissance detection."""
    log_event("API_PROBE", "Balance endpoint accessed")
    return {
        "account": "****4582",
        "available": 24870.12,
        "pending": 0.00,
        "currency": "USD"
    }

@app.route("/admin", methods=["GET"])
def admin():
    """Fake admin page - high-value target for attackers."""
    log_event("ADMIN_PROBE", "Admin page access attempt")
    return """
    <html>
    <head><title>Admin Portal</title></head>
    <body>
        <h2>Administration Panel</h2>
        <p>Access Denied: Invalid credentials</p>
        <p>This incident has been logged.</p>
    </body>
    </html>
    """, 403

@app.errorhandler(404)
def not_found(e):
    """Log path traversal and scanning attempts."""
    log_event("404_PROBE", f"Path: {request.path}")
    return "Not Found", 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8085, debug=False)
