class Filter {
  List<FilterEntry> filter = [];
  List<dynamic> columns = [];

  //add a filter entry to the filter
  void add(
      {String? name,
      String? where,
      String? whereArgs,
      bool exact = false,
      bool contains = false,
      bool begins = false,
      bool ends = false}) {
    filter.add(FilterEntry(
        name: name,
        where: where,
        whereArgs: whereArgs,
        exact: exact,
        contains: contains,
        begins: begins,
        ends: ends));
  }

  //edit a filterEntry by name
  void edit(
      {String? name,
      String? where,
      String? whereArgs,
      bool exact = false,
      bool contains = false,
      bool begins = false,
      bool ends = false}) {
    filter.map((e) {
      if (e.name == name) {
        e = FilterEntry(
            name: name,
            where: where,
            whereArgs: whereArgs,
            exact: exact,
            contains: contains,
            begins: begins,
            ends: ends);
      }
    });
  }

  //find a filterEntry by name
  FilterEntry? find({String? name}) {
    FilterEntry? found;
    filter.map((e) {
      if (e.name == name) {
        found = e;
      }
    });
    return found;
  }

  //delete a filterEntry by name
  void delete({required FilterEntry? entry}) {
    if (entry != null) filter.remove(entry);
  }

  //delete all filter entries
  void clear() {
    filter.clear();
  }

  Map<String, dynamic> get map {
    Map<String, dynamic> filterMap = {"where": null, "whereArgs": null};

    filter.forEach((e) {
      if (e.whereArgs != null) {
        filterMap["where"] ??= "";
        filterMap["whereArgs"] ??= [];

        filterMap["where"] = filterMap["where"].toString() + "${e.where!} = ?,";
        filterMap["whereArgs"].add("${e.whereArgs}");
      }
    });

    //removes the comma at the end of the string that causes the
    //sqlite query to return an error
    if (filterMap["where"].toString().endsWith(",")) {
      filterMap["where"] = filterMap["where"]
          .toString()
          .substring(0, filterMap["where"].toString().length - 1);
    }

    return filterMap;
  }
}

enum OrderDirection { DESC, ASC }

class ItemFilter {
  static List<FilterEntry> filter = [];
  static List<dynamic> columns = [];
  static String? orderBy;

  //Set order by clause
  static void setOrderBy(String? orderBy, OrderDirection orderDirection) {
    ItemFilter.orderBy =
        "ORDER BY $orderBy ${(orderDirection == OrderDirection.DESC) ? "DESC" : "ASC"}";
  }

  //add a filter entry to the filter
  static void add(
      {String? name,
      String? where,
      String? whereArgs,
      String? firstDate,
      String? lastDate,
      bool isDate = false,
      bool isBool = false,
      bool exact = false,
      bool contains = false,
      bool begins = false,
      bool ends = false}) {
    if (ItemFilter.find(name: "$name") == null)
      filter.add(FilterEntry(
          name: name,
          where: where,
          whereArgs: whereArgs,
          firstDate: firstDate,
          lastDate: lastDate,
          isDate: isDate,
          isBool: isBool,
          exact: exact,
          contains: contains,
          begins: begins,
          ends: ends));
    else {
      ItemFilter.delete(
          entry: filter.singleWhere((element) => element.name == name));
      ItemFilter.add(
          name: name,
          where: where,
          whereArgs: whereArgs,
          firstDate: firstDate,
          lastDate: lastDate,
          isDate: isDate,
          isBool: isBool,
          exact: exact,
          contains: contains,
          begins: begins,
          ends: ends);
    }
  }

  //edit a filterEntry by name
  static void edit(
      {String? name,
      String? where,
      String? whereArgs,
      bool isDate = false,
      bool isBool = false,
      String? firstDate,
      String? lastDate,
      bool exact = false,
      bool contains = false,
      bool begins = false,
      bool ends = false}) {
    ItemFilter.delete(
        entry: filter.singleWhere((element) => element.name == name));
    ItemFilter.add(
        name: name,
        where: where,
        whereArgs: whereArgs,
        firstDate: firstDate,
        lastDate: lastDate,
        isDate: isDate,
        isBool: isBool,
        exact: exact,
        contains: contains,
        begins: begins,
        ends: ends);
  }

  //find a filterEntry by name
  static FilterEntry? find({String? name}) {
    FilterEntry? found;
    filter.forEach((e) {
      if (e.name == name) {
        found = e;
      }
    });
    return found;
  }

  //delete a filterEntry by name
  static void delete({required FilterEntry? entry}) {
    if (entry != null) filter.remove(entry);
  }

  //delete all filter entries
  static void clear() {
    filter.clear();
  }

  static Map<String, dynamic> get map {
    Map<String, dynamic> filterMap = {"where": null, "whereArgs": null};

    filter.forEach((e) {
      if (e.whereArgs != null || e.firstDate != null || e.lastDate != null) {
        filterMap["where"] ??= "";
        filterMap["whereArgs"] ??= [];
        // Boolean Handler
        if (e.isBool) {
          filterMap["whereArgs"].add("${e.whereArgs}");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} ? AND";
        } else if (e.exact) {
          // Exact Handler
          filterMap["whereArgs"].add("${e.whereArgs}");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} = ? AND";
        } else if (e.contains) {
          // Contain Handler
          filterMap["whereArgs"].add("%${e.whereArgs}%");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        } else if (e.begins) {
          //Begin with Handler
          filterMap["whereArgs"].add("${e.whereArgs}%");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        } else if (e.ends) {
          // End with Handler
          filterMap["whereArgs"].add("%${e.whereArgs}");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        } else if (e.isDate) {
          // Date Handler
          filterMap["whereArgs"].add("${e.firstDate}");
          filterMap["whereArgs"].add("${e.lastDate}");
          filterMap["where"] =
              filterMap["where"].toString() + " (${e.where!} BETWEEN ? AND ?)";
        }
      }
    });

    //removes the comma at the end of the string that causes the
    //sqlite query to return an error
    if (filterMap["where"].toString().endsWith("AND")) {
      filterMap["where"] = filterMap["where"]
          .toString()
          .substring(0, filterMap["where"].toString().length - 3);
    }

    return filterMap;
  }
}

class DistributorFilter {
  static List<FilterEntry> filter = [];

  static String? orderBy;
//Set order by clause
  static void setOrderBy(String? orderBy, OrderDirection orderDirection) {
    DistributorFilter.orderBy =
        "ORDER BY $orderBy ${(orderDirection == OrderDirection.DESC) ? "DESC" : "ASC"}";
  }

  //add a filter entry to the filter
  static void add(
      {String? name,
      String? where,
      String? whereArgs,
      String? firstDate,
      String? lastDate,
      bool isDate = false,
      bool isBool = false,
      bool exact = false,
      bool contains = false,
      bool begins = false,
      bool ends = false}) {
    if (DistributorFilter.find(name: "$name") == null)
      filter.add(FilterEntry(
          name: name,
          where: where,
          whereArgs: whereArgs,
          firstDate: firstDate,
          lastDate: lastDate,
          isDate: isDate,
          isBool: isBool,
          exact: exact,
          contains: contains,
          begins: begins,
          ends: ends));
    else {
      DistributorFilter.edit(
          name: name,
          where: where,
          whereArgs: whereArgs,
          firstDate: firstDate,
          lastDate: lastDate,
          isDate: isDate,
          isBool: isBool,
          exact: exact,
          contains: contains,
          begins: begins,
          ends: ends);
    }
  }

  //edit a filterEntry by name
  static void edit(
      {String? name,
      String? where,
      String? whereArgs,
      bool isDate = false,
      bool isBool = false,
      String? firstDate,
      String? lastDate,
      bool exact = false,
      bool contains = false,
      bool begins = false,
      bool ends = false}) {
    DistributorFilter.delete(
        entry: filter.singleWhere((element) => element.name == name));
    DistributorFilter.add(
        name: name,
        where: where,
        whereArgs: whereArgs,
        firstDate: firstDate,
        lastDate: lastDate,
        isDate: isDate,
        isBool: isBool,
        exact: exact,
        contains: contains,
        begins: begins,
        ends: ends);
  }

  //find a filterEntry by name
  static FilterEntry? find({String? name}) {
    FilterEntry? found;
    filter.forEach((e) {
      if (e.name == name) {
        found = e;
      }
    });
    return found;
  }

  //delete a filterEntry by name
  static void delete({required FilterEntry? entry}) {
    if (entry != null) filter.remove(entry);
  }

  //delete all filter entries
  static void clear() {
    filter.clear();
  }

  static Map<String, dynamic> get map {
    Map<String, dynamic> filterMap = {"where": null, "whereArgs": null};

    filter.forEach((e) {
      if (e.whereArgs != null) {
        filterMap["where"] ??= "";
        filterMap["whereArgs"] ??= [];
        if (e.exact) {
          filterMap["whereArgs"].add("${e.whereArgs}");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} = ? AND";
        } else if (e.contains) {
          filterMap["whereArgs"].add("%${e.whereArgs}%");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        } else if (e.begins) {
          filterMap["whereArgs"].add("${e.whereArgs}%");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        } else if (e.ends) {
          filterMap["whereArgs"].add("%${e.whereArgs}");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        }
      }
    });

    //removes the comma at the end of the string that causes the
    //sqlite query to return an error
    if (filterMap["where"].toString().endsWith("AND")) {
      filterMap["where"] = filterMap["where"]
          .toString()
          .substring(0, filterMap["where"].toString().length - 3);
    }

    return filterMap;
  }
}

class OrderFilter {
  static List<FilterEntry> filter = [];

  static String? orderBy;
//Set order by clause
  static void setOrderBy(String? orderBy, OrderDirection orderDirection) {
    OrderFilter.orderBy =
        "ORDER BY $orderBy ${(orderDirection == OrderDirection.DESC) ? "DESC" : "ASC"}";
  }

  //add a filter entry to the filter
  static void add(
      {String? name,
      String? where,
      String? whereArgs,
      String? firstDate,
      String? lastDate,
      bool isDate = false,
      bool isBool = false,
      bool exact = false,
      bool contains = false,
      bool begins = false,
      bool ends = false}) {
    if (OrderFilter.find(name: "$name") == null)
      filter.add(FilterEntry(
          name: name,
          where: where,
          whereArgs: whereArgs,
          firstDate: firstDate,
          lastDate: lastDate,
          isDate: isDate,
          isBool: isBool,
          exact: exact,
          contains: contains,
          begins: begins,
          ends: ends));
    else {
      OrderFilter.delete(
          entry: filter.singleWhere((element) => element.name == name));
      OrderFilter.add(
          name: name,
          where: where,
          whereArgs: whereArgs,
          firstDate: firstDate,
          lastDate: lastDate,
          isDate: isDate,
          isBool: isBool,
          exact: exact,
          contains: contains,
          begins: begins,
          ends: ends);
    }
  }

  //edit a filterEntry by name
  static void edit(
      {String? name,
      String? where,
      String? whereArgs,
      bool isDate = false,
      bool isBool = false,
      String? firstDate,
      String? lastDate,
      bool exact = false,
      bool contains = false,
      bool begins = false,
      bool ends = false}) {
    OrderFilter.delete(
        entry: filter.singleWhere((element) => element.name == name));
    OrderFilter.add(
        name: name,
        where: where,
        whereArgs: whereArgs,
        firstDate: firstDate,
        lastDate: lastDate,
        isDate: isDate,
        isBool: isBool,
        exact: exact,
        contains: contains,
        begins: begins,
        ends: ends);
  }

  //find a filterEntry by name
  static FilterEntry? find({String? name}) {
    FilterEntry? found;
    filter.forEach((e) {
      if (e.name == name) {
        found = e;
      }
    });
    return found;
  }

  //delete a filterEntry by name
  static void delete({required FilterEntry? entry}) {
    if (entry != null) filter.remove(entry);
  }

  //delete all filter entries
  static void clear() {
    filter.clear();
  }

  static Map<String, dynamic> get map {
    Map<String, dynamic> filterMap = {"where": null, "whereArgs": null};

    filter.forEach((e) {
      if (e.whereArgs != null || e.firstDate != null || e.lastDate != null) {
        filterMap["where"] ??= "";
        filterMap["whereArgs"] ??= [];
        // Boolean Handler
        if (e.isBool) {
          filterMap["whereArgs"].add("${e.whereArgs}");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} ? AND";
        } else if (e.exact) {
          // Exact Handler
          filterMap["whereArgs"].add("${e.whereArgs}");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} = ? AND";
        } else if (e.contains) {
          // Contain Handler
          filterMap["whereArgs"].add("%${e.whereArgs}%");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        } else if (e.begins) {
          //Begin with Handler
          filterMap["whereArgs"].add("${e.whereArgs}%");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        } else if (e.ends) {
          // End with Handler
          filterMap["whereArgs"].add("%${e.whereArgs}");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        } else if (e.isDate) {
          // Date Handler
          filterMap["whereArgs"].add("${e.firstDate}");
          filterMap["whereArgs"].add("${e.lastDate}");
          filterMap["where"] =
              filterMap["where"].toString() + " (${e.where!} BETWEEN ? AND ?)";
        }
      }
    });

    //removes the comma at the end of the string that causes the
    //sqlite query to return an error
    if (filterMap["where"].toString().endsWith("AND")) {
      filterMap["where"] = filterMap["where"]
          .toString()
          .substring(0, filterMap["where"].toString().length - 3);
    }

    return filterMap;
  }
}

class CategoryFilter {
  static List<FilterEntry> filter = [];

  static String? orderBy;
//Set order by clause
  static void setOrderBy(String? orderBy, OrderDirection orderDirection) {
    CategoryFilter.orderBy =
        "ORDER BY $orderBy ${(orderDirection == OrderDirection.DESC) ? "DESC" : "ASC"}";
  }

  //add a filter entry to the filter
  static void add(
      {String? name,
      String? where,
      String? whereArgs,
      String? firstDate,
      String? lastDate,
      bool isDate = false,
      bool isBool = false,
      bool exact = false,
      bool contains = false,
      bool begins = false,
      bool ends = false}) {
    if (CategoryFilter.find(name: "$name") == null)
      filter.add(FilterEntry(
          name: name,
          where: where,
          whereArgs: whereArgs,
          firstDate: firstDate,
          lastDate: lastDate,
          isDate: isDate,
          isBool: isBool,
          exact: exact,
          contains: contains,
          begins: begins,
          ends: ends));
    else {
      CategoryFilter.edit(
          name: name,
          where: where,
          whereArgs: whereArgs,
          firstDate: firstDate,
          lastDate: lastDate,
          isDate: isDate,
          isBool: isBool,
          exact: exact,
          contains: contains,
          begins: begins,
          ends: ends);
    }
  }

  //edit a filterEntry by name
  static void edit(
      {String? name,
      String? where,
      String? whereArgs,
      bool isDate = false,
      bool isBool = false,
      String? firstDate,
      String? lastDate,
      bool exact = false,
      bool contains = false,
      bool begins = false,
      bool ends = false}) {
    CategoryFilter.delete(
        entry: filter.singleWhere((element) => element.name == name));
    CategoryFilter.add(
        name: name,
        where: where,
        whereArgs: whereArgs,
        firstDate: firstDate,
        lastDate: lastDate,
        isDate: isDate,
        isBool: isBool,
        exact: exact,
        contains: contains,
        begins: begins,
        ends: ends);
  }

  //find a filterEntry by name
  static FilterEntry? find({String? name}) {
    FilterEntry? found;
    filter.forEach((e) {
      if (e.name == name) {
        found = e;
      }
    });
    return found;
  }

  //delete a filterEntry by name
  static void delete({required FilterEntry? entry}) {
    if (entry != null) filter.remove(entry);
  }

  //delete all filter entries
  static void clear() {
    filter.clear();
  }

  static Map<String, dynamic> get map {
    Map<String, dynamic> filterMap = {"where": null, "whereArgs": null};

    filter.forEach((e) {
      if (e.whereArgs != null) {
        filterMap["where"] ??= "";
        filterMap["whereArgs"] ??= [];
        if (e.exact) {
          filterMap["whereArgs"].add("${e.whereArgs}");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} = ? AND";
        } else if (e.contains) {
          filterMap["whereArgs"].add("%${e.whereArgs}%");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        } else if (e.begins) {
          filterMap["whereArgs"].add("${e.whereArgs}%");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        } else if (e.ends) {
          filterMap["whereArgs"].add("%${e.whereArgs}");
          filterMap["where"] =
              filterMap["where"].toString() + " ${e.where!} LIKE ? AND";
        }
      }
    });

    //removes the comma at the end of the string that causes the
    //sqlite query to return an error
    if (filterMap["where"].toString().endsWith("AND")) {
      filterMap["where"] = filterMap["where"]
          .toString()
          .substring(0, filterMap["where"].toString().length - 3);
    }

    return filterMap;
  }
}

class FilterEntry {
  String? name;
  String? where;
  String? whereArgs;
  String? firstDate;
  String? lastDate;
  bool isDate = false;
  bool isBool = false;

  bool exact = false;
  bool contains = false;
  bool begins = false;
  bool ends = false;

  FilterEntry(
      {this.name,
      this.where,
      this.whereArgs,
      this.firstDate,
      this.lastDate,
      this.isDate = false,
      this.exact = false,
      this.contains = false,
      this.begins = false,
      this.ends = false,
      this.isBool = false});
}
