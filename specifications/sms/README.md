# SMS references for the Android reader

This directory separates three different contracts that are easy to conflate.

## Android stored-message contract

The reader being developed here reads Android's SMS provider. The authoritative
programming interfaces are Android's:

- `android.provider.Telephony.Sms` / `Telephony.TextBasedSmsColumns`;
- `android.content.ContentResolver.query`;
- `android.database.Cursor`;
- `android.permission.READ_SMS`.

The first read-only slice uses `content://sms` and reads the `body` and
`address` columns. Later slices should add `_id`, `thread_id`, `date`,
`date_sent`, `type`, `read`, `status`, and `sub_id` with semantic
Idriç types instead of exposing untyped column numbers.

`READ_SMS` is a dangerous, hard-restricted permission on current Android.
That is an installation/role/privilege constraint, not a DEX encoding issue.
Phone acceptance therefore reports `NOT_VERIFIED` rather than claiming a
compiler failure when a sideloaded APK cannot be granted the permission.

## IETF material

There is no RFC defining Android's `content://sms` provider.

The directly relevant RFC is:

- RFC 5724 — *URI Scheme for Global System for Mobile Communications (GSM)
  Short Message Service (SMS)*.

Its telephone-number syntax depends on:

- RFC 3966 — *The tel URI for Telephone Numbers*.

RFC 5724 also depends on the generic URI and ABNF definitions:

- RFC 3986 — *Uniform Resource Identifier (URI): Generic Syntax*.
- RFC 5234 — *Augmented BNF for Syntax Specifications: ABNF*.

Run `fetch-rfcs.sh` to materialize exact RFC Editor text copies into
`specifications/sms/rfc/`. The fetch script is kept in the repository so the
documents come from the authoritative source rather than from a transcription.

RFC 5724 is mainly relevant to future compose/send URI handling. It does not
specify Android's stored-message schema.

## 3GPP material

For actual SMS transport/encoding semantics, the relevant specifications are
3GPP rather than IETF:

- 3GPP TS 23.040 — technical realization of SMS;
- 3GPP TS 23.038 — alphabets and language-specific information.

These are references for later transport/PDU work. Reading the Android provider
does not require implementing their PDU formats.

## Implementation target

The semantic layer should eventually expose values such as:

- `SmsMessageId`
- `SmsAddress`
- `SmsBody`
- `SmsReceivedAt`
- `SmsSentAt`
- `SmsMessageType`
- `SmsReadState`
- `SmsDeliveryStatus`
- `SmsThreadId`
- `SmsSubscriptionId`

The DEX/backend layer should own `ContentResolver`, `Cursor`, Android object
references, null handling, and permission plumbing. Those mechanisms should
not leak upward as the meaning of a text message.
