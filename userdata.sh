#!/bin/bash
# Update package repositories and install Apache
apt update
apt install -y apache2

# Get the IMDSv2 token (Required by modern AWS AMIs)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)

# Use the token to fetch the Instance ID
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)

# Fallback if the fetch fails
if [ -z "$INSTANCE_ID" ]; then
  INSTANCE_ID="ID unavailable"
fi

# Create an HTML file with your portfolio details and social links
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Laxman Godi Portfolio</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
    @keyframes colorChange {
      0% { color: red; }
      50% { color: green; }
      100% { color: blue; }
    }
    h1 { animation: colorChange 2s infinite; }
    .links a { margin: 0 15px; text-decoration: none; color: #007bff; font-weight: bold; }
  </style>
</head>
<body>
  <h1>Laxman Godi Portfolio</h1>
  <h2>Instance ID: <span style="color:green">$INSTANCE_ID</span></h2>
  <p>Cloud Engineer & DevOps Enthusiast</p>
  
  <div class="links">
    <a href="https://github.com/LaxmanGodi" target="_blank">GitHub</a>
    <a href="https://www.linkedin.com/in/laxman-godi-6a9631270/" target="_blank">LinkedIn</a>
    <a href="https://www.naukri.com/mnjuser/profile?id=&altresid" target="_blank">Naukri</a>
  </div>
</body>
</html>
EOF

# Start Apache and enable it to run on system boot
systemctl start apache2
systemctl enable apache2
