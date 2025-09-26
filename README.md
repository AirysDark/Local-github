# Local-github (All targets with dropdown config)

This repo builds console-only images and lets you set **hostname, users, SSH policy, Wi‑Fi, IP config** via the **workflow dropdown**.

## Inputs (workflow_dispatch)
- target: `pi | pc | arm64 | armhf | riscv64 | i386 | i860`
- hostname, username, user_password, root_password
- Wi‑Fi: ssid, password, country
- timezone, keyboard
- Static IP (eth0): ip, gateway, dns (semicolon-separated)
- SSH: PermitRootLogin, PasswordAuthentication, PubkeyAuthentication

Pi & PC builds apply these settings; generic/i860 steps are placeholders.

> Security: Defaults are permissive for first boot. Switch to key-only SSH after provisioning.
