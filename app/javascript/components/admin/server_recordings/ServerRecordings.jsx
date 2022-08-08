import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Container, Row, Tab, Stack, Button,
} from 'react-bootstrap';
import AdminNavSideBar from '../AdminNavSideBar';
import SearchBarQuery from '../../shared_components/search/SearchBarQuery';
import RecordingsList from '../../recordings/RecordingsList';
import useServerRecordings from '../../../hooks/queries/admin/server_recordings/useServerRecordings';
import ServerRecordingRow from './ServerRecordingRow';
import useRecordingsReSync from '../../../hooks/queries/recordings/useRecordingsReSync';
import Pagination from '../../shared_components/Pagination';

export default function ServerRecordings() {
  const [input, setInput] = useState();
  const [page, setPage] = useState();
  const { isLoading, data: serverRecordings } = useServerRecordings(input, page);
  const recordingsReSync = useRecordingsReSync();

  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="server-recordings">
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
                    <h2> Latest Recordings </h2>
                  </div>
                  <div className="p-4">
                    <Stack direction="horizontal" className="mb-4">
                      <SearchBarQuery setInput={setInput} />
                      <Button
                        variant="brand-backward"
                        className="ms-auto"
                        onClick={recordingsReSync.refetch}
                      > Re-Sync Recordings
                      </Button>
                    </Stack>
                    <Row className="my-2">
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
                              borders
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
