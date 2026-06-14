import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../services/storage_service.dart';
import 'password_form_screen.dart';
import 'user_profile.dart';

/// Home Screen consists of different function like list of passwords, search query, and selecting.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Service to handle our local database operations
  final StorageService _storageService = StorageService();

  // State Variables: Changing any of these inside a setState() will rebuild the UI.
  List<PasswordEntry> _passwords = [];
  bool _isLoading = true; // Shows a loading spinner while reading from storage
  int _currentTab = 0; // Tracks if we are on the Home (0) or Profile (1) tab
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isSelecting = false;
  final Set<String> _selectedIds = {}; // 'final' because the Set object itself never changes, only its contents

  @override
  void initState() {
    super.initState();
    // Fetch passwords from the encrypted storage as soon as the screen loads
    _loadPasswords();
  }

  // Asynchronous method to load data without freezing the app UI
  Future<void> _loadPasswords() async {
    final passwords = await _storageService.getPasswords();
    setState(() {
      _passwords = passwords;
      _isLoading = false;
    });
  }

  Future<void> _deleteSelectedPasswords() async {
    for (String id in _selectedIds) {
      await _storageService.deletePassword(id);
    }
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
    _loadPasswords();
  }

  Future<void> _openAddForm() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PasswordFormScreen()),
    );
    _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    final displayedPasswords = _passwords.where((p) {
      return p.siteName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF090D10),
      extendBodyBehindAppBar: true,

      // Dynamic AppBar: Only show it if we are on the Home tab
      appBar: _currentTab == 0
          ? AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Row(
                children: [
                  Icon(Icons.shield, color: Colors.tealAccent, size: 24),
                  SizedBox(width: 10),
                  Text('Vautify', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                ],
              ),
              actions: [
                // Conditional UI: Only show the delete button if items are actually selected
                if (_isSelecting && _selectedIds.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                    onPressed: _deleteSelectedPasswords,
                  ),
                if (_isSelecting)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _isSelecting = false;
                      _selectedIds.clear();
                    }),
                  ),
              ],
            )
          : null,
      
      body: Stack(
        children: [
          // === LAYER 1: AMBIENT DUAL-GLOW BACKGROUND ===
          Positioned(
            top: -150, left: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.tealAccent.withValues(alpha: 0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200, right: -100,
            child: Container(
              width: 500, height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.tealAccent.withValues(alpha: 0.15), Colors.transparent],
                ),
              ),
            ),
          ),

          // === LAYER 1.5: THE SHIELD WATERMARK ===
          Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.2, // Keeps it subtle so text is readable on top
              child: SizedBox(
                height: 300,
                width: 300,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 150, height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.tealAccent.withValues(alpha: 0.6), blurRadius: 60, spreadRadius: 15)
                        ],
                      ),
                    ),
                    Icon(Icons.security, size: 220, color: Colors.grey[400]!.withValues(alpha: 0.5)),
                    Positioned(
                      top: 40, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text('AES-256', style: TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // === LAYER 2: The Main Screen Content ===
          if (_currentTab == 0)
            SafeArea(
              child: Column(
                children: [
                  // --- SEARCH BAR ---
                  if (_isSearching)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search site name...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05), 
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
                          ),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),

                  // --- PASSWORD LIST ---
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
                        : displayedPasswords.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_outline, size: 64, color: Colors.tealAccent),
                                    SizedBox(height: 16),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                                      child: Text(
                                        'No passwords saved yet.\nTap the + button below to add one!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16, color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 120),
                                itemCount: displayedPasswords.length,
                                itemBuilder: (context, index) {
                                  final entry = displayedPasswords[index];
                                  final isSelected = _selectedIds.contains(entry.id);

                                  return Card(
                                    color: isSelected ? Colors.tealAccent.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                                    elevation: 0,
                                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected ? Colors.tealAccent : Colors.white.withValues(alpha: 0.08), 
                                        width: 1
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                      leading: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.lock, color: Colors.tealAccent, size: 20),
                                      ),
                                      title: Text(entry.siteName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                                      subtitle: Text(entry.username, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                                      trailing: _isSelecting 
                                          ? Checkbox(
                                              value: isSelected,
                                              activeColor: Colors.tealAccent,
                                              checkColor: Colors.black,
                                              side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedIds.add(entry.id);
                                                  } else {
                                                    _selectedIds.remove(entry.id);
                                                  }
                                                });
                                              },
                                            )
                                          : const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                                      onTap: () async {
                                        if (_isSelecting) {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedIds.remove(entry.id);
                                            } else {
                                              _selectedIds.add(entry.id);
                                              }
                                          });
                                        } else {
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => PasswordFormScreen(existingEntry: entry)),
                                          );
                                          _loadPasswords();
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            )
          else
            const UserProfile(), 

          // === LAYER 3: Floating Navigation Bar ===
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF090D10).withValues(alpha: 0.9), 
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.home_outlined, color: _currentTab == 0 ? Colors.white : Colors.white38),
                    onPressed: () => setState(() {
                      _currentTab = 0; 
                      _isSelecting = false; 
                      _isSearching = false; 
                    }),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: (_isSearching && _currentTab == 0) ? Colors.white : Colors.white38),
                    onPressed: () => setState(() { 
                      _currentTab = 0; 
                      _isSearching = !_isSearching; 
                      _isSelecting = false; 
                    }),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.tealAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.tealAccent.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black, size: 28),
                      onPressed: _openAddForm,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.checklist, color: (_isSelecting && _currentTab == 0) ? Colors.white : Colors.white38),
                    onPressed: () => setState(() {
                      _currentTab = 0;
                      _isSelecting = !_isSelecting;
                      _isSearching = false;
                      _selectedIds.clear();
                    }),
                  ),
                  IconButton(
                    icon: Icon(Icons.person_outline, color: _currentTab == 1 ? Colors.white : Colors.white38),
                    onPressed: () => setState(() { 
                      _currentTab = 1; 
                      _isSelecting = false; 
                      _isSearching = false; 
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}