# 📁 Samba Share Guide - Access Notes from Windows/Mac

**Purpose**: Access your FlowTech-AI Notes folder from your Windows/Mac computer over the network

---

## 🎯 Why Samba?

FlowTech-AI runs on a **Linux server/VM**, but you work from **Windows/Mac**.

Samba allows you to:
- ✅ Access `Notes/` folder from your PC as a network drive
- ✅ Edit notes with Obsidian directly on the server
- ✅ Real-time synchronization (no manual sync needed)
- ✅ Multi-user access (team collaboration)

---

## 🚀 Setup (5 minutes)

### Step 1: Enable Samba in FlowTech-AI

Samba is **optional** and uses Docker profile `samba`.

**During installation** (`./init.sh`):
- Samba credentials are auto-generated
- Service is configured but **not started by default**

**To start Samba**:
```bash
cd FlowTech-AI
docker compose --profile samba up -d samba
```

**Check it's running**:
```bash
docker compose ps | grep samba
# Should show: samba-notes  Up  0.0.0.0:445->445/tcp
```

### Step 2: Get Credentials

Credentials are in `.env` file:

```bash
cat .env | grep SAMBA
```

**Example output**:
```
SAMBA_USER=admin
SAMBA_PASSWORD=HdviwuBXcmx/C5RLgnmjFTATclRyn+zY
SAMBA_UID=1000
SAMBA_GID=1000
SAMBA_PORT=445
```

**Save these!** You'll need them to connect.

### Step 3: Find Your Server IP

On the Linux server:
```bash
hostname -I | awk '{print $1}'
# Example: 192.168.0.246
```

---

## 💻 Connect from Windows

### Method 1: Map Network Drive (Recommended)

1. **Open File Explorer**
2. **Right-click "This PC"** → **"Map network drive..."**
3. **Choose drive letter** (e.g., Z:)
4. **Folder**: `\\192.168.0.246\notes`
   - Replace `192.168.0.246` with your server IP
5. ✅ **Check "Reconnect at sign-in"**
6. ✅ **Check "Connect using different credentials"**
7. Click **"Finish"**
8. **Enter credentials**:
   - Username: `admin`
   - Password: (from `.env` SAMBA_PASSWORD)
9. Click **"OK"**

✅ **Done!** Drive Z: now shows your Notes folder.

### Method 2: Direct Access (Quick Test)

1. **Press Win + R**
2. **Type**: `\\192.168.0.246\notes`
3. **Press Enter**
4. **Enter credentials** when prompted
5. **Folder opens** in File Explorer

### Method 3: Add to Quick Access

1. Open `\\192.168.0.246\notes`
2. **Right-click** the folder in File Explorer
3. **"Pin to Quick access"**

---

## 🍎 Connect from macOS

### Method 1: Finder (GUI)

1. **Open Finder**
2. **Press Cmd + K** (or Go → "Connect to Server")
3. **Server Address**: `smb://192.168.0.246/notes`
4. Click **"Connect"**
5. **Registered User**: 
   - Name: `admin`
   - Password: (from `.env`)
6. Click **"Connect"**

✅ **Done!** Folder appears in Finder sidebar.

### Method 2: Terminal (CLI)

```bash
# Create mount point
mkdir -p ~/FlowTech-Notes

# Mount share
mount -t smbfs //admin@192.168.0.246/notes ~/FlowTech-Notes

# Enter password when prompted
```

---

## 🐧 Connect from Linux

### Ubuntu/Debian

```bash
# Install CIFS utils
sudo apt install cifs-utils

# Create mount point
sudo mkdir -p /mnt/flowtech-notes

# Mount share
sudo mount -t cifs //192.168.0.246/notes /mnt/flowtech-notes -o username=admin,password=YOUR_PASSWORD

# Or add to /etc/fstab for automatic mount
echo "//192.168.0.246/notes /mnt/flowtech-notes cifs username=admin,password=YOUR_PASSWORD,uid=1000,gid=1000 0 0" | sudo tee -a /etc/fstab
```

---

## 📝 Use with Obsidian

### Windows

1. **Open Obsidian**
2. **Click "Open folder as vault"**
3. **Select**: `Z:\` (your mapped network drive)
   - Or browse to `\\192.168.0.246\notes`
4. **Click "Open"**

✅ **Vault opens** with templates and examples!

### macOS

1. **Open Obsidian**
2. **Click "Open folder as vault"**
3. **Navigate to**: `/Volumes/notes` (or your mount point)
4. **Click "Open"**

### What You'll See

```
Notes/
├── _Templates/           ← Ready-to-use templates
│   ├── vm-template.md
│   ├── server-template.md
│   └── domain-template.md
│
├── VMs/                  ← Example VM notes
│   └── VM-Example-WebServer.md
│
├── Servers/              ← Example server notes
│   └── Server-Example-Database.md
│
└── Domains/              ← Example domain notes
    └── Domain-Example.md
```

**Start by**:
1. Exploring the examples
2. Duplicating a template
3. Creating your first real note!

---

## 🔧 Troubleshooting

### Problem: Can't connect to \\SERVER_IP\notes

**Check**:
1. Is Samba running?
   ```bash
   docker compose ps | grep samba
   ```
2. Is port 445 accessible?
   ```bash
   # On server
   sudo ufw allow 445
   ```
3. Can you ping the server?
   ```bash
   ping 192.168.0.246
   ```

### Problem: Authentication fails

**Check**:
1. Credentials correct?
   ```bash
   cat .env | grep SAMBA_PASSWORD
   ```
2. Try disconnecting and reconnecting
3. On Windows: Clear saved credentials
   - Control Panel → Credential Manager
   - Remove old credentials for the server

### Problem: "Access Denied" or permission errors

**Fix permissions on server**:
```bash
cd FlowTech-AI
sudo chown -R 1000:1000 Notes/
chmod -R 775 Notes/
```

### Problem: Can't see files in Obsidian

**Check**:
1. Folder is mounted correctly
2. Files exist:
   ```bash
   ls -la Notes/
   ```
3. Obsidian has permission to access network drive

---

## 🔒 Security Notes

### For Local Network (Home/Office)

Current config is **secure for LAN**:
- ✅ Password-protected
- ✅ User authentication required
- ✅ No guest access

### For Internet-Facing (Advanced)

**NOT recommended** to expose Samba to internet!

If you must:
1. Use VPN (WireGuard, OpenVPN)
2. Firewall rules (only allow specific IPs)
3. Strong passwords (already done)
4. Consider SSH tunnel instead

---

## 💡 Tips & Tricks

### Auto-Connect on Windows

Make Windows reconnect automatically:
1. Map network drive with "Reconnect at sign-in" ✅
2. Save credentials in Credential Manager
3. Drive connects automatically at boot

### Obsidian Plugin: Templater

Use with templates:
```javascript
// Auto-fill template fields
IP: <% tp.system.prompt("Enter VM IP") %>
Name: <% tp.system.prompt("Enter VM Name") %>
```

### Backup Strategy

Even with Samba, **backup your notes**:
```bash
# On server
tar -czf notes-backup-$(date +%Y%m%d).tar.gz Notes/
```

Or use the server's existing backup system.

---

## 📊 Performance

**Expected performance over LAN**:
- Opening files: Instant
- Saving files: < 1 second
- Obsidian sync: Real-time
- Search: Same as local

**Over slower networks**:
- May have slight delay
- Consider working offline and syncing later

---

## 🎯 Quick Reference

### Connection Strings

**Windows**: `\\192.168.0.246\notes`  
**macOS**: `smb://192.168.0.246/notes`  
**Linux**: `//192.168.0.246/notes`

### Default Credentials

**Username**: `admin`  
**Password**: Check `.env` file (`SAMBA_PASSWORD`)

### Ports

**Samba**: 445 (SMB)

### Service Control

```bash
# Start
docker compose --profile samba up -d samba

# Stop
docker compose stop samba

# Logs
docker compose logs -f samba
```

---

## ✅ Checklist

Before using Samba:

- [ ] Samba service started
- [ ] Credentials saved
- [ ] Server IP known
- [ ] Port 445 accessible (firewall)
- [ ] Network drive mapped
- [ ] Obsidian can access folder
- [ ] Can create/edit files
- [ ] Examples visible

---

**Happy note-taking over the network! 📝**

