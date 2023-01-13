import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Tabs, Container,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { Navigate } from 'react-router-dom';
import AdminNavSideBar from '../AdminNavSideBar';
import Appearance from './appearance/Appearance';
import Administration from './administration/Administration';
import Settings from './settings/Settings';
import Registration from './registration/Registration';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function SiteSettings() {
  const { t } = useTranslation();
  const currentUser = useAuth();

  if (currentUser.permissions?.ManageSiteSettings !== 'true') {
    return <Navigate to="/404" />;
  }

  return (
    <div id="admin-panel" className="pb-3">
      <h3 className="py-5">{ t('admin.admin_panel') }</h3>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="site_settings">
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
                    <h3>{ t('admin.site_settings.customize_greenlight') }</h3>
                  </div>
                  <Tabs className="border-bottom ps-3" defaultActiveKey="appearance" unmountOnExit>
                    <Tab className="p-4" eventKey="appearance" title={ t('admin.site_settings.appearance.appearance') }>
                      <Appearance />
                    </Tab>
                    <Tab className="p-4" eventKey="administration" title={ t('admin.site_settings.administration.administration') }>
                      <Administration />
                    </Tab>
                    <Tab className="p-4" eventKey="settings" title={ t('admin.site_settings.settings.settings') }>
                      <Settings />
                    </Tab>
                    <Tab className="p-4" eventKey="registration" title={ t('admin.site_settings.registration.registration') }>
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
