import 'pickle_request.dart';

class PickleOutbox {
  final List<PickleRequest> _items;

  PickleOutbox() : _items = [];

  PickleOutbox.load(Iterable<PickleRequest> items) : _items = List.of(items);

  List<PickleRequest> get items {
    final sorted = List<PickleRequest>.of(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  void save(PickleRequest request) {
    _items.add(request);
  }

  void markDone(String id) {
    for (final item in _items) {
      if (item.id == id) {
        _items[_items.indexOf(item)] = _replaced(item);
        return;
      }
    }
  }

  PickleRequest _replaced(PickleRequest item) {
    final next = PickleRequest(
      id: item.id,
      category: item.category,
      message: item.message,
      audience: item.audience,
      status: PickleStatus.done,
      createdAt: item.createdAt,
    );
    return next;
  }
}
