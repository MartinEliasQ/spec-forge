# Product Planning Meeting — 2026-03-10

## Attendees
Sarah (PM), Alex (Engineering Lead), Jamie (Design)

## Discussion

### User Authentication
- We need a secure login system. Sarah emphasized that users should be able to log in with email/password and also with social accounts (Google, GitHub).
- Jamie wants the login page to be clean and minimal — no clutter.
- Alex mentioned we should rate-limit login attempts to prevent brute force.
- Password reset flow needs to be self-service via email.

### Dashboard
- First thing users see after login.
- Should show a summary of recent activity: last 5 actions, key metrics (total projects, pending tasks).
- Jamie wants a "quick actions" panel — create project, invite team member, view reports.
- Alex said we need real-time updates — when a team member makes changes, the dashboard should reflect it within a few seconds.

### Team Management
- Users need to invite team members via email.
- Role-based access: Admin, Editor, Viewer.
- Admins can remove team members and change roles.
- We need an activity log showing who did what and when.

### Open Questions
- Do we need SSO for enterprise customers? Sarah will check with sales.
- What's the notification strategy? Email only or in-app too? Deferred to next meeting.
