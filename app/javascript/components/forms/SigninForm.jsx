import React from 'react';
import { Button, Col, Row, Stack, Form as BootstrapForm} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { Link } from 'react-router-dom';
import FormControl from './FormControl';
import Form from './Form';
import { signinFormFields, signinFormConfig } from '../../helpers/forms/SigninFormHelpers';
import Spinner from '../stylings/Spinner';
import useCreateSession from '../../hooks/mutations/sessions/useCreateSession';

export default function SigninForm() {
  const methods = useForm(signinFormConfig);
  const { onSubmit } = useCreateSession();
  const { isSubmitting } = methods.formState;
  const fields = signinFormFields;
  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <FormControl field={fields.email} type="email" />
      <FormControl field={fields.password} type="password" />
      <Row>
        <Col>
          <BootstrapForm.Group className="mb-2" controlId="formBasicCheckbox">
            <BootstrapForm.Check type="checkbox" label="Remember me" className="small" />
          </BootstrapForm.Group>
        </Col>
        <Col>
          <Link to="/" className="text-link float-end small"> Forgot password? </Link>
        </Col>
      </Row>
      <Stack className="mt-1" gap={1}>
        <Button variant="primary" className="w-100 my-3 py-2" type="submit" disabled={isSubmitting}>
          Sign In
          { isSubmitting && <Spinner /> }
        </Button>
      </Stack>
    </Form>
  );
}
