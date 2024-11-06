# Incident Management System

## Overview

This Incident Management System is built with Ruby on Rails, leveraging Turbo and Hotwire for real-time features. It allows users to create, view, edit, and manage incident tickets without requiring authentication.

## Features

- **Main Landing Page:** Overview of all incidents.
- **Create Incident Ticket:** Submit new incidents with a title and description.
- **Dynamic Priority Assignment:** Upon submission, a randomized priority level is suggested.
- **Confirmation Prompt:** Users can choose to accept the recommended priority or retain their original selection.
- **Incident Details:** View detailed information about each incident.
- **Incident Management:** Close, edit, or delete tickets.

## Setup & Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/incident_management.git
   cd incident_management
   ```

2. **Install Dependencies:**

   Ensure you have Ruby and Bundler installed.

   ```bash
   bundle install
   ```

3. **Setup Database:**

   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Run the Server:**

   ```bash
   rails server
   ```

   Visit `http://localhost:3000` to access the application.

## Usage

- **Create an Incident:** Click on "New Incident" and fill out the form.
- **Confirm Priority:** After submission, confirm the recommended priority.
- **Manage Incidents:** View all incidents, and use the options to edit, close, or delete each incident.

## Technology Stack

- **Backend:** Ruby on Rails
- **Frontend:** Turbo and Hotwire for real-time updates
- **Database:** SQLite (can be configured to use PostgreSQL in production)

## Security Considerations

- **Data Validation:** Ensures all necessary fields are present and valid.
- **Strong Parameters:** Protects against mass assignment vulnerabilities.
- **No Authentication:** Since there's no login, ensure the application is deployed in a secure environment.

## Future Enhancements

- **Authentication:** Implement user login for secure access.
- **Email Notifications:** Notify administrators of new incidents.
- **Advanced Priority Logic:** Enhance the priority assignment mechanism based on incident details.

## License

MIT License
