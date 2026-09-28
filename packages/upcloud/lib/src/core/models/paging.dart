import 'package:freezed_annotation/freezed_annotation.dart';

part 'paging.freezed.dart';

/// Pagination parameters for list operations.
@freezed
abstract class PageRequest with _$PageRequest {
  /// Requests [page] (1-based) with up to [perPage] items.
  const factory PageRequest({@Default(1) int page, @Default(50) int perPage}) =
      _PageRequest;

  const PageRequest._();

  /// The first page with the default size.
  static const first = PageRequest();

  /// The page after this one.
  PageRequest get next => copyWith(page: page + 1);
}

/// A page of results returned by a list operation.
@freezed
abstract class PagedResult<T> with _$PagedResult<T> {
  /// Creates a page of [items].
  const factory PagedResult({
    required List<T> items,
    required PageRequest request,

    /// Total number of items across all pages, if known.
    int? totalItems,

    /// Total number of pages, if known.
    int? totalPages,

    /// Explicit flag from the provider. When `null` it is inferred from
    /// [totalPages] or from the page being full.
    bool? hasMoreHint,
  }) = _PagedResult<T>;

  const PagedResult._();

  /// Whether another page can be requested.
  bool get hasMore {
    if (hasMoreHint != null) return hasMoreHint!;
    if (totalPages != null) return request.page < totalPages!;
    if (totalItems != null) {
      return request.page * request.perPage < totalItems!;
    }
    return items.length >= request.perPage;
  }
}
