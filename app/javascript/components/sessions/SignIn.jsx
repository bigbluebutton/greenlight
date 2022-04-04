import React from 'react';
import { useForm } from 'react-hook-form';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import Stack from 'react-bootstrap/Stack';
import { Link, useNavigate } from 'react-router-dom';
import { useMutation, useQueryClient } from 'react-query';
import {useCreateSession} from "../../hooks/mutations/sessions/useCreateSession";

export default function SignIn() {
  const { mutate } = useCreateSession();
  // Form handling needs access to mutate method from useMutation
  const { register, handleSubmit, formState: { errors } } = useForm();
  const handleSignIn = (sessionUser) => mutate(sessionUser);

  return (
    <Stack className="col-md-2 mx-auto">
      <h1> Sign In </h1>
      <Form onSubmit={handleSubmit(handleSignIn)} noValidate>
        <Form.Group className="mb-3" controlId="signInEmail">
          <Form.Label>Email:</Form.Label>
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
          <Form.Label>Password:</Form.Label>
          <Form.Control
            type="password"
            placeholder="Password"
            {...register('password', { required: 'Password is required.' })}
          />
          <Form.Text className="text-danger d-block">
            {errors?.password && errors.password.message}
          </Form.Text>
        </Form.Group>
        <Button type="submit" variant="primary">Sign In</Button>
      </Form>
      <Link to="/">Home</Link>
    </Stack>
  );
}
