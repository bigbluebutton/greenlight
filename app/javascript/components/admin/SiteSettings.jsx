import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Tabs, Container,
} from 'react-bootstrap';
import AdminNavSideBar from './shared/AdminNavSideBar';
import Appearance from './site_settings/Appearance';
import Administration from './site_settings/Administration';
import Settings from './site_settings/Settings';
import Registration from './site_settings/Registration';
import useSiteSetttings from '../../hooks/queries/admin/site-settings/useSiteSetttings';
import Spinner from '../shared/stylings/Spinner';

export default function SiteSettings() {
  const siteSettings = useSiteSetttings();

  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="site-settings">
          <Row>
            <Col sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col sm={9}>
              <Tab.Content className="p-3 ps-0">
                <Container className="admin-table">
                  <h2 className="my-4"> Customize Greenlight </h2>
                  <Row>
                    {
                      (siteSettings.isLoading && <Spinner />)
                      || (
                        <Tabs defaultActiveKey="appearance">
                          <Tab eventKey="appearance" title="Appearance">
                            <Appearance />
                          </Tab>
                          <Tab eventKey="administration" title="Administration">
                            <Administration
                              terms={siteSettings.data.Terms}
                              privacy={siteSettings.data.PrivacyPolicy}
                            />
                          </Tab>
                          <Tab eventKey="settings" title="Settings">
                            <Settings />
                          </Tab>
                          <Tab eventKey="registration" title="Registration">
                            <Registration setting={siteSettings.data.RoleMapping} />
                          </Tab>
                        </Tabs>
                      )
                    }
                  </Row>
                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
