/// Identifier of a file inside a provider (e.g. an XVS `file_code`).
///
/// Ids are opaque: only the provider that produced them knows how to
/// interpret them.
extension type const FileId(String value);

/// Identifier of a folder inside a provider (e.g. an XVS `fld_id`).
///
/// The root folder is represented by `null` wherever a `FolderId?` is
/// accepted, so providers can map it to their own convention (`0`,
/// `myfiles`, ...).
extension type const FolderId(String value);
