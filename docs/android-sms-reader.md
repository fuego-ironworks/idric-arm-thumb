# Android SMS reader: Edriç → direct DEX

Status: first Android-framework DEX slice under development.

## Immediate acceptance target

A physical Android phone runs a directly encoded DEX Activity that:

1. obtains a `ContentResolver`;
2. parses `content://sms`;
3. calls the API-26 `ContentResolver.query(Uri, String[], Bundle,
   CancellationSignal)` overload with null projection/query arguments;
4. obtains `body` and `address` column indexes;
5. iterates the returned `Cursor`;
6. calls `getString` for both columns on every row;
7. closes the cursor;
8. logs only the row count.

The candidate DEX is emitted directly by Edriç code. Java source, Kotlin,
Gradle, javac, d8, and smali are absent from the production path. Smali is an
oracle only.

## Why this is a useful DEX step

The generic checked-ANF DEX backend can already encode Int32, Text, object
moves, string constants, branches, and String equality. It still does not
lower arbitrary Android object types or framework method calls from checked
Idriç source.

The SMS reader therefore has two layers for now:

- `Backend.DEX.EncodeSmsReader`: a bounded direct DEX Android adapter proving
  the required framework calls and bytecode shapes;
- future checked-source bindings: the semantic Idriç API that should compile
  to the same DEX operations once reference types and external calls are part
  of the generic lowering.

This mirrors the existing NativeActivity boundary: use a narrow direct encoder
to establish facts about DEX/ART first, then generalize only what the source
language actually needs.

## Generic backend work exposed by SMS

The checked Idriç path needs these additions, in roughly dependency order:

1. **Typed reference values.** Replace the single undifferentiated
   `ObjectValue` internal notion with class/array descriptors where DEX method
   signatures require them.
2. **Null references.** Represent a checked null reference separately from an
   integer zero even though DEX uses a zero constant encoding.
3. **External method references.** Generalize the hard-coded
   `String.equals` method reference into typed static, virtual, interface,
   direct, and super calls.
4. **Invoke result types.** Support `move-result`, `move-result-object`, and
   later wide results according to the declared method descriptor.
5. **Reference/null branches.** Add `if-eqz` and `if-nez` for reference and
   Boolean control flow.
6. **Arrays.** Add reference-array support when an explicit SMS projection is
   introduced. The first proof deliberately passes a null projection.
7. **Int64 / wide registers.** Android SMS `date`, `date_sent`, `_id`,
   `thread_id`, and related columns are naturally 64-bit. A real semantic
   model should not truncate them to Int32 just because the first DEX slice is
   narrow.
8. **Android application boundary.** Generalize Activity superclass,
   constructor, lifecycle method, manifest, permission, APK packaging, and
   signing support without folding those concerns into ordinary pure lowering.
9. **Permission/role capability.** `READ_SMS` is hard-restricted on modern
   Android. The language-facing API should express the capability explicitly
   and allow Shizuku/Crawl Space/privileged-device implementations underneath
   it where ordinary app permission is unavailable.

## Next semantic API

The Idriç-facing layer should describe SMS rather than Cursor mechanics.
A reader should eventually resemble:

```text
messages : SmsStore

read messages : Stream SmsMessage
search messages query : Stream SmsMessage
```

with semantic fields such as `SmsAddress`, `SmsBody`, timestamps,
direction/type, read state, delivery status, thread, and subscription.

The first export/import project can then consume that API without knowing
anything about Binder transactions or Android cursor column positions.

## Tests

Run host structure/oracle acceptance with:

```sh
bash tests/dex/sms-reader-host-acceptance.sh
```

With Android build tools and a physical phone:

```sh
bash tests/dex/sms-reader/phone-acceptance.sh
```

Phone acceptance refuses to convert a missing hard-restricted `READ_SMS`
grant into a false PASS.
