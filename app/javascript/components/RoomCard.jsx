import React, { useCallback } from "react";
import { useNavigate } from "react-router";
import { Card, Container } from "react-bootstrap";
import ButtonLink from "./stylings/buttons/ButtonLink";
import { PersonSquare, Link45deg } from 'react-bootstrap-icons';

export default function RoomCard(props) {
  const  {id, name} = props
  const navigate = useNavigate() 
  const handleClick = useCallback( () => { navigate(id)}, [id] )

  return (
    <Container>
      <Card style={{ width: '14rem' }} border='dark'>
        <Card.Body id='rooms-card' onClick={handleClick}>
          <PersonSquare size={30}/>
          <Card.Title> {name} </Card.Title>
          {/* TODO: Hadi- Make last session dynamic per room */}
          <Card.Text> Last session... </Card.Text>
          <hr />
          <Link45deg id='clipboard-icon' size={20}/>
          <ButtonLink to='#'> Start</ButtonLink>
        </Card.Body>
      </Card>
    </Container>
  )
}