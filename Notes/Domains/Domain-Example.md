---
type: domain
name: example.com
ip: 203.0.113.50
domain_type: public
status: active
registrar: Namecheap
services:
  - website
  - email
  - api
created: 2024-06-01
expires: 2026-06-01
updated: 2025-01-15
tags: [example, public, production]
---

# example.com

## 📋 Description

Example domain name configuration and management.

This is a **template example** - duplicate for your own domains.

## 🌐 DNS Configuration

### A Records
```
@       A       203.0.113.50
www     A       203.0.113.50
api     A       203.0.113.51
```

### MX Records
```
@       MX  10  mail.example.com
```

### TXT Records
```
@       TXT     "v=spf1 include:_spf.google.com ~all"
```

## 🔒 SSL Certificates

- **Provider**: Let's Encrypt
- **Type**: Wildcard (*.example.com)
- **Expires**: 2025-04-15
- **Auto-renewal**: Enabled (certbot)

## 📧 Email Services

- **Provider**: Google Workspace
- **MX Priority**: 10
- **DKIM**: Enabled
- **DMARC**: p=quarantine

## 🔐 Registrar Info

- **Registrar**: Namecheap
- **Account**: admin@company.com
- **Registered**: 2024-06-01
- **Expires**: 2026-06-01
- **Auto-renew**: ✅ Enabled

## 🔗 Related Notes

- [[Web-Server-01]] - Hosting server
- [[Email-Configuration]]
- [[SSL-Certificate-Management]]

## 📝 Maintenance Log

### 2025-01-15
- Renewed SSL certificate
- Updated DNS records
- Verified email delivery

### 2024-12-01
- Migrated to new server
- Updated A records

## 📊 Monitoring

- **Status**: Active ✅
- **DNS Propagation**: Complete
- **SSL**: Valid
- **Email**: Operational

---

*Example Domain - Replace with your actual domain information*

