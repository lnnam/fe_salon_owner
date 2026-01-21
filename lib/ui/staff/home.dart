import 'package:flutter/material.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/staff.dart';
import 'package:salonapp/ui/staff/form.dart';
import 'package:salonapp/constants.dart';
import 'dart:convert';
import 'dart:typed_data';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  List<Staff> _staffList = [];
  List<Staff> _filteredStaff = [];
  bool _loading = true;
  String _search = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final staffList = await apiManager.ListStaff2();
      setState(() {
        _staffList = staffList;
        _filteredStaff = staffList;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _filter(String value) {
    setState(() {
      _search = value;
      _filteredStaff = _staffList.where((s) {
        final q = value.toLowerCase();
        return s.fullname.toLowerCase().contains(q) ||
            s.position.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search staff',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _filter('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text('Error: $_error'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _fetchStaff,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredStaff.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  _search.isEmpty
                                      ? 'No staff found'
                                      : 'No staff matches your search',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _filteredStaff.length,
                            itemBuilder: (context, index) {
                              final staff = _filteredStaff[index];
                              Uint8List? photoBytes;
                              if (staff.photo != 'Unknown' &&
                                  staff.photo.isNotEmpty) {
                                try {
                                  photoBytes = base64Decode(staff.photo);
                                } catch (_) {
                                  photoBytes = null;
                                }
                              }
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    child: (photoBytes == null)
                                        ? Icon(Icons.person,
                                            color: Colors.blue.shade600)
                                        : null,
                                    backgroundImage: (photoBytes != null)
                                        ? MemoryImage(photoBytes)
                                        : null,
                                  ),
                                  title: Text(
                                    staff.fullname,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Text(
                                    staff.position,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Switch(
                                        value: staff.active,
                                        activeColor: const Color(COLOR_PRIMARY),
                                        onChanged: (value) async {
                                          final success =
                                              await apiManager.activateStaff(
                                            staff.staffkey,
                                            value,
                                          );

                                          if (success) {
                                            setState(() {
                                              staff.active = value;
                                              // Update datelastactivated based on switch state
                                              if (value) {
                                                staff.datelastactivated =
                                                    DateTime.now().toString();
                                              } else {
                                                staff.datelastactivated = null;
                                              }
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  value
                                                      ? 'Staff activated'
                                                      : 'Staff deactivated',
                                                ),
                                                duration:
                                                    const Duration(seconds: 2),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Failed to update staff status'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      PopupMenuButton(
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.edit, size: 20),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                            onTap: () {
                                              // TODO: Implement edit functionality
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.delete, size: 20),
                                                SizedBox(width: 8),
                                                Text('Delete'),
                                              ],
                                            ),
                                            onTap: () {
                                              // TODO: Implement delete functionality
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // TODO: Implement view details functionality
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (context) => const StaffFormPage()),
          );
          if (result == true) {
            _fetchStaff();
          }
        },
        tooltip: 'Add Staff',
        child: const Icon(Icons.add),
      ),
    );
  }
}
