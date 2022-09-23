import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControl from '../../../shared_components/forms/FormControl';
import { createRoomFormConfig, createRoomFormFields } from '../../../../helpers/forms/CreateRoomFormHelpers';
import { useAuth } from '../../../../contexts/auth/AuthProvider';

export default function CreateRoomForm({ mutation: useCreateRoomAPI, userId, handleClose }) {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const createRoomAPI = useCreateRoomAPI({ onSettled: handleClose, user_id: currentUser.id });
  createRoomFormConfig.defaultValues.user_id = userId;
  const methods = useForm(createRoomFormConfig);
  const { name } = createRoomFormFields;

  return (
    <Form methods={methods} onSubmit={createRoomAPI.mutate}>
      <FormControl field={name} type="text" />
      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="brand-outline" className="ms-auto" onClick={handleClose}>
          { t('close') }
        </Button>
        <Button variant="brand" type="submit" disabled={createRoomAPI.isLoading}>
          { t('room.create_room') }
          {createRoomAPI.isLoading && <Spinner />}
        </Button>
      </Stack>
    </Form>
  );
}

CreateRoomForm.propTypes = {
  handleClose: PropTypes.func,
  mutation: PropTypes.func.isRequired,
  userId: PropTypes.string.isRequired,
};

CreateRoomForm.defaultProps = {
  handleClose: () => { },
};
