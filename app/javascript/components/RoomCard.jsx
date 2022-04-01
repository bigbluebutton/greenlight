import React, { useCallback } from "react";
import { useNavigate } from "react-router";
import { Button, Card, Container } from "react-bootstrap";
import { PersonSquare, Link45deg } from 'react-bootstrap-icons';
import usePostStartSession from "../hooks/mutations/rooms/StartSession";
import { Spinner } from "./stylings/Spinner";

export default function RoomCard(props) {
  const  {id, name} = props
  const navigate = useNavigate()
  const navigateToRoomShow = useCallback( () => { navigate(id) }, [id] )
  const { handleStartSession, isLoading } = usePostStartSession(id)

  return (
    <Container>
      <Card className='rooms-card' style={{ width: '14rem' }} border='dark'>
        <Card.Body className='room-card-top' onClick={navigateToRoomShow}>
          <PersonSquare size={30}/>
          <Card.Title> {name} </Card.Title>
          {/* TODO: Hadi- Make last session dynamic per room */}
          <Card.Text> Last session... </Card.Text>
        </Card.Body>
        <Card.Body>
          <hr />
          <Link45deg id='clipboard-icon' size={20}/>
          <Button className='float-end' onClick={handleStartSession} disabled={isLoading} >
            Start {' '}
            { isLoading && <Spinner/> }
          </Button>
        </Card.Body>
      </Card>
    </Container>
  )
}