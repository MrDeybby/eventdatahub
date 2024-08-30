# EventDataHub

EventDataHub is a comprehensive database system designed to efficiently manage data related to events, locations, tickets, entries, organizers, and participants for concerts and festivals. This database aims to centralize and organize all the essential information required for event management, streamlining planning, coordination, and resource allocation.

## 🎯 Purpose

The main goal of EventDataHub is to provide a robust platform for event organizers and ticket sales companies to manage all aspects of event administration. The system helps optimize resource allocation, manage ticket availability, and ensure smooth coordination of participants, enhancing overall event management efficiency.

## 👥 End Users

- **Event Organizers**: Create and manage events, assign participants (artists, presenters, etc.), and track ticket availability and status. Organizers can also monitor event performance and generate detailed reports on attendance and sales.
  
- **Ticket Sales Companies**: Manage ticket sales, update ticket statuses (e.g., active, used), and ensure ticket availability is always accurate. They can also generate sales reports and handle returns or exchanges.

## 🏗️ Design Overview

The database is structured with several interconnected tables that represent key entities:

- **Events**: Stores information about the events being organized.
- **Locations**: Contains data on where events are held, including capacity and seating.
- **Tickets**: Manages different types of tickets available for events.
- **Entries**: Tracks tickets purchased by attendees and their current status.
- **Organizers**: Maintains information about event organizers and their roles.
- **Participants**: Stores details about artists, speakers, and other participants involved in events.

The architecture includes both one-to-many and many-to-many relationships, with indexes to optimize query performance and stored procedures to automate common tasks. 

## 🚀 Features

- **Centralized Event Management**: All event data in one place for easy access and management.
- **Real-Time Ticket Tracking**: Monitor ticket status and availability.
- **Performance Reports**: Generate reports on event performance, sales, and attendance.
- **Resource Optimization**: Efficiently allocate resources for better event planning and execution.

## 🛠️ Technologies Used

- **SQL**: Core database management and queries.
- **DIA**: Used for designing the logical and entity-relationship diagrams.
  
## 📄 Technical Documentation

For a detailed overview of the database design, please refer to the attached technical document.
