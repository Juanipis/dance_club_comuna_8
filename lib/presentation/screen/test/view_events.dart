import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
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
          trailing: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterEvent(eventId: event.id),
                ),
              );
            },
            child: const Icon(Icons.arrow_forward),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<EventBloc>(context, listen: false)
        .add(LoadUpcomingEventsEvent(
            startTime: DateTime.now(), //TODO: Change to real date
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

class RegisterEvent extends StatefulWidget {
  final String eventId;

  const RegisterEvent({super.key, required this.eventId});

  @override
  State<StatefulWidget> createState() => _RegisterEventState();
}

class _RegisterEventState extends State<RegisterEvent> {
  final TextEditingController phoneNumber = TextEditingController();
  late EventBloc eventBloc;

  @override
  void initState() {
    super.initState();
    eventBloc = BlocProvider.of<EventBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is UserRegisteredState) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Registration Successful'),
              content: const Text('You have been successfully registered.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else if (state is EventErrorState) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Registration Failed'),
              content: Text(state.message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Registering for event...'),
              Text('Event ID: ${widget.eventId}'),
              TextField(
                controller: phoneNumber,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              ElevatedButton(
                onPressed: () {
                  eventBloc.add(RegisterUserEvent(
                      eventId: widget.eventId,
                      phoneNumber: phoneNumber.text,
                      name: "test"));
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
