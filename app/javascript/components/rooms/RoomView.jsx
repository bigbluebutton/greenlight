import React from "react";
import {Button, Col, Row} from "react-bootstrap";
import FeatureTabs from "./FeatureTabs";
import {Link, useParams} from "react-router-dom";
import {Spinner} from "../stylings/Spinner"
import {House} from "react-bootstrap-icons";
import GetRoomQuery from "../../hooks/queries/rooms/GetRoomQuery";
import usePostStartSession from "../../hooks/mutations/rooms/StartSession";

export default function RoomView() {
  const { friendly_id } = useParams()

  const { isLoading: queryIsLoading, data: room } = GetRoomQuery(friendly_id)
  const { handleStartSession, isLoading: startSessionIsLoading } = usePostStartSession(friendly_id)

  if (queryIsLoading) return <Spinner />

  return (
    <>
      <Row>
        <Col>
          <Link to="/rooms">
            <House />
          </Link>
        </Col>
      </Row>
      <Row className="my-5">
        <Col>
          { room.name }
        </Col>
        <Col>
          <Button variant="primary" className="float-end" onClick={handleStartSession} disabled={startSessionIsLoading} >
            Start Session {' '}
            { startSessionIsLoading && <Spinner/> }
          </Button>
        </Col>
      </Row>
      <FeatureTabs />
    </>
  )
}
