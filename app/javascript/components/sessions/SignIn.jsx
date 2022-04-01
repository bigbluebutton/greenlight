import React from 'react';
import { useForm } from 'react-hook-form';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import Col from 'react-bootstrap/Col';
import Row from 'react-bootstrap/Row';
import { Link, useNavigate } from 'react-router-dom';
import { useMutation, useQueryClient } from 'react-query';

export default function SignIn() {
  // POST request to server to create a session using email and password from Sign In form.
  async function createSession(sessionUser) {
    const response = await fetch('/api/v1/sessions.json', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({
        session: {
          email: sessionUser.email,
          password: sessionUser.password,
        },
      }),
    });
    if (!response.ok) throw new Error('Email or password is incorrect.');
    return response.json();
  }

  // React Query useMutation
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { mutate, error } = useMutation(createSession, {
    // Re-fetch the current_user and redirect to homepage if Mutation is successful.
    onSuccess: () => {
      queryClient.invalidateQueries('current_user');
      navigate('/rooms');
      console.log('mutate success');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
  });

  // Form handling needs access to mutate method from useMutation
  const { register, handleSubmit, formState: { errors } } = useForm();
  const handleSignIn = (sessionUser) => mutate(sessionUser);
  return (
    <Card className="col-md-4 mx-auto p-4">
      <h2 className="text-center py-4"> Sign In </h2>
      <Form onSubmit={handleSubmit(handleSignIn)} noValidate>
        <Form.Group className="mb-3" controlId="signInEmail">
          <Form.Label>Email</Form.Label>
          <Form.Control
            type="email"
            placeholder="Email"
            {...register('email', { required: 'Email is required.' })}
          />
          <Form.Text className="text-danger d-block">
            {errors?.email && errors.email.message}
          </Form.Text>
        </Form.Group>
        <Form.Group className="mb-3" controlId="signInPassword">
          <Form.Label>Password</Form.Label>
          <Form.Control
            type="password"
            placeholder="Password"
            {...register('password', { required: 'Password is required.' })}
          />
          <Form.Text className="text-danger d-block">
            {errors?.password && errors.password.message}
          </Form.Text>
        </Form.Group>
        <Button className="w-100 my-3 py-2" type="submit" variant="primary">Sign In</Button>
      </Form>
    </Card>

  );
}
