.class public Lorg/isomorphisms/smsreader/SmsReaderActivity;
.super Landroid/app/Activity;

.method public constructor <init>()V
    .registers 1

    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .registers 10

    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v1

    const-string v5, "content://sms"
    invoke-static {v5}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v0

    const/4 v2, 0x0
    invoke-virtual {v1, v0, v2, v2, v2}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Landroid/os/Bundle;Landroid/os/CancellationSignal;)Landroid/database/Cursor;
    move-result-object v3

    if-eqz v3, :done

    invoke-interface {v3}, Landroid/database/Cursor;->getCount()I
    move-result v4
    invoke-static {v4}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v5
    const-string v0, "IdricSmsCount"
    invoke-static {v0, v5}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    move-result v4

    const-string v5, "body"
    invoke-interface {v3, v5}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I
    move-result v6

    const-string v5, "address"
    invoke-interface {v3, v5}, Landroid/database/Cursor;->getColumnIndex(Ljava/lang/String;)I
    move-result v7

    invoke-interface {v3}, Landroid/database/Cursor;->moveToFirst()Z
    move-result v4
    if-eqz v4, :close

:loop
    invoke-interface {v3, v6}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v5
    invoke-interface {v3, v7}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v5
    invoke-interface {v3}, Landroid/database/Cursor;->moveToNext()Z
    move-result v4
    if-nez v4, :loop

:close
    invoke-interface {v3}, Landroid/database/Cursor;->close()V

:done
    return-void
.end method
