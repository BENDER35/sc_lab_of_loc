# Macros Lab (Safe)

This folder is for **your own harmless test files** created inside an isolated VM.

## Rules

- Do **not** add real malware samples.
- Do **not** add files you do not own or have permission to share.
- Prefer synthetic, inert examples (e.g., a macro that only shows `MsgBox "Hello lab"`).
- Keep generated `.docm/.xlsm` files ignored by git (see `.gitignore`).

## Suggested harmless exercise

1. In an isolated Windows VM, create a Word document.
2. Add a macro:
   ```vba
   Sub AutoOpen()
       MsgBox "Hello from isolated lab"
   End Sub
   ```
3. Save a copy as `.docm` locally (not committed).
4. Analyze with `oleid`, `olevba`, and `mraptor`.
5. Apply hardening and confirm policy blocks macro execution as configured.
