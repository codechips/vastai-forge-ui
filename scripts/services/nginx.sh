#!/usr/bin/env bash
# Nginx service with dynamic landing page

function start_nginx() {
    echo "nginx: starting web server"
    
    # Create nginx directories
    mkdir -p /opt/nginx/html
    mkdir -p /var/log/nginx
    
    # Get external IP and port mappings from Vast.ai environment
    EXTERNAL_IP="${PUBLIC_IPADDR:-localhost}"
    FORGE_PORT="${VAST_TCP_PORT_8010:-8010}"
    FILES_PORT="${VAST_TCP_PORT_7010:-7010}"
    TERMINAL_PORT="${VAST_TCP_PORT_7020:-7020}"
    LOGS_PORT="${VAST_TCP_PORT_7030:-7030}"
    
    echo "nginx: generating landing page for IP ${EXTERNAL_IP}"
    echo "nginx: ports - forge:${FORGE_PORT}, files:${FILES_PORT}, terminal:${TERMINAL_PORT}, logs:${LOGS_PORT}"
    
    # Generate the landing page HTML with embedded CSS
    cat > /opt/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VastAI Forge Services</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: linear-gradient(to bottom, #2a2a2a, #1a1a1a);
            color: #e0e0e0;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
        }
        
        .services {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            gap: 1.5rem;
            padding: 2rem;
        }
        
        .service-button {
            display: block;
            width: 280px;
            padding: 1.5rem 2rem;
            background: #fde120;
            border: none;
            border-radius: 8px;
            text-decoration: none;
            color: #1a1a1a;
            text-align: center;
            transition: all 0.3s ease;
            font-size: 1.1rem;
            font-weight: 500;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
        }
        
        .service-button:hover {
            background: #fce000;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.4);
            color: #000;
        }
        
        .service-button:active {
            transform: translateY(0);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
        }
        
        .footer {
            position: sticky;
            bottom: 0;
            padding: 1rem;
            text-align: center;
            background: transparent;
            font-size: 0.9rem;
            color: #888;
        }
        
        .footer a {
            color: #ccc;
            text-decoration: none;
            transition: color 0.3s ease;
        }
        
        .footer a:hover {
            color: #fff;
        }
        
        @media (max-width: 600px) {
            .services {
                padding: 1rem;
                gap: 1rem;
            }
            
            .service-button {
                width: 100%;
                max-width: 280px;
            }
        }
    </style>
</head>
<body>
    <div class="services">
        <a href="http://EXTERNAL_IP:FORGE_PORT" target="_blank" class="service-button">
            Forge WebUI
        </a>
        <a href="http://EXTERNAL_IP:FILES_PORT" target="_blank" class="service-button">
            File Browser
        </a>
        <a href="http://EXTERNAL_IP:TERMINAL_PORT" target="_blank" class="service-button">
            Web Terminal
        </a>
        <a href="http://EXTERNAL_IP:LOGS_PORT" target="_blank" class="service-button">
            Log Viewer
        </a>
    </div>
    <div class="footer">
        Another joint by <a href="http://codechips.me" target="_blank">@codechips</a>
    </div>
</body>
</html>
EOF

    # Replace placeholders with actual values
    sed -i "s/EXTERNAL_IP:FORGE_PORT/${EXTERNAL_IP}:${FORGE_PORT}/g" /opt/nginx/html/index.html
    sed -i "s/EXTERNAL_IP:FILES_PORT/${EXTERNAL_IP}:${FILES_PORT}/g" /opt/nginx/html/index.html
    sed -i "s/EXTERNAL_IP:TERMINAL_PORT/${EXTERNAL_IP}:${TERMINAL_PORT}/g" /opt/nginx/html/index.html
    sed -i "s/EXTERNAL_IP:LOGS_PORT/${EXTERNAL_IP}:${LOGS_PORT}/g" /opt/nginx/html/index.html
    
    # Create simple nginx configuration
    cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /opt/nginx/html;
    index index.html;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Disable access logs for favicon and robots.txt
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    
    location = /robots.txt {
        log_not_found off;
        access_log off;
    }
}
EOF

    # Start nginx
    nginx -t && nginx -g 'daemon off;' >/workspace/logs/nginx.log 2>&1 &
    
    echo "nginx: started on port 80"
    echo "nginx: log file at /workspace/logs/nginx.log"
    echo "nginx: serving landing page at http://${EXTERNAL_IP}:80"
}

# Main execution if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    start_nginx
fi