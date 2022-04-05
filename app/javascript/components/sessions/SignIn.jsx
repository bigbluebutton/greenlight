/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import { useForm } from 'react-hook-form';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import { Link } from 'react-router-dom';
import { Col, Row } from 'react-bootstrap';
import FormLogo from '../forms/FormLogo';
import useCreateSession from '../../hooks/mutations/sessions/useCreateSession';

export default function SignIn() {
  const { register, handleSubmit, formState: { errors } } = useForm();
  const { handleSignIn } = useCreateSession();

  return (
    <>
      <FormLogo />
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> Sign In </Card.Title>
        <Form onSubmit={handleSubmit(handleSignIn)} noValidate>
          <Form.Group className="mb-2" controlId="signInEmail">
            <Form.Label className="small mb-0">Email</Form.Label>
            <Form.Control
              type="email"
              placeholder="Email"
              {...register('email', { required: 'Email is required.' })}
            />
            <Form.Text className="text-danger d-block">
              {errors?.email && errors.email.message}
            </Form.Text>
          </Form.Group>
          <Form.Group className="mb-2" controlId="signInPassword">
            <Form.Label className="small mb-0">Password</Form.Label>
            <Form.Control
              type="password"
              placeholder="Password"
              {...register('password', { required: 'Password is required.' })}
            />
            <Form.Text className="text-danger d-block">
              {errors?.password && errors.password.message}
            </Form.Text>
          </Form.Group>
          <Row>
            <Col>
              <Form.Group className="mb-2" controlId="formBasicCheckbox">
                <Form.Check type="checkbox" label="Remember me" className="small" />
              </Form.Group>
            </Col>
            <Col>
              <Link to="/" className="text-link float-end small"> Forgot password? </Link>
            </Col>
          </Row>
          <Button className="w-100 my-3 py-2" type="submit" variant="primary">Sign In</Button>
        </Form>
        <span className="text-center text-muted small"> Don&apos;t have an account?
          <Link to="/signup" className="text-link"> Sign up </Link>
        </span>
      </Card>
    </>
  );
}
