# Local-github — dropdown Timezones + 32/64-bit

This package updates the workflow to include:
- **Timezone**: full IANA timezone dropdown (e.g., `Australia/Sydney`).
- **Bit type**: dropdown `64bit` or `32bit` that maps architectures per target:
  - **Pi**: 64bit → arm64, 32bit → armhf (the action defaults to arm64; armhf may require action support).
  - **PC**: 64bit → amd64, 32bit → i386.
  - **Generic**: 64bit → arm64, 32bit → i386 (adjust as you like).

> Note: For Raspberry Pi via `usimd/pi-gen-action`, 32-bit (`armhf`) support depends on the action. The workflow passes an `ARCH_PI` env you can use or switch to a custom pi-gen invocation if needed.
