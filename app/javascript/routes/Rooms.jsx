import React, { useState, useEffect } from "react";
import axios from "axios"
import { Card, Row, Col, Container } from "react-bootstrap";
import RoomCard from "../components/RoomCard";


export default function Rooms() {

	const [rooms, setRooms] = useState([]);

	useEffect(() => {
		axios.get('/api/v1/rooms.json', {
			headers: {
				'Content-Type': 'application/json',
				'Accept': 'application/json'
			}
		})
			.then(function (resp) {
				setRooms(resp.data.data)
			})
	}, [])

	return (
		<>
			<h1>Rooms:</h1>
			<Container className='bg-secondary'>
				<Row md={4} className='g-4'>
					{rooms.map((room) => (
						<Col key={room.id}>
							<RoomCard id={room.friendly_id} name={room.name}> </RoomCard>
						</Col>
					))}
				</Row>
			</Container>
		</>
	)
}