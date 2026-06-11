# User Checks

A Windows PowerShell GUI tool for Active Directory account support. The script helps support analysts check common user-account conditions such as lockout status, bad password counts, password age, account status, mailbox attributes, and password-policy information.

## What It Demonstrates

- PowerShell automation for help desk and identity support workflows
- Windows Forms GUI creation with .NET
- Active Directory account lookup with `Get-ADUser`
- Lockout and bad-password investigation
- Password reset and unlock workflows
- Clear output for support decision-making

## Support Scenarios

- Determine whether an account is locked or disabled.
- Compare bad-password counts against domain controller information.
- Check password age and password-expired conditions.
- Review mailbox/license-related attributes.
- Surface domain password policy details for troubleshooting.

## Production Support Relevance

This project maps directly to identity and access support work. It shows how repetitive support checks can be wrapped in a GUI to reduce lookup time, standardize investigation steps, and help analysts make safer account-support decisions.

## Important Note

This script should be reviewed and sanitized before use outside a lab or approved enterprise environment. Public portfolio versions should avoid organization-specific URLs, domains, or internal process references.

## Suggested Improvements

- Move organization-specific URLs into a local configuration file.
- Add transcript logging for auditability.
- Add role/permission checks before write actions.
- Separate read-only checks from account-changing actions.
- Add clearer error handling for missing AD modules or insufficient privileges.
