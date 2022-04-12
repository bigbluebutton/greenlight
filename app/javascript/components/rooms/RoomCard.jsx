import React, { useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card } from 'react-bootstrap';
import PropTypes from 'prop-types';
import ButtonLink from '../stylings/buttons/ButtonLink';
import {FontAwesomeIcon} from "@fortawesome/react-fontawesome";
import {faCopy} from "@fortawesome/free-regular-svg-icons";
import {faChalkboardUser} from "@fortawesome/free-solid-svg-icons";

export default function RoomCard(props) {
  const { id, name } = props;
  const navigate = useNavigate();
  const handleClick = useCallback(() => { navigate(id); }, [id]);

  return (
    <Card className="rooms-card" border="light">
      <Card.Body className="room-card-top pb-0" onClick={handleClick}>
        <FontAwesomeIcon icon={faChalkboardUser} size="3x" className="mb-4" />
        <Card.Title> {name} </Card.Title>
        {/* TODO: Hadi- Make last session dynamic per room */}
        <Card.Text className="text-muted"> Last session... </Card.Text>
        <hr />
      </Card.Body>
      <Card.Body className="pt-0">
        <FontAwesomeIcon icon={faCopy} size="lg"/>
        <ButtonLink variant="outline-secondary" className="float-end" to="#"> Start</ButtonLink>
      </Card.Body>
    </Card>
  );
}

RoomCard.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
};
