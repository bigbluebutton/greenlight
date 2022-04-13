import React from 'react';
import {
  Row, Col, Button, Spinner, Form, FormControl,
} from 'react-bootstrap';
import RoomCard from './RoomCard';
import useRooms from '../../hooks/queries/rooms/useRooms';
import ButtonLink from '../shared/stylings/buttons/ButtonLink';

export default function RoomsList() {
  const { isLoading, data: rooms } = useRooms();
  if (isLoading) return <Spinner />;

  return (
    <>
      <Row className="mt-4 mb-4">
        <Col>
          {/* TODO: May need to change search form when implementing search functionality */}
          <Form className="d-flex">
            <FormControl
              type="search"
              placeholder="Search"
              className=""
              style={{ width: '19rem' }}
              aria-label="Search"
            />
            <Button className="ms-2" variant="outline-secondary">Search</Button>
          </Form>
        </Col>
        <Col>
          {/* TODO: Set this button to create new room page */}
          <ButtonLink className="float-end" to="#"> + New Room </ButtonLink>
        </Col>
      </Row>
      <Row md={4} className="g-4">
        {rooms.map((room) => (
          <Col key={room.friendly_id}>
            <RoomCard id={room.friendly_id} name={room.name}> </RoomCard>
          </Col>
        ))}
      </Row>
    </>
  );
}
