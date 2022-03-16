import React from "react";
import { Card, Row, Col } from "react-bootstrap";
import ButtonLink from "../components/stylings/buttons/ButtonLink";
import SignupForm from "../components/forms/SignupForm";

export default () => {
  return (
    <>
      <Row className="mt-2">
        <Col>
          <ButtonLink to="/" size="sm" variant="secondary">Home</ButtonLink>
        </Col>
      </Row>

      <Row className="mt-2">
        <Col md={{span: 6,offset:3}}>
          <Card className="d-flex m-auto">

              <Card.Body>
                  <Card.Title className="text-center">Signup Form</Card.Title>
                  <Row className="d-flex">
                    <Col>
                      <SignupForm/>
                    </Col>
                  </Row>
              </Card.Body>
      
          </Card>
        </Col>
      </Row>
    </>
  )
};
