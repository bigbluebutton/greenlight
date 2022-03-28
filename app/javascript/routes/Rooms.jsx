import React from "react";
import axios from "axios"
import { Row, Col, Container, Spinner } from "react-bootstrap";
import RoomCard from "../components/RoomCard";
import {useQuery} from "react-query";

export default function Rooms() {

  const { isLoading, error, data: rooms, isFetching } = useQuery("getRooms", () =>
    axios.get('/api/v1/rooms.json', {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    })
    .then(resp => resp.data.data)
  );
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