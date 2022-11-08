import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Container, Row, Tab,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import AdminNavSideBar from '../AdminNavSideBar';
import SearchBar from '../../shared_components/search/SearchBar';
import RecordingsList from '../../recordings/RecordingsList';
import useServerRecordings from '../../../hooks/queries/admin/server_recordings/useServerRecordings';
import ServerRecordingRow from './ServerRecordingRow';
import Pagination from '../../shared_components/Pagination';
import {useAuth} from "../../../contexts/auth/AuthProvider";
import {Navigate} from "react-router-dom";

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
    <div id="admin-panel" className="pb-3">
      <h3 className="py-5"> {t('admin.admin_panel')} </h3>
      <Card className="border-0 shadow-sm">
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
                  <div className="p-4">
                    <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
                    <Row className="mt-4">
                      <Col>
                        <RecordingsList
                          recordings={serverRecordings?.data}
                          isLoading={isLoading}
                          RecordingRow={ServerRecordingRow}
                        />
                        {!isLoading
                          && (
                            <Pagination
                              page={serverRecordings.meta.page}
                              totalPages={serverRecordings.meta.pages}
                              setPage={setPage}
                            />
                          )}
                      </Col>
                    </Row>
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
