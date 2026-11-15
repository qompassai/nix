# SSD merge gate observations

The merge branch uses the deployed SSD lock unchanged. At that lock the package
attribute is oneDNN; onednn is absent (checked by evaluation). Only primo remains
an exposed NixOS host; ARM source files remain but lack a deployed ARM base.
The local sops policy and encrypted placeholders require provisioning before
activation. No build or runtime decryption was validated. See REPORT.md for gates.
