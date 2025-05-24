import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:waiter/Controllers/api_service.dart';

import 'order_view_page.dart';

class Table {
  final int id;
  final int restaurantId;
  final String tableNumber;
  final int chairCount;
  final String? positionCode;
  final int seatsUsed;
  final bool isAc;
  final bool isActive;
  final List<bool> selectedChairs; // Add this line

  Table({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.chairCount,
    this.positionCode,
    required this.seatsUsed,
    required this.isAc,
    required this.isActive,
    List<bool>? selectedChairs, // Add this parameter
  }) : selectedChairs = selectedChairs ?? List.filled(chairCount, false);

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'] as int,
      restaurantId: json['restaurant_id'] as int,
      tableNumber: json['table_number'] as String,
      chairCount: json['chair'] as int,
      positionCode: json['position_code'] as String?,
      seatsUsed: (json['seats_used'] as int?) ?? 0,
      isAc: (json['is_ac'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      selectedChairs: json['selected_chairs'] != null
          ? List<bool>.from(json['selected_chairs'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'table_number': tableNumber,
      'chair': chairCount,
      'position_code': positionCode,
      'seats_used': seatsUsed,
      'is_ac': isAc ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'selected_chairs': selectedChairs, // Add this line
    };
  }

  Table copyWith({
    int? id,
    int? restaurantId,
    String? tableNumber,
    int? chairCount,
    String? positionCode,
    int? seatsUsed,
    bool? isAc,
    bool? isActive,
    List<bool>? selectedChairs, // Add this parameter
  }) {
    return Table(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      tableNumber: tableNumber ?? this.tableNumber,
      chairCount: chairCount ?? this.chairCount,
      positionCode: positionCode ?? this.positionCode,
      seatsUsed: seatsUsed ?? this.seatsUsed,
      isAc: isAc ?? this.isAc,
      isActive: isActive ?? this.isActive,
      selectedChairs: selectedChairs ?? this.selectedChairs, // Add this line
    );
  }
}

class TableService {
  static final Logger _logger = Logger();
  Future<List<Table>> getTables() async {
    try {
      final response =
          await ApiService.getAuthenticatedRequest('table?limit=100');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonData['data'] is! List) {
          throw Exception('Invalid response format: data is not a list');
        }

        return (jsonData['data'] as List)
            .map((t) => Table.fromJson(t))
            .toList();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.e('Failed to fetch tables', error: e);
      rethrow;
    }
  }

  Future<Table> updateTable({
    required int tableId,
    required String tableNumber,
    required int chairCount,
    String? positionCode,
    required bool isAc,
    int? seatsUsed,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        '_method': 'PATCH',
        'table_number': tableNumber,
        'chair': chairCount,
        'position_code': positionCode,
        'is_ac': isAc ? 1 : 0,
      };

      if (seatsUsed != null) {
        requestBody['seats_used'] = seatsUsed;
      }

      final response = await ApiService.postAuthenticatedRequest(
        'table/$tableId',
        requestBody,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return Table.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to update table: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error updating table', error: e);
      rethrow;
    }
  }




  Future<Table> createTable({
    required String tableNumber,
    required int chairCount,
    String? positionCode,
    required bool isAc,
  }) async {
    try {
      final response = await ApiService.postAuthenticatedRequest(
        'table',
        {
          'table_number': tableNumber,
          'chair': chairCount,
          'position_code': positionCode,
          'is_ac': isAc ? 1 : 0,
          'seats_used': 0,
        },
      );

      _logger.d('Create table response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonData['data'] != null) {
          return Table.fromJson(jsonData['data']);
        }
        throw Exception('Invalid response format: missing data field');
      } else if (response.statusCode == 422) {
        // Handle validation errors
        final errors = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception('Validation errors: ${errors['errors']}');
      } else {
        throw Exception('Failed to create table: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.e('Error creating table', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }


  Future<bool> deleteTable(int tableId) async {
    try {
      final response = await ApiService.postAuthenticatedRequest(
        'table/$tableId',
        {'_method': 'DELETE'},
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error deleting table', error: e);
      rethrow;
    }
  }
}

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  final TableService _tableService = TableService();
  List<Table> _tables = [];
  bool _isLoading = false;
  bool _showAcSection = true;
  Table? _selectedTable;
  bool _showActionButtons = false;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() => _isLoading = true);
    try {
      final tables = await _tableService.getTables();
      setState(() => _tables = tables);
    } catch (e) {
      _showErrorSnackbar('Failed to load tables');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleTableTap(Table table) {
    setState(() {
      _selectedTable = table;
      _showActionButtons = true;
    });
  }

  Future<void> _confirmTableAction(Table table, String action) async {
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Table'),
          content: Text('Delete Table #${table.tableNumber} permanently?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _isLoading = true);
      try {
        await _tableService.deleteTable(table.id);
        setState(() {
          _tables.removeWhere((t) => t.id == table.id);
          _selectedTable = null;
          _showActionButtons = false;
        });
        _showSuccessSnackbar('Table deleted');
      } catch (e) {
        _showErrorSnackbar('Failed to delete table');
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (action == 'book') {
      _navigateToBookingScreen(table);
    } else if (action == 'edit') {
      _showEditTableDialog(table);
    }
  }

  Future<void> _showEditTableDialog(Table table) async {
    final _formKey = GlobalKey<FormState>();
    final _tableNumberController =
        TextEditingController(text: table.tableNumber);
    final _chairCountController =
        TextEditingController(text: table.chairCount.toString());
    final _positionCodeController =
        TextEditingController(text: table.positionCode);
    bool _isAc = table.isAc;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Table'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _tableNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Table Number'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _chairCountController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Chair Count'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final num = int.tryParse(value);
                        if (num == null) return 'Invalid number';
                        if (num < 1 || num > 10) return '1-10 chairs only';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _positionCodeController,
                      decoration: const InputDecoration(
                          labelText: 'Position Code (Optional)'),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('AC Table'),
                      value: _isAc,
                      onChanged: (value) => setState(() => _isAc = value),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final updatedTable = await _tableService.updateTable(
        tableId: table.id,
        tableNumber: _tableNumberController.text,
        chairCount: int.parse(_chairCountController.text),
        positionCode: _positionCodeController.text.isEmpty
            ? null
            : _positionCodeController.text,
        isAc: _isAc,
      );

      setState(() {
        _tables =
            _tables.map((t) => t.id == table.id ? updatedTable : t).toList();
        _selectedTable = updatedTable;
        _showActionButtons = true;
      });
      _showSuccessSnackbar('Table updated');
    } catch (e) {
      _showErrorSnackbar('Failed to update table');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToBookingScreen(Table table) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          table: table,
          onTableBooked: (bookedTable) async {
            setState(() => _isLoading = true);
            try {
              final updatedTable = await _tableService.updateTable(
                tableId: bookedTable.id,
                tableNumber: bookedTable.tableNumber,
                chairCount: bookedTable.chairCount,
                positionCode: bookedTable.positionCode,
                isAc: bookedTable.isAc,
                seatsUsed: bookedTable.selectedChairs.where((s) => s).length,
              );

              setState(() {
                _tables = _tables
                    .map((t) => t.id == bookedTable.id ? updatedTable : t)
                    .toList();
                _selectedTable = null;
                _showActionButtons = false;
              });
            } catch (e) {
              _showErrorSnackbar('Failed to update table status');
            } finally {
              setState(() => _isLoading = false);
            }
          },
        ),
      ),
    );
  }

  Future<void> _showAddTableDialog() async {
    final _formKey = GlobalKey<FormState>();
    final _tableNumberController = TextEditingController();
    final _chairCountController = TextEditingController();
    final _positionCodeController = TextEditingController();
    bool _isAc = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Table'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _tableNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Table Number'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _chairCountController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Chair Count'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final num = int.tryParse(value);
                        if (num == null) return 'Invalid number';
                        if (num < 1 || num > 10) return '1-10 chairs only';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _positionCodeController,
                      decoration: const InputDecoration(
                          labelText: 'Position Code (Optional)'),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('AC Table'),
                      value: _isAc,
                      onChanged: (value) => setState(() => _isAc = value),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final newTable = await _tableService.createTable(
        tableNumber: _tableNumberController.text,
        chairCount: int.parse(_chairCountController.text),
        positionCode: _positionCodeController.text.isEmpty
            ? null
            : _positionCodeController.text,
        isAc: _isAc,
      );
      setState(() => _tables.add(newTable));
      _showSuccessSnackbar('Table added');
    } catch (e) {
      _showErrorSnackbar('Failed to add table');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Table> filteredTables =
        _tables.where((table) => table.isAc == _showAcSection).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSectionSelector(),
          if (_showActionButtons && _selectedTable != null)
            _buildActionButtons(),
          Expanded(
            child: _buildContentArea(filteredTables),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // AppBar _buildAppBar() {
  //   return AppBar(
  //     title: Text(
  //       'Table Management',
  //       style: GoogleFonts.poppins(
  //         fontWeight: FontWeight.w600,
  //         fontSize: 22,
  //         color: Colors.white,
  //       ),
  //     ),
  //     centerTitle: true,
  //     elevation: 0,
  //     flexibleSpace: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [Colors.blue[700]!, Colors.blue[500]!],
  //         ),
  //       ),
  //     ),
  //     actions: [
  //       IconButton(
  //         icon: Icon(Icons.refresh, color: Colors.white),
  //         onPressed: _isLoading ? null : _loadTables,
  //         tooltip: 'Refresh Tables',
  //       ),
  //     ],
  //   );
  // }
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Table Management',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[700]!, Colors.blue[500]!],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.receipt_long, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderViewPage()),
            );
          },
          tooltip: 'View Orders',
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: _isLoading ? null : _loadTables,
          tooltip: 'Refresh Tables',
        ),
      ],
    );
  }
  Widget _buildSectionSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSectionButton(
            icon: FontAwesomeIcons.snowflake,
            label: 'AC Section',
            isSelected: _showAcSection,
            onTap: () => _setSection(true),
          ),
          _buildSectionButton(
            icon: FontAwesomeIcons.fan,
            label: 'Non-AC Section',
            isSelected: !_showAcSection,
            onTap: () => _setSection(false),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.blue[600] : Colors.grey[500],
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.blue[600] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit',
            color: Colors.blue,
            onPressed: () => _confirmTableAction(_selectedTable!, 'edit'),
          ),
          _buildActionButton(
            icon: FontAwesomeIcons.calendarCheck,
            label: 'Book',
            color: Colors.green,
            onPressed: () => _confirmTableAction(_selectedTable!, 'book'),
          ),
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: Colors.red,
            isDestructive: true,
            onPressed: () => _confirmTableAction(_selectedTable!, 'delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(List<Table> filteredTables) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _isLoading
          ? _buildLoadingIndicator()
          : filteredTables.isEmpty
              ? _buildEmptyState()
              : _buildFloorPlan(filteredTables),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading Tables...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant,
            size: 64,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'No ${_showAcSection ? 'AC' : 'Non-AC'} tables found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add a new table',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorPlan(List<Table> filteredTables) {
    return RestaurantFloorPlan(
      tables: filteredTables,
      selectedTableId: _selectedTable?.id,
      onTableTap: _handleTableTap,
      onTablePositionChanged: (updatedTable) {
        setState(() {
          _tables = _tables
              .map((t) => t.id == updatedTable.id ? updatedTable : t)
              .toList();
        });
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _isLoading ? null : _showAddTableDialog,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.add, size: 28),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: label,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setSection(bool isAc) {
    setState(() {
      _showAcSection = isAc;
      _selectedTable = null;
      _showActionButtons = false;
    });
  }
}

class RestaurantFloorPlan extends StatefulWidget {
  final List<Table> tables;
  final int? selectedTableId;
  final Function(Table) onTableTap;
  final Function(Table) onTablePositionChanged;

  const RestaurantFloorPlan({
    super.key,
    required this.tables,
    this.selectedTableId,
    required this.onTableTap,
    required this.onTablePositionChanged,
  });

  @override
  State<RestaurantFloorPlan> createState() => _RestaurantFloorPlanState();
}

class _RestaurantFloorPlanState extends State<RestaurantFloorPlan> {
  final TableService _tableService = TableService();
  int? _draggingTableId;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int gridColumns = screenWidth > 1000 ? 4 : (screenWidth > 600 ? 3 : 2);

    return SingleChildScrollView(
      child: Container(
        height: 1200, // Set your desired height here
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Grid background
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridColumns,
                childAspectRatio: 1.2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: widget.tables.length,
              itemBuilder: (context, index) {
                return Container();
              },
            ),
            // Draggable tables
            ...widget.tables.map((table) {
              return RestaurantTable(
                key: ValueKey(table.id),
                table: table,
                isSelected: table.id == widget.selectedTableId,
                isDragging: table.id == _draggingTableId,
                onTap: (updatedTable) {
                  widget.onTableTap(updatedTable);
                },
                onDragStarted: () {
                  setState(() => _draggingTableId = table.id);
                },
                onDragEnded: (newPosition) async {
                  final updatedTable = await _tableService.updateTable(
                    tableId: table.id,
                    tableNumber: table.tableNumber,
                    chairCount: table.chairCount,
                    positionCode: newPosition,
                    isAc: table.isAc,
                  );
                  widget.onTablePositionChanged(updatedTable);
                  setState(() => _draggingTableId = null);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class RestaurantTable extends StatefulWidget {
  final Table table;
  final bool isSelected;
  final bool isDragging;
  final Function(Table) onTap; // Changed to pass the updated table
  final VoidCallback onDragStarted;
  final Function(String) onDragEnded;

  const RestaurantTable({
    super.key,
    required this.table,
    this.isSelected = false,
    this.isDragging = false,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  @override
  State<RestaurantTable> createState() => _RestaurantTableState();
}

class _RestaurantTableState extends State<RestaurantTable> {
  late Table _currentTable;
  double top = 0;
  double left = 0;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentTable = widget.table;
    // Parse initial position from positionCode if available
    if (widget.table.positionCode != null) {
      final parts = widget.table.positionCode!.split(',');
      if (parts.length == 2) {
        left = double.tryParse(parts[0]) ?? 0;
        top = double.tryParse(parts[1]) ?? 0;
      }
    }
  }

  void _handleChairTap(int chairIndex) {
    setState(() {
      _currentTable = _currentTable.copyWith(
        selectedChairs: List.from(_currentTable.selectedChairs)
          ..[chairIndex] = !_currentTable.selectedChairs[chairIndex],
      );
    });
    widget.onTap(_currentTable);
  }

  @override
  Widget build(BuildContext context) {
    final tableSize = _calculateTableSize(_currentTable.chairCount);
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanStart: (details) {
          widget.onDragStarted();
          setState(() => isDragging = true);
        },
        onPanUpdate: (details) {
          setState(() {
            left += details.delta.dx;
            top += details.delta.dy;
          });
        },
        onPanEnd: (details) {
          setState(() => isDragging = false);
          widget.onDragEnded('$left,$top');
        },
        child: AbsorbPointer(
          absorbing: isDragging,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Table with chairs
                Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      children: [
                        // Table
                        Container(
                          decoration: BoxDecoration(
                            color: _currentTable.seatsUsed > 0
                                ? Colors.red[300]
                                : Colors.brown[300],
                            borderRadius: BorderRadius.circular(12),
                            border:
                            Border.all(color: Colors.brown[600]!, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              _currentTable.tableNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        // Chairs with tap handling
                        ..._buildChairs(_currentTable.chairCount),
                      ],
                    ),
                  ),
                ),
                // Table info at bottom
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Text(
                      //   '${_currentTable.chairCount} ${_currentTable.chairCount == 1 ? 'Chair' : 'Chairs'}',
                      //   style: const TextStyle(fontWeight: FontWeight.bold),
                      // ),
                      // if (_currentTable.isAc)
                      //   const Icon(Icons.ac_unit, size: 16),
                      if (_currentTable.seatsUsed > 0)
                        Text(
                          '${_currentTable.seatsUsed} occupied',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateTableSize(int chairCount) {
    if (chairCount <= 2) return 20;
    if (chairCount <= 4) return 100;
    if (chairCount <= 6) return 120;
    if (chairCount <= 8) return 140;
    return 160; // for more than 8 chairs
  }

  List<Widget> _buildChairs(int count) {
    List<Widget> chairs = [];
    const double chairSize = 20;
    const double tableSize = 120;
    const double chairOffset = 4;

    int chairsPerSide = (count / 4).ceil();
    if (chairsPerSide == 0) chairsPerSide = 1;
    double spacing = (tableSize - chairSize) / (chairsPerSide + 1);

    // Top chairs
    for (int i = 0; i < chairsPerSide && chairs.length < count; i++) {
      final chairIndex = chairs.length;
      chairs.add(Positioned(
        top: chairOffset,
        left: spacing * (i + 1) - chairSize / 2,
        child: GestureDetector(
          onTap: () => _handleChairTap(chairIndex),
          child: _buildChair(chairIndex),
        ),
      ));
    }

    // Right chairs
    for (int i = 0; i < chairsPerSide && chairs.length < count; i++) {
      final chairIndex = chairs.length;
      chairs.add(Positioned(
        right: chairOffset,
        top: spacing * (i + 1) - chairSize / 2,
        child: GestureDetector(
          onTap: () => _handleChairTap(chairIndex),
          child: Transform.rotate(angle: 1.57, child: _buildChair(chairIndex)),
        ),
      ));
    }

    // Bottom chairs
    for (int i = 0; i < chairsPerSide && chairs.length < count; i++) {
      final chairIndex = chairs.length;
      chairs.add(Positioned(
        bottom: chairOffset,
        left: spacing * (i + 1) - chairSize / 2,
        child: GestureDetector(
          onTap: () => _handleChairTap(chairIndex),
          child: Transform.rotate(angle: 3.14, child: _buildChair(chairIndex)),
        ),
      ));
    }

    // Left chairs
    for (int i = 0; i < chairsPerSide && chairs.length < count; i++) {
      final chairIndex = chairs.length;
      chairs.add(Positioned(
        left: chairOffset,
        top: spacing * (i + 1) - chairSize / 2,
        child: GestureDetector(
          onTap: () => _handleChairTap(chairIndex),
          child: Transform.rotate(angle: 4.71, child: _buildChair(chairIndex)),
        ),
      ));
    }

    return chairs;
  }

  Widget _buildChair(int index) {
    final isSelected = _currentTable.selectedChairs[index];
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? Colors.blue[800]! : Colors.grey[600]!,
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 6,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[800] : Colors.grey[600],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class BookingScreen extends StatelessWidget {
  final Table table;
  final Function(Table) onTableBooked;

  const BookingScreen({
    super.key,
    required this.table,
    required this.onTableBooked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedChairCount = table.selectedChairs.where((s) => s).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Table #${table.tableNumber}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      // Table visualization
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: colorScheme.surfaceVariant,
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            // Table with chairs
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Table
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.brown[400],
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.brown.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.brown[600]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        table.tableNumber,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                          shadows: [
                                            Shadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 2,
                                              offset: const Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Chairs
                                  ..._buildChairsWithSelection(table),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Selected chairs information
                            if (selectedChairCount > 0)
                              Text(
                                '$selectedChairCount ${selectedChairCount == 1 ? 'chair' : 'chairs'} selected',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            // Table details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.table_restaurant,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Table #${table.tableNumber}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chair,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${table.chairCount} ${table.chairCount == 1 ? 'Seat' : 'Seats'}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            if (table.isAc) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.ac_unit,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Air Conditioned',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Booking information
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        Icons.calendar_today,
                        'Date',
                        'Today, ${DateFormat('MMM dd').format(DateTime.now())}',
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        context,
                        Icons.access_time,
                        'Time',
                        DateFormat('hh:mm a').format(DateTime.now()),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        context,
                        Icons.chair,
                        'Selected Chairs',
                        '${table.selectedChairs.where((s) => s).length} chairs selected',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onTableBooked(table.copyWith(seatsUsed: 1));
                    Navigator.pushNamed(
                      context,
                      '/TodaysMenuScreen',
                      arguments: {
                        'tableId': table.id,
                        'tableNumber': table.tableNumber,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Confirm Booking',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildChairsWithSelection(Table table) {
    List<Widget> chairs = [];
    const double chairSize = 1;
    const double tableSize = 120;
    const double chairOffset = 2;

    int chairsPerSide = (table.chairCount / 4).ceil();
    if (chairsPerSide == 0) chairsPerSide = 1;
    double spacing = (tableSize - chairSize) / (chairsPerSide + 1);

    // Top chairs
    for (int i = 0;
        i < chairsPerSide && chairs.length < table.chairCount;
        i++) {
      final chairIndex = chairs.length;
      chairs.add(Positioned(
        top: -chairSize / 2,
        left: tableSize / 2 + spacing * (i + 1) - (chairsPerSide * spacing) / 2,
        child: _buildChair(table.selectedChairs[chairIndex]),
      ));
    }

    // Right chairs
    for (int i = 0;
        i < chairsPerSide && chairs.length < table.chairCount;
        i++) {
      final chairIndex = chairs.length;
      chairs.add(Positioned(
        right: -chairSize / 2,
        top: tableSize / 2 + spacing * (i + 1) - (chairsPerSide * spacing) / 2,
        child: Transform.rotate(
            angle: 1.57, child: _buildChair(table.selectedChairs[chairIndex])),
      ));
    }

    // Bottom chairs
    for (int i = 0;
        i < chairsPerSide && chairs.length < table.chairCount;
        i++) {
      final chairIndex = chairs.length;
      chairs.add(Positioned(
        bottom: -chairSize / 2,
        left: tableSize / 2 + spacing * (i + 1) - (chairsPerSide * spacing) / 2,
        child: Transform.rotate(
            angle: 3.14, child: _buildChair(table.selectedChairs[chairIndex])),
      ));
    }

    // Left chairs
    for (int i = 0;
        i < chairsPerSide && chairs.length < table.chairCount;
        i++) {
      final chairIndex = chairs.length;
      chairs.add(Positioned(
        left: -chairSize / 2,
        top: tableSize / 2 + spacing * (i + 1) - (chairsPerSide * spacing) / 2,
        child: Transform.rotate(
            angle: 4.71, child: _buildChair(table.selectedChairs[chairIndex])),
      ));
    }

    return chairs;
  }

  Widget _buildChair(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? Colors.blue[800]! : Colors.grey[500]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 8,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[800] : Colors.grey[500],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
