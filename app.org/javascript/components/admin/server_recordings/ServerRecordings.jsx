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

import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Container, Row, Tab,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { Navigate } from 'react-router-dom';
import AdminNavSideBar from '../AdminNavSideBar';
import RecordingsList from '../../recordings/RecordingsList';
import useServerRecordings from '../../../hooks/queries/admin/server_recordings/useServerRecordings';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function ServerRecordings() {
  const { t } = useTranslation();
  const [searchInput, setSearchInput] = useState();
  const [page, setPage] = useState();
  const { isLoading, data: serverRecordings } = useServerRecordings(searchInput, page);
  const currentUser = useAuth();

  if (currentUser.permissions?.ManageRecordings !== 'true') {
    return <Navigate to="/404" />;
  }

  return (
    <div id="admin-panel" className="pb-4">
      <h3 className="py-5"> {t('admin.admin_panel')} </h3>
      <Card className="border-0 card-shadow">
        <Tab.Container activeKey="server_recordings">
          <Row>
            <Col className="pe-0" sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col className="ps-0" sm={9}>
              <Tab.Content className="p-0">
                <Container className="admin-table p-0">
                  <div className="p-4 border-bottom">
                    <h3> {t('admin.server_recordings.latest_recordings')} </h3>
                  </div>
                  <div id="server-recordings" className="p-4">
                    <RecordingsList
                      adminTable
                      recordings={serverRecordings}
                      isLoading={isLoading}
                      setPage={setPage}
                      setSearchInput={setSearchInput}
                      searchInput={searchInput}
                    />
                  </div>
                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
