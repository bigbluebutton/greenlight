import React, { useState } from 'react';
import { Container, Table } from 'react-bootstrap';
import useServerRooms from '../../hooks/queries/admin/server_rooms/useServerRooms';
import ServerRoomRow from './server-rooms/ServerRoomRow';
import SearchBarQuery from '../shared/SearchBarQuery';

export default function ServerRooms() {
  const [input, setInput] = useState();
  const [serverRooms, setServerRooms] = useState();
  useServerRooms(input, setServerRooms);

  return (
    <Container id="admin-server-rooms">
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
          {serverRooms?.length
            ? (
              serverRooms?.map((room) => <ServerRoomRow key={room.id} room={room} />)
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
    </Container>
  );
}
