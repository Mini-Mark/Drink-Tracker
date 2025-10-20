import 'package:drinktracker/data_json/drinks_json.dart';
import 'package:drinktracker/providers/app_state.dart';
import 'package:drinktracker/services/utils_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MainHistory extends StatefulWidget {
  const MainHistory({Key? key}) : super(key: key);

  @override
  State<MainHistory> createState() => _MainHistoryState();
}

class _MainHistoryState extends State<MainHistory> {
  final Set<String> _selectedEntries = {};
  bool _isSelectionMode = false;

  void _toggleSelection(String entryId) {
    setState(() {
      if (_selectedEntries.contains(entryId)) {
        _selectedEntries.remove(entryId);
      } else {
        _selectedEntries.add(entryId);
      }
    });
  }

  void _enterSelectionMode(String entryId) {
    setState(() {
      _isSelectionMode = true;
      _selectedEntries.add(entryId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedEntries.clear();
    });
  }

  Future<void> _deleteSelectedEntries(AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entries'),
          content: Text(
              'Are you sure you want to delete ${_selectedEntries.length} drink ${_selectedEntries.length == 1 ? 'entry' : 'entries'}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      for (final entryId in _selectedEntries) {
        await appState.deleteDrinkEntry(entryId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_selectedEntries.length} ${_selectedEntries.length == 1 ? 'entry' : 'entries'} deleted'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _exitSelectionMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final appState = Provider.of<AppState>(context);
    final drinkEntries = appState.drinkEntries;

    return Stack(
      children: [
        SafeArea(
          child: Scrollbar(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 38,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "History",
                            style: TextStyle(
                                fontSize: title_lg,
                                fontWeight: FontWeight.bold,
                                color: light_secondary),
                          ),
                          if (_isSelectionMode)
                            IconButton(
                              icon: const Icon(Icons.close, color: dark),
                              onPressed: _exitSelectionMode,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    drinkEntries.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              "No drink entries yet. Start tracking your water intake!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: text_md,
                                color: dark,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _getUniqueDateCount(drinkEntries),
                                itemBuilder: (context, index) {
                                  final uniqueDates =
                                      _getUniqueDates(drinkEntries);
                                  final currentDate = DateTime.now();
                                  final itemDate = uniqueDates[index];
                                  final difference =
                                      currentDate.difference(itemDate).inDays;

                                  String dateLabel = '';

                                  if (difference == 0) {
                                    dateLabel = 'Today';
                                  } else if (difference == 1) {
                                    dateLabel = 'Yesterday';
                                  } else {
                                    dateLabel = DateFormat("MM/dd/yyyy")
                                        .format(itemDate);
                                  }

                                  final itemsForDate =
                                      drinkEntries.where((entry) {
                                    final entryDate = DateFormat('yyyy-MM-dd')
                                        .parse(entry.date);
                                    return entryDate.year == itemDate.year &&
                                        entryDate.month == itemDate.month &&
                                        entryDate.day == itemDate.day;
                                  }).toList();

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: index == 0 ? 0 : 20,
                                            bottom: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              dateLabel,
                                              style: const TextStyle(
                                                fontSize: title_md,
                                                fontWeight: FontWeight.bold,
                                                color: light_secondary,
                                              ),
                                            ),
                                            if (!_isSelectionMode)
                                              const Row(
                                                children: [
                                                  Text(
                                                    "hold to select",
                                                    style: TextStyle(
                                                        fontSize: text_sm,
                                                        color: black),
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Icon(
                                                    Icons.touch_app,
                                                    color: dark,
                                                  )
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width,
                                        child: ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: itemsForDate.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, entryIndex) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: _historyCard(
                                                  context,
                                                  itemsForDate[entryIndex],
                                                  appState,
                                                  _isSelectionMode,
                                                  _selectedEntries.contains(
                                                      itemsForDate[entryIndex]
                                                          .id)),
                                            );
                                          },
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ],
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isSelectionMode && _selectedEntries.isNotEmpty)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => _deleteSelectedEntries(appState),
              backgroundColor: danger,
              child: const Icon(Icons.delete, color: white),
            ),
          ),
      ],
    );
  }

  int _getUniqueDateCount(List drinkEntries) {
    final uniqueDates = _getUniqueDates(drinkEntries);
    return uniqueDates.length;
  }

  List<DateTime> _getUniqueDates(List drinkEntries) {
    final dateSet = <DateTime>{};
    for (var entry in drinkEntries) {
      final entryDate = DateFormat('yyyy-MM-dd').parse(entry.date);
      final dateOnly = DateTime(entryDate.year, entryDate.month, entryDate.day);
      dateSet.add(dateOnly);
    }
    // Sort in reverse chronological order (newest first)
    return dateSet.toList()..sort((a, b) => b.compareTo(a));
  }

  Widget _historyCard(context, entry, AppState appState, bool isSelectionMode,
      bool isSelected) {
    // Lookup drink data from drinkLists
    final drinkData = drinkLists.firstWhere(
      (drink) => drink['id'] == entry.drinkId,
      orElse: () => {
        'id': entry.drinkId,
        'name': 'Unknown Drink',
        'icon': Icons.local_drink,
      },
    );

    // Format timestamp for display
    final timeString = DateFormat('HH:mm').format(entry.timestamp);
    final dateString = DateFormat('MM/dd/yyyy').format(entry.timestamp);

    return Slidable(
        enabled: !isSelectionMode,
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            const SlidableAction(
              onPressed: null,
              backgroundColor: Colors.transparent,
              label: '',
            ),
            SlidableAction(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                onPressed: (context) async {
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Entry'),
                        content: const Text(
                            'Are you sure you want to delete this drink entry?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed == true) {
                    await appState.deleteDrinkEntry(entry.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Drink entry deleted'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                backgroundColor: danger,
                foregroundColor: white,
                icon: Icons.delete,
                label: 'Delete',
                flex: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: success, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: primary.withAlpha(30),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    isSelectionMode ? () => _toggleSelection(entry.id) : null,
                onLongPress: !isSelectionMode
                    ? () => _enterSelectionMode(entry.id)
                    : null,
                splashColor: primary.withAlpha(100),
                highlightColor: primary.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    if (isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected ? success : grey,
                          size: 20,
                        ),
                      ),
                    Expanded(
                      child: ListTile(
                        leading: Icon(
                          drinkData["icon"],
                          size: 40,
                          color: drinkData["color"] != null
                              ? UtilsService().hexToColor(drinkData["color"])
                              : dark,
                        ),
                        tileColor: Colors.transparent,
                        textColor: dark,
                        iconColor: drinkData["color"] != null
                            ? UtilsService().hexToColor(drinkData["color"])
                            : dark,
                        title: Text(
                          drinkData['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: title_md),
                        ),
                        subtitle: Text(
                          "${entry.mlAmount}ml",
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              timeString,
                              style: TextStyle(color: dark.withAlpha(100)),
                            ),
                            Text(
                              dateString,
                              style: TextStyle(color: dark.withAlpha(100)),
                            ),
                          ],
                        ),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
