import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from '../../../forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControl from '../../../forms/FormControl';
import { createRoomFormConfig, createRoomFormFields } from '../../../../helpers/forms/CreateRoomFormHelpers';

export default function CreateRoomForm({ mutation: useCreateRoomAPI, handleClose }) {
  const createRoomAPI = useCreateRoomAPI({ onSettled: handleClose });
  const methods = useForm(createRoomFormConfig);

  const { name } = createRoomFormFields;

  return (
    <Form methods={methods} onSubmit={createRoomAPI.mutate}>
      <FormControl field={name} type="text" />
      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="brand-backward" className="ms-auto" onClick={handleClose}>
          Close
        </Button>
        <Button variant="brand" type="submit" disabled={createRoomAPI.isLoading}>
          Create Room
          {createRoomAPI.isLoading && <Spinner />}
        </Button>
      </Stack>
    </Form>
  );
}

CreateRoomForm.propTypes = {
  handleClose: PropTypes.func,
  mutation: PropTypes.func.isRequired,
};

CreateRoomForm.defaultProps = {
  handleClose: () => { },
};
