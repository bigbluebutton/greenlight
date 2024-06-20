// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
    <div id="admin-panel" className="pb-4">
      <h3 className="py-5">{ t('admin.admin_panel') }</h3>
      <Card className="border-0 card-shadow">
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
                    <Tab className="p-4" eventKey="appearance" title={t('admin.site_settings.appearance.appearance')}>
                      <Appearance />
                    </Tab>
                    <Tab className="p-4" eventKey="administration" title={t('admin.site_settings.administration.administration')}>
                      <Administration />
                    </Tab>
                    <Tab className="p-4" eventKey="settings" title={t('admin.site_settings.settings.settings')}>
                      <Settings />
                    </Tab>
                    <Tab className="p-4" eventKey="registration" title={t('admin.site_settings.registration.registration')}>
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
