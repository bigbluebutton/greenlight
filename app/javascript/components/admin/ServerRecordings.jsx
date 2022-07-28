import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Container, Row, Tab, Stack, Button,
} from 'react-bootstrap';
import AdminNavSideBar from './shared/AdminNavSideBar';
import SearchBarQuery from '../shared/SearchBarQuery';
import RecordingsList from '../recordings/RecordingsList';
import useServerRecordings from '../../hooks/queries/admin/server-recordings/useServerRecordings';
import ServerRecordingRow from './server-recordings/ServerRecordingRow';
import useRecordingsReSync from '../../hooks/queries/recordings/useRecordingsReSync';
import Pagy from '../shared/Pagy';

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
            <Col sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col sm={9}>
              <Tab.Content className="p-3 ps-0">
                <Container>
                  <Row className="my-1"><h3>Latest Recordings</h3></Row>
                  <Row><hr className="w-100 mx-0" /></Row>
                  <Stack className="my-4" direction="horizontal">
                    <div><SearchBarQuery setInput={setInput} /></div>
                    <Button variant="brand-backward" className="ms-auto" onClick={recordingsReSync.refetch}>Re-Sync Recordings</Button>
                  </Stack>
                  <Row className="my-2">
                    <Col>
                      <RecordingsList
                        recordings={serverRecordings?.data}
                        isLoading={isLoading}
                        RecordingRow={ServerRecordingRow}
                      />
                    </Col>
                    {!isLoading
                      && (
                      <Pagy
                        page={serverRecordings.meta.page}
                        totalPages={serverRecordings.meta.pages}
                        setPage={setPage}
                      />
                      )}
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
