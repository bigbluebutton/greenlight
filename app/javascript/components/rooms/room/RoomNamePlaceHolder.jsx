import React from "react";
import Placeholder from "../../shared_components/utilities/Placeholder";
import { Row, Col, Stack } from "react-bootstrap";

export default function RoomNamePlaceHolder() {
  return (
    <Stack className="room-header-wrapper">
      <Placeholder width={8} size="lg" className="me-2" />
      <Placeholder width={6} size="lg" className="me-2" />
    </Stack>
  );
}
