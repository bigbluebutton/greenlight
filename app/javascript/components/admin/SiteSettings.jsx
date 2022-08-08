import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Tabs, Container,
} from 'react-bootstrap';
import AdminNavSideBar from './shared/AdminNavSideBar';
import Appearance from './site_settings/appearance/Appearance';
import Administration from './site_settings/Administration';
import Settings from './site_settings/Settings';
import Registration from './site_settings/Registration';
import Spinner from '../shared_components/utilities/Spinner';
import useSiteSettings from '../../hooks/queries/admin/site_settings/useSiteSettings';

export default function SiteSettings() {
  const { isLoading, data: siteSettings } = useSiteSettings();

  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
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
                    <h2> Customize Greenlight </h2>
                  </div>
                  {
                    (isLoading && <Spinner />)
                    || (
                      <Tabs className="border-bottom ps-3" defaultActiveKey="appearance">
                        <Tab className="p-4" eventKey="appearance" title="Appearance">
                          <Appearance />
                        </Tab>
                        <Tab className="p-4" eventKey="administration" title="Administration">
                          <Administration
                            terms={siteSettings.Terms}
                            privacy={siteSettings.PrivacyPolicy}
                          />
                        </Tab>
                        <Tab className="p-4" eventKey="settings" title="Settings">
                          <Settings />
                        </Tab>
                        <Tab className="p-4" eventKey="registration" title="Registration">
                          <Registration value={siteSettings.RoleMapping} />
                        </Tab>
                      </Tabs>
                    )
                  }

                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
