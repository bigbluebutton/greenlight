import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Nav, Row, Tab,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  faGear, faServer, faSliders, faUserCheck, faUsers, faVideo,
} from '@fortawesome/free-solid-svg-icons';
import ServerRecordings from './ServerRecordings';
import ManageUsers from './ManageUsers';
import ServerRooms from './ServerRooms';
import SiteSettings from './SiteSettings';
import RoomConfig from './RoomConfig';
import Roles from './Roles';

export default function AdminPanel() {
  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container defaultActiveKey="first">
          <Row>
            <Col sm={3}>
              <div id="admin-sidebar">
                <Nav variant="pills" className="flex-column">
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer" eventKey="first">
                      <FontAwesomeIcon icon={faUsers} className="pe-3" />
                      Manage Users
                    </Nav.Link>
                  </Nav.Item>
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer" eventKey="second">
                      <FontAwesomeIcon icon={faServer} className="pe-3" />
                      Server Rooms
                    </Nav.Link>
                  </Nav.Item>
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer" eventKey="third">
                      <FontAwesomeIcon icon={faVideo} className="pe-3" />
                      Server Recordings
                    </Nav.Link>
                  </Nav.Item>
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer" eventKey="fourth">
                      <FontAwesomeIcon icon={faGear} className="pe-3" />
                      Site Settings
                    </Nav.Link>
                  </Nav.Item>
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer" eventKey="fifth">
                      <FontAwesomeIcon icon={faSliders} className="pe-3" />
                      Room Configuration
                    </Nav.Link>
                  </Nav.Item>
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer" eventKey="sixth">
                      <FontAwesomeIcon icon={faUserCheck} className="pe-3" />
                      Roles
                    </Nav.Link>
                  </Nav.Item>
                </Nav>
              </div>
            </Col>
            <Col sm={9}>
              <Tab.Content className="p-3 ps-0">
                <Tab.Pane eventKey="first">
                  <ManageUsers />
                </Tab.Pane>
                <Tab.Pane eventKey="second">
                  <ServerRooms />
                </Tab.Pane>
                <Tab.Pane eventKey="third">
                  <ServerRecordings />
                </Tab.Pane>
                <Tab.Pane eventKey="fourth">
                  <SiteSettings />
                </Tab.Pane>
                <Tab.Pane eventKey="fifth">
                  <RoomConfig />
                </Tab.Pane>
                <Tab.Pane eventKey="sixth">
                  <Roles />
                </Tab.Pane>

              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
