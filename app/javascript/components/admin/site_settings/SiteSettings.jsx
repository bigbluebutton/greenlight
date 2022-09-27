import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Tabs, Container,
} from 'react-bootstrap';
import AdminNavSideBar from '../AdminNavSideBar';
import Appearance from './appearance/Appearance';
import Administration from './administration/Administration';
import Settings from './settings/Settings';
import Registration from './registration/Registration';

export default function SiteSettings() {
  return (
    <div id="admin-panel">
      <h3 className="py-5"> Administrator Panel </h3>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="site-settings">
          <Row>
            <Col className="pe-0" sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col className="ps-0" sm={9}>
              <Tab.Content className="p-0">
                <Container className="admin-table p-0">
                  <div className="ps-4 pe-4 pt-4">
                    <h3> Customize Greenlight </h3>
                  </div>
                  <Tabs className="border-bottom ps-3" defaultActiveKey="appearance" unmountOnExit>
                    <Tab className="p-4" eventKey="appearance" title="Appearance">
                      <Appearance />
                    </Tab>
                    <Tab className="p-4" eventKey="administration" title="Administration">
                      <Administration />
                    </Tab>
                    <Tab className="p-4" eventKey="settings" title="Settings">
                      <Settings />
                    </Tab>
                    <Tab className="p-4" eventKey="registration" title="Registration">
                      <Registration />
                    </Tab>
                  </Tabs>
                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
