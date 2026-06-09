# Security Policy

## Reporting a vulnerability

If you discover a security vulnerability in Vesker, please **open a
[GitHub issue](../../issues)** describing the problem and how to reproduce it.

Vesker is a small open-source project without a dedicated security team, so please be patient while
the issue is triaged. We appreciate responsible disclosure — give us a reasonable chance to ship a
fix before publicizing details more widely.

## Scope

Vesker is auth-sensitive: it has passwordless email-code login, WebAuthn passkeys, Pundit-based
authorization, and user file uploads. Reports about authentication bypass, authorization gaps
(accessing albums/moments you shouldn't), session/cookie handling, or upload handling are especially
valuable.

## Supported versions

Only the latest `main` is supported. Please confirm an issue still reproduces on `main` before
reporting.
