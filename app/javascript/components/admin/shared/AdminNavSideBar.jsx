import {
  AdjustmentsIcon, CogIcon, IdentificationIcon, ServerIcon, UsersIcon, VideoCameraIcon,
} from '@heroicons/react/outline';
import React from 'react';
import { Nav } from 'react-bootstrap';
import { Link } from 'react-router-dom';

export default function AdminNavSideBar() {
  return (
    <Nav variant="pills" className="flex-column">
      <Nav.Item>
        <Nav.Link className="cursor-pointer" as={Link} to="users" eventKey="users">
          <UsersIcon className="hi-s text-primary me-3" />
          Manage Users
        </Nav.Link>
      </Nav.Item>
      <Nav.Item>
        <Nav.Link className="cursor-pointer" as={Link} to="server-rooms" eventKey="server-rooms">
          <ServerIcon className="hi-s text-primary me-3" />
          Server Rooms
        </Nav.Link>
      </Nav.Item>
      <Nav.Item>
        <Nav.Link className="cursor-pointer" as={Link} to="server-recordings" eventKey="server-recordings">
          <VideoCameraIcon className="hi-s text-primary me-3" />
          Server Recordings
        </Nav.Link>
      </Nav.Item>
      <Nav.Item>
        <Nav.Link className="cursor-pointer" as={Link} to="site-settings" eventKey="site-settings">
          <CogIcon className="hi-s text-primary me-3" />
          Site Settings
        </Nav.Link>
      </Nav.Item>
      <Nav.Item>
        <Nav.Link className="cursor-pointer" as={Link} to="room-configuration" eventKey="room-configuration">
          <AdjustmentsIcon className="hi-s text-primary me-3" />
          Room Configuration
        </Nav.Link>
      </Nav.Item>
      <Nav.Item>
        <Nav.Link className="cursor-pointer" as={Link} to="roles" eventKey="roles">
          <IdentificationIcon className="hi-s text-primary me-3" />
          Roles
        </Nav.Link>
      </Nav.Item>
    </Nav>
  );
}
