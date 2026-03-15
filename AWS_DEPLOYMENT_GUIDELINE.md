# AWS 3-Tier Architecture Deployment Guide

Hosting a 3-tier application on AWS requires setting up Networking, Computing, and Database layers. Below is the step-by-step setup guide.

## 1. Networking Layer (VPC)
The foundation of your architecture.
*   **VPC**: Create a VPC (e.g., `10.0.0.0/16`).
*   **Subnets**:
    *   **Public Subnets (x2)**: In different Availability Zones (AZs) for External Load Balancers.
    *   **Private App Subnets (x2)**: In different AZs for your Web/App EC2 instances.
    *   **Private DB Subnets (x2)**: In different AZs for the Aurora Database.
*   **Internet Gateway (IGW)**: Attach to the VPC to allow traffic to the public subnets.
*   **NAT Gateway**: Place in a public subnet to allow private app instances to download updates.

## 2. Security Groups (Firewalls)
*   **Web-SG**: Allow Port 80/443 from Everywhere (0.0.0.0/0).
*   **App-SG**: Allow Port 4000 from the Internal Load Balancer Security Group.
*   **DB-SG**: Allow Port 3306 from the App-SG.

## 3. Database Layer (Aurora)
*   **Subnet Group**: Create an RDS Subnet Group using the two Private DB Subnets.
*   **Provision**: Create an **Amazon Aurora MySQL** cluster.
*   **Access**: Ensure it uses the **DB-SG**.
*   **Setup**: Once created, take the **Cluster Endpoint** and update your `DbConfig.js`.

## 4. App Tier Setup (EC2)
*   **Provision**: Launch an EC2 (Amazon Linux 2) in a Private App Subnet.
*   **Install Node.js**:
    ```bash
    curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
    sudo yum install -y nodejs
    ```
*   **Deploy**: Upload the `app-tier` code, run `npm install`, and start the app (`node index.js`).
*   **Internal Load Balancer**: Create an Internal ALB that forwards traffic to these App EC2 instances on port 4000.

## 5. Web Tier Setup (EC2)
*   **Provision**: Launch an EC2 in a Private App Subnet.
*   **Install NGINX & Node.js**:
    ```bash
    sudo amazon-linux-extras install nginx1
    ```
*   **Deploy**:
    1. Update `nginx.conf` with the **Internal ALB DNS**.
    2. Build React app (`npm run build`) and move files to `/var/www/html` or similar.
    3. Start NGINX.
*   **External Load Balancer**: Create an External (Internet-facing) ALB that forwards traffic to these Web EC2 instances on port 80.

---

## 🛠️ Infrastructure Checklist

| Component | Status | Note |
| :--- | :--- | :--- |
| VPC & Subnets | 🔲 | Need 6 subnets total for High Availability. |
| Aurora DB Cluster | 🔲 | Note down the endpoint. |
| Internal Load Balancer | 🔲 | Used by Web Tier to talk to App Tier. |
| External Load Balancer | 🔲 | The public entry point for users. |
| S3 Bucket | 🔲 | (Optional) To store the application code for deployment. |
