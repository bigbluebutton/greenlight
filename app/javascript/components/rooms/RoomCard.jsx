import React, { useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, Container } from 'react-bootstrap';
import { PersonSquare, Link45deg } from 'react-bootstrap-icons';
import ButtonLink from '../stylings/buttons/ButtonLink';

export default function RoomCard(props) {
  const { id, name } = props;
  const navigate = useNavigate();
  const handleClick = useCallback(() => { navigate(id); }, [id]);

  return (
    <Container>
      <Card id='rooms-card' style={{ width: '14rem' }} border='light'>
        <Card.Body id='room-card-top' onClick={handleClick}>
          <PersonSquare className='mb-4' size={55}/>
          <Card.Title> {name} </Card.Title>
          {/* TODO: Hadi- Make last session dynamic per room */}
          <Card.Text className='text-muted'> Last session... </Card.Text>
          <hr />
        </Card.Body>
        <Card.Body>
          <Link45deg id='clipboard-icon' size={20}/>
          <ButtonLink variant="outline-secondary" className='float-end' to='#'> Start</ButtonLink>
        </Card.Body>
      </Card>
    </Container>
  )
}
