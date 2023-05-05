enum HistoryKey {
  data('data'),
  type('type'),
  starred('pinned'),
  createdAt('created_at'),
  ;

  const HistoryKey(this.str);

  final String str;
}
