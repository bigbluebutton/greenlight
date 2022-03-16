import React from "react";
import { Col, Container, Row } from "react-bootstrap";
import { Outlet } from "react-router-dom";
import ButtonLink from "./components/stylings/buttons/ButtonLink";

export default () => (
        <Container fluid>
            <Row>
                <Col>
                    <ButtonLink to="signup">Signup</ButtonLink>
                </Col>
            </Row>
            <Row>
                <Col><Outlet/></Col>
            </Row>
        </Container>
)