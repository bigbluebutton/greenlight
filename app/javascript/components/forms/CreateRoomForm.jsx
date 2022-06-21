import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from './Form';
import Spinner from '../shared/stylings/Spinner';
import useCreateRoom from '../../hooks/mutations/rooms/useCreateRoom';
import FormControl from './FormControl';
import { createRoomFormConfig, createRoomFormFields } from '../../helpers/forms/CreateRoomFormHelpers';

export default function CreateRoomForm({ handleClose, userID }) {
  createRoomFormConfig.defaultValues.user_id = userID;

  const methods = useForm(createRoomFormConfig);
  const { handleCreateRoom: onSubmit } = useCreateRoom({ onSettled: handleClose });
  const { isSubmitting } = methods.formState;
  const fields = createRoomFormFields;

  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <FormControl field={fields.name} type="text" />
      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="primary-light" className="ms-auto" onClick={handleClose}>
          Close
        </Button>
        <Button variant="primary" type="submit" disabled={isSubmitting}>
          Create Room
          {isSubmitting && <Spinner />}
        </Button>
      </Stack>
    </Form>
  );
}

CreateRoomForm.propTypes = {
  handleClose: PropTypes.func,
  userID: PropTypes.number.isRequired,
};

CreateRoomForm.defaultProps = {
  handleClose: () => { },
};
