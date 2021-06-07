import 'dart:convert';


class Paginated<T> {
  List<T> data;
  Paging paging;

  Paginated({
    this.data,
    this.paging,
  });
}

class Paging {
  int count;
  int pageItemLimit;
  String next;
  String previous;

  Paging({
    this.count,
    this.pageItemLimit,
    this.next,
    this.previous
  });

  String get description => 'count: $count\npageItemLimit: $pageItemLimit\nnext: $next\nprevious: $previous';

  factory Paging.fromRawJson(String str) => Paging.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Paging.fromJson(Map<String, dynamic> json) => Paging(
    count: json["count"],
    pageItemLimit: json["page_item_limit"],
    next: json["next"],
      previous: json["previous"]
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "page_item_limit": pageItemLimit,
    "next": next,
    "previous": previous,
  };
}