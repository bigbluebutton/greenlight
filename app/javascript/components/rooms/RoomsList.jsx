import React, { useState } from 'react';
import {
  Row, Col, Button, Stack, Container,
} from 'react-bootstrap';
import { Pagination } from 'semantic-ui-react';
import Spinner from '../shared/stylings/Spinner';
import RoomCard from './RoomCard';
import useRooms from '../../hooks/queries/rooms/useRooms';
import useCreateRoom from '../../hooks/mutations/rooms/useCreateRoom';
import RoomPlaceHolder from './RoomPlaceHolder';
import Modal from '../shared/Modal';
import CreateRoomForm from '../forms/CreateRoomForm';
import SearchBar from '../shared/SearchBar';

export default function RoomsList() {
  const [page, setPage] = useState();
  const rooms = useRooms(page);
  const [search, setSearch] = useState('');

  if (rooms.isLoading) return <Spinner />;

  const roomsData = rooms.data.data;
  const roomsMeta = rooms.data.meta;

  const handlePage = (e, { activePage }) => {
    const gotopage = { activePage };
    const pagenum = gotopage.activePage;
    setPage(pagenum);
  };

  return (
    <div className="wide-background full-height-rooms">
      <Stack direction="horizontal" className="w-100 mt-5">
        <div>
          <SearchBar id="rooms-search" setSearch={setSearch} />
        </div>
        <Modal
          modalButton={<Button variant="brand" className="ms-auto">+ New Room </Button>}
          title="Create New Room"
          body={<CreateRoomForm mutation={useCreateRoom} />}
        />
      </Stack>
      <Row md={4} className="g-4 pb-4 mt-4">
        {
          roomsData.filter((room) => {
            if (room.name.toLowerCase().includes(search.toLowerCase())) {
              return room;
            }
            return false;
          }).map((room) => (
            <Col key={room.friendly_id} className="mt-0 mb-4">
              {(room.optimistic && <RoomPlaceHolder />) || <RoomCard room={room} />}
            </Col>
          ))
        }
      </Row>
      <Container className="text-center">
        <Pagination
          defaultActivePage={roomsMeta.page}
          totalPages={roomsMeta.pages}
          onPageChange={handlePage}
          firstItem={null}
          lastItem={null}
          pointing
          secondary
        />
      </Container>
    </div>
  );
}
