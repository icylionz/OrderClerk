class NotFoundException implements Exception {
  String group;
  int id;
  NotFoundException(this.group, this.id);
}