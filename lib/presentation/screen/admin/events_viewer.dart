import 'package:dance_club_comuna_8/logic/bloc/event/event_admin_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/logic/models/date_helper.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/attendes_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/event_form/update_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum EventFilter { today, tomorrow, thisWeek, thisMonth, all, past }

class EventsViewerScreen extends StatefulWidget {
  const EventsViewerScreen({super.key});

  @override
  State<EventsViewerScreen> createState() => _EventsViewerScreenState();
}

class _EventsViewerScreenState extends State<EventsViewerScreen> {
  EventFilter filter = EventFilter.today;
  DateTime startDate = DateHelper.startOfToday();
  DateTime endDate = DateHelper.endOfToday();
  bool _isLoadingMore = false;
  bool _isFilterChanging = false; // New state to handle filter changes
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _loadMoreEvents();
    }
  }

  void _loadEvents() {
    BlocProvider.of<EventAdminBloc>(context).add(
      LoadUpcomingEventsEvent(startTime: startDate, endTime: endDate),
    );
  }

  void _loadMoreEvents() {
    final state = BlocProvider.of<EventAdminBloc>(context).state;
    if (state is EventsLoadedState && state.hasMore) {
      setState(() => _isLoadingMore = true);
      BlocProvider.of<EventAdminBloc>(context).add(
        LoadUpcomingEventsEvent(
          startTime: startDate,
          endTime: endDate,
          lastDocument: state.lastDocument,
        ),
      );
    }
  }

  Future<void> _navigateAndRefresh(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    _loadEvents(); // Refresh events when coming back from the navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eventos actuales"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildFilterButtons(context),
          const SizedBox(height: 10),
          Expanded(
            child: BlocConsumer<EventAdminBloc, EventState>(
              listener: (context, state) {
                if (state is EventsLoadedState) {
                  setState(() {
                    _isLoadingMore = false;
                    _isFilterChanging = false; // Reset after loading completes
                  });
                }
              },
              builder: (context, state) {
                final eventBloc = BlocProvider.of<EventAdminBloc>(context);

                if (_isFilterChanging) {
                  // Show loading spinner when filter is changing
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EventLoadingState &&
                    eventBloc.allEvents.isEmpty) {
                  // Show a full-screen loader only if no events are loaded yet
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EventsLoadedState) {
                  // Build the list and handle loading at the end of the list
                  return _buildEventList(state);
                } else if (state is EventErrorState) {
                  return Center(child: Text(state.message));
                } else {
                  // If events are already loaded and we're loading more, use the allEvents list
                  return _buildEventList(EventsLoadedState(
                    eventBloc.allEvents,
                    hasMore:
                        true, // Assume true to allow for infinite scrolling
                    lastDocument:
                        null, // Pass null or the correct value based on your logic
                  ));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: EventFilter.values.map((eventFilter) {
        return ElevatedButton.icon(
          onPressed: filter == eventFilter
              ? null
              : () => _onFilterSelected(eventFilter),
          icon: Icon(_getIconForFilter(eventFilter)),
          label: Text(_getLabelForFilter(eventFilter)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: filter == eventFilter ? Colors.grey : null,
          ),
        );
      }).toList(),
    );
  }

  void _onFilterSelected(EventFilter eventFilter) {
    setState(() {
      _isFilterChanging = true; // Set filter changing state
      filter = eventFilter;
      switch (filter) {
        case EventFilter.today:
          startDate = DateHelper.startOfToday();
          endDate = DateHelper.endOfToday();
          break;
        case EventFilter.tomorrow:
          startDate = DateHelper.startOfTomorrow();
          endDate = DateHelper.endOfTomorrow();
          break;
        case EventFilter.thisWeek:
          startDate = DateHelper.startOfThisWeek();
          endDate = DateHelper.endOfThisWeek();
          break;
        case EventFilter.thisMonth:
          startDate = DateHelper.startOfThisMonth();
          endDate = DateHelper.endOfThisMonth();
          break;
        case EventFilter.all:
          startDate = DateHelper.startOfAll();
          endDate = DateHelper.endOfAll();
          break;
        case EventFilter.past:
          startDate = DateHelper.past();
          endDate = DateHelper.startOfToday();
          break;
      }
      _loadEvents();
    });
  }

  Widget _buildEventList(EventsLoadedState state) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: state.events.length +
          (_isLoadingMore ? 1 : 0), // Add extra item if loading more
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        if (index < state.events.length) {
          final event = state.events[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(event.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "${event.date.day}/${event.date.month}/${event.date.year} - ${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}"),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 4),
                      Text("${event.attendes}/${event.maxAttendees}"),
                    ],
                  ),
                ],
              ),
              trailing: _buildTrailingIcons(context, event),
            ),
          );
        } else {
          // Show a loading indicator at the bottom
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildTrailingIcons(BuildContext context, Event event) {
    return Wrap(
      spacing: 8.0,
      children: [
        IconButton(
          onPressed: () => _navigateAndRefresh(
            context,
            UpdateEventScreen(eventId: event.id),
          ),
          icon: const Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () => _navigateAndRefresh(
            context,
            AttendeesScreen(eventId: event.id),
          ),
          icon: const Icon(Icons.people),
        ),
        IconButton(
          onPressed: () => _showDeleteConfirmationDialog(context, event),
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false; // To manage loading state

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Eliminar evento"),
            content: isLoading
                ? const CircularProgressIndicator()
                : const Text("¿Está seguro que desea eliminar este evento?"),
            actions: isLoading
                ? []
                : [
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true; // Show loading spinner
                        });

                        final success = await removeEvent(context, event);

                        setState(() {
                          isLoading = false; // Hide loading spinner
                        });

                        Navigator.pop(context); // Close the dialog

                        // Show snackbar with result
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Evento "${event.title}" (ID: ${event.id}) eliminado exitosamente.'
                                : 'Error al eliminar el evento "${event.title}" (ID: ${event.id}).'),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ),
                        );
                      },
                      child: const Text("Sí"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("No"),
                    ),
                  ],
          ),
        );
      },
    );
  }

  Future<bool> removeEvent(BuildContext context, Event event) async {
    try {
      BlocProvider.of<EventAdminBloc>(context)
          .add(DeleteEventEvent(id: event.id));
      await Future.delayed(const Duration(seconds: 3)); // Simulate a delay
      _loadEvents(); // Reload events after deletion

      return true; // Return success
    } catch (e) {
      return false; // Return failure if an error occurs
    }
  }

  IconData _getIconForFilter(EventFilter filter) {
    switch (filter) {
      case EventFilter.today:
        return Icons.calendar_view_day;
      case EventFilter.tomorrow:
        return Icons.keyboard_tab;
      case EventFilter.thisWeek:
        return Icons.calendar_view_week;
      case EventFilter.thisMonth:
        return Icons.calendar_view_month;
      case EventFilter.all:
        return Icons.calendar_today;
      case EventFilter.past:
        return Icons.history;
      default:
        return Icons.calendar_today;
    }
  }

  String _getLabelForFilter(EventFilter filter) {
    switch (filter) {
      case EventFilter.today:
        return 'Hoy';
      case EventFilter.tomorrow:
        return 'Mañana';
      case EventFilter.thisWeek:
        return 'Esta semana';
      case EventFilter.thisMonth:
        return 'Este mes';
      case EventFilter.all:
        return 'Todos';
      case EventFilter.past:
        return 'Pasados';
      default:
        return '';
    }
  }
}
