import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:flutter/material.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dance_club_comuna_8/logic/models/event.dart';

class EventNavigationPage extends StatefulWidget {
  const EventNavigationPage({super.key});

  @override
  EventNavigationPageState createState() => EventNavigationPageState();
}

class EventNavigationPageState extends State<EventNavigationPage> {
  int _selectedIndex = 0;

  // Helper method to build the event list view
  Widget _buildEventListView(List<Event> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text("${event.description} - ${event.date} - ${event.id}"),
          // description and date

          trailing: const Icon(Icons.arrow_forward),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<EventBloc>(context, listen: false).add(
        LoadUpcomingEventsEvent(
            endTime: DateTime.now().add(const Duration(days: 31))));
  }

  @override
  Widget build(BuildContext context) {
    EventBloc eventBloc = BlocProvider.of<EventBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Navigation'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          _buildEventListView(eventBloc.filterEventsForToday()),
          _buildEventListView(eventBloc.filterEventsForTomorrow()),
          _buildEventListView(eventBloc.filterEventsForThisWeek()),
          _buildEventListView(eventBloc.filterUpcomingEvents()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_day),
            label: 'Tomorrow',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_week),
            label: 'This Week',
          ),
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Upcoming',
          ),
        ],
      ),
    );
  }
}
