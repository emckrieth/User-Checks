# Support Workflow

## Goal

Provide a repeatable process for investigating Active Directory account access issues.

## Triage Steps

1. Confirm the user ID and reported symptom.
2. Check whether the account exists and is enabled.
3. Check lockout status and bad-password counts.
4. Review password age, expiration, and must-change-password flags.
5. Check mailbox/license attributes when email access is part of the issue.
6. Escalate if account state conflicts with expected domain controller information.

## Safe Operation Notes

- Prefer read-only checks before taking account-changing actions.
- Confirm user identity and ticket authorization before unlocking or resetting passwords.
- Document any account-changing action in the support ticket.
- Keep public scripts sanitized by using placeholder URLs or local configuration for environment-specific values.

## Production Support Skills Represented

- Identity support triage
- Active Directory troubleshooting
- GUI scripting for analyst workflows
- Support process standardization
- Clear technical communication
