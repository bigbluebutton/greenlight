import React, { ReactElement } from "react";
import { Col, Container, Row } from "react-bootstrap";
import { Outlet } from "react-router-dom";
import CurrentUser from './components/user/CurrentUser';

const App: React.FC = (): ReactElement => (
        <Container fluid>
            <Row>
                <Col><CurrentUser /></Col>
            </Row>
            <Row>
                <Col><Outlet/></Col>
            </Row>
        </Container>
)

export default App
