import React from "react";
import { Row, Col, Container, Spinner } from "react-bootstrap";
import RoomCard from "../rooms/RoomCard";
import GetRoomsQuery from "../../hooks/queries/rooms/GetRoomsQuery";

export default function Rooms() {

  const { isLoading, error, data: rooms, isFetching } = GetRoomsQuery()

  if (isLoading) return <Spinner />

  return (
    <>
      <h1>Rooms:</h1>
      <Container className='bg-secondary'>
        <Row md={4} className='g-4'>
          {rooms.map((room) => (
            <Col key={room.friendly_id}>
              <RoomCard id={room.friendly_id} name={room.name}> </RoomCard>
            </Col>
          ))}
        </Row>
      </Container>
    </>
  )
}