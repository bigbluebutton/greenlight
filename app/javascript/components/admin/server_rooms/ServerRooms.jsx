import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Container, Row, Tab, Table,
} from 'react-bootstrap';
import useServerRooms from '../../../hooks/queries/admin/server_rooms/useServerRooms';
import ServerRoomRow from './ServerRoomRow';
import SearchBarQuery from '../../shared/SearchBarQuery';
import AdminNavSideBar from '../shared/AdminNavSideBar';
import Pagy from '../../shared/Pagy';

export default function ServerRooms() {
  const [input, setInput] = useState();
  const [page, setPage] = useState();
  const { isLoading, data: serverRooms } = useServerRooms(input, page);

  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="server-rooms">
          <Row>
            <Col sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col sm={9}>
              <Tab.Content className="p-3 ps-0">
                <Container className="admin-table">
                  <h2> Server Rooms </h2>
                  <div className="my-4">
                    <SearchBarQuery setInput={setInput} />
                  </div>
                  <Table className="table-bordered border border-2" hover>
                    <thead>
                      <tr className="text-muted small">
                        <th className="fw-normal border-end-0">Name</th>
                        <th className="fw-normal border-0">Owner</th>
                        <th className="fw-normal border-0">ID</th>
                        <th className="fw-normal border-0">Participants</th>
                        <th className="fw-normal border-0">Status</th>
                        <th className="border-start-0" aria-label="options" />
                      </tr>
                    </thead>
                    <tbody className="border-top-0">
                      {serverRooms?.data.length
                        ? (
                          serverRooms?.data.map((room) => <ServerRoomRow key={room.friendly_id} room={room} />)
                        )
                        : (
                          <tr>
                            <td className="fw-bold">
                              No recordings found!
                            </td>
                          </tr>
                        )}
                    </tbody>
                  </Table>
                  {!isLoading
                    && (
                    <Pagy
                      page={serverRooms.meta.page}
                      totalPages={serverRooms.meta.pages}
                      setPage={setPage}
                    />
                    )}
                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
