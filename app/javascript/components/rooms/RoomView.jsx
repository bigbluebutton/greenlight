import React from "react";
import axios from "axios"
import {Col, Row} from "react-bootstrap";
import ButtonLink from "../stylings/buttons/ButtonLink";
import FeatureTabs from "./FeatureTabs";
import {Link, useParams} from "react-router-dom";
import {useQuery} from "react-query";
import {Spinner} from "../stylings/Spinner"
import {House} from "react-bootstrap-icons";
import GetRoomQuery from "../../hooks/queries/rooms/GetRoomQuery";

export default function RoomView() {
  const { friendly_id } = useParams()

  const { isLoading, error, data: room, isFetching } = GetRoomQuery(friendly_id)

  if (isLoading) return <Spinner />

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
          <ButtonLink to="/" variant="primary" className="float-end">Start Session</ButtonLink>
        </Col>
      </Row>
      <FeatureTabs />
    </>
  )
}
