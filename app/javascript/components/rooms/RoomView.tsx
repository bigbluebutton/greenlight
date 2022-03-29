import React, {useEffect, useState} from "react";
import axios from "axios"
import {Row, Col, Tabs, Tab} from "react-bootstrap";
import ButtonLink from "../stylings/buttons/ButtonLink";
import FeatureTabs from "./FeatureTabs";
import {Link, useParams} from "react-router-dom";
import {useQuery} from "react-query";
import Spinner from "../stylings/Spinner"
import {House} from "react-bootstrap-icons";

export default function RoomView() {
  const { friendly_id } = useParams()

  const { isLoading, error, data: room, isFetching } = useQuery("getRoom", () =>
    axios.get(`/api/v1/rooms/${friendly_id}.json`, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    }).then(resp => resp.data.data)
  );

  if (isLoading) return <Spinner animation="grow" />

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
