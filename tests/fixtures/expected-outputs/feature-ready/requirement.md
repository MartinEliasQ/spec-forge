# User Authentication & Access Control

The system provides secure authentication for all users, supporting both email/password login and social account providers. Users can reset their own passwords through a self-service email flow. Login attempts are rate-limited to prevent abuse.

Access is controlled through a role-based system with three levels: administrators who manage team settings and membership, editors who can modify project content, and viewers who have read-only access. Administrators can invite team members, change roles, and remove members. All access changes are logged for audit purposes.

This feature serves team leads who need to manage their team's access and team members who need secure, frictionless entry to the system.
