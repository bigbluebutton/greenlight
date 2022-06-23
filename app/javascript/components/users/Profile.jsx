import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Nav, Row, Tab,
} from 'react-bootstrap';
import { TrashIcon, UserIcon, LockClosedIcon } from '@heroicons/react/outline';
import DeleteAccount from './DeleteAccount';
import AccountInfo from './AccountInfo';
import ChangePassword from './ChangePassword';

export default function Profile() {
  return (
    <div id="profile" className="wide-background">
      <h2 className="my-5"> Profile </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container id="profile-wrapper" defaultActiveKey="first">
          <Row>
            <Col sm={3}>
              <div id="profile-sidebar">
                <Nav variant="pills" className="flex-column">
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer" eventKey="first">
                      <UserIcon className="w-24 text-primary me-3" />
                      Account Info
                    </Nav.Link>
                  </Nav.Item>
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer" eventKey="third">
                      <LockClosedIcon className="w-24 text-primary me-3" />
                      Change Password
                    </Nav.Link>
                  </Nav.Item>
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer" eventKey="second">
                      <TrashIcon className="w-24 text-primary me-3" />
                      Delete Account
                    </Nav.Link>
                  </Nav.Item>
                </Nav>
              </div>
            </Col>
            <Col sm={9}>
              <Tab.Content className="p-3 ps-0">
                <Tab.Pane eventKey="first">
                  <AccountInfo />
                </Tab.Pane>
                <Tab.Pane eventKey="second">
                  <DeleteAccount />
                </Tab.Pane>
                <Tab.Pane eventKey="third">
                  <ChangePassword />
                </Tab.Pane>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
