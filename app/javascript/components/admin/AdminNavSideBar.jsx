import {
  AdjustmentsIcon, CogIcon, IdentificationIcon, ServerIcon, UsersIcon, VideoCameraIcon,
} from '@heroicons/react/outline';
import React from 'react';
import { Nav } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function AdminNavSideBar() {
  const currentUser = useAuth();
  return (
    <Nav variant="pills" className="flex-column">
      <Nav.Item>
        <Nav.Link className="cursor-pointer text-muted" as={Link} to="/adminpanel/users" eventKey="users">
          <UsersIcon className="hi-s me-3" />
          Manage Users
        </Nav.Link>
      </Nav.Item>
      {(currentUser.permissions.ManageRooms === 'true') && (
        <Nav.Item>
          <Nav.Link className="cursor-pointer text-muted" as={Link} to="/adminpanel/server-rooms" eventKey="server-rooms">
            <ServerIcon className="hi-s me-3" />
            Server Rooms
          </Nav.Link>
        </Nav.Item>
      )}
      <Nav.Item>
        <Nav.Link className="cursor-pointer text-muted" as={Link} to="/adminpanel/server-recordings" eventKey="server-recordings">
          <VideoCameraIcon className="hi-s me-3" />
          Server Recordings
        </Nav.Link>
      </Nav.Item>
      <Nav.Item>
        <Nav.Link className="cursor-pointer text-muted" as={Link} to="/adminpanel/site-settings" eventKey="site-settings">
          <CogIcon className="hi-s me-3" />
          Site Settings
        </Nav.Link>
      </Nav.Item>
      <Nav.Item>
        <Nav.Link className="cursor-pointer text-muted" as={Link} to="/adminpanel/room-configuration" eventKey="room-configuration">
          <AdjustmentsIcon className="hi-s me-3" />
          Room Configuration
        </Nav.Link>
      </Nav.Item>
      {(currentUser.permissions.ManageRoles === 'true') && (
      <Nav.Item>
        <Nav.Link className="cursor-pointer text-muted" as={Link} to="/adminpanel/roles" eventKey="roles">
          <IdentificationIcon className="hi-s me-3" />
          Roles
        </Nav.Link>
      </Nav.Item>
      )}
    </Nav>
  );
}
