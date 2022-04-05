import React from 'react';
import { useForm } from 'react-hook-form';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import useCreateSession from '../../hooks/mutations/sessions/useCreateSession';

export default function SignIn() {
  const { register, handleSubmit, formState: { errors } } = useForm();
  const { handleSignIn } = useCreateSession();

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
