# Local-github JSON Presets

This repo stores preset dropdown choices in `config/options.json` and uses string inputs in the workflow.
You can pass explicit values or tokens that reference the JSON.

## Tokens
- @users:0  → the 1st entry under `users` (name+password)
- @wifi:1   → the 2nd Wi‑Fi entry (ssid+password)
- @ssh:2    → the 3rd SSH preset
- @net:0    → the 1st IPv4 tuple (ip+gateway+dns)
- @tz:0, @country:0, @kbd:2 for `timezones`, `wifi_countries`, `keyboards`

## Examples
- user_name: chip
- user_password: raspberry
- wifi_ssid: Raspbain
- wifi_password: Zombie1986X2
- ssh_permit_root_login: yes|no|prohibit-password
- ssh_password_auth: yes|no
- ssh_pubkey_auth: yes|no
- static_ip: 192.168.0.8
- gateway: 192.168.0.1
- dns: 1.1.1.1;8.8.8.8
- keyboard: us|gb|au|...|custom (if custom, set keyboard_custom)
