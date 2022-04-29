import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Nav, Row, Tab,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrashCan, faUser } from '@fortawesome/free-regular-svg-icons';
import DeleteAccount from './DeleteAccount';
import AccountInfo from './AccountInfo';

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
                      <FontAwesomeIcon icon={faUser} className="pe-3" />
                      Account Info
                    </Nav.Link>
                  </Nav.Item>
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer" eventKey="second">
                      <FontAwesomeIcon icon={faTrashCan} className="pe-3" />
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
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
