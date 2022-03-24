import React from "react";
import { FaRegUser } from 'react-icons/fa'
import { FiCopy } from 'react-icons/fi'
import { Card } from "react-bootstrap";
import ButtonLink from "./stylings/buttons/ButtonLink";

export default function RoomCard(props) {
  const  {name} = props

  return (
    <Card style={{ width: '14rem' }} border='dark'>
      <Card.Body>
          <FaRegUser size={25}/>
          <Card.Title> {name} </Card.Title>
          <Card.Text> Last session... </Card.Text>
          <hr />
          <FiCopy size={25}/>
          <ButtonLink to='#'> Start </ButtonLink>
      </Card.Body>
    </Card>
  )
}