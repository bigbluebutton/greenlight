import React from 'react';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControl from '../../../shared_components/forms/FormControl';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import useRoomForm from '../../../../hooks/forms/rooms/useRoomForm';

export default function CreateRoomForm({ mutation: useCreateRoomAPI, userId, handleClose }) {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const createRoomAPI = useCreateRoomAPI({ onSettled: handleClose, user_id: currentUser.id });
  const { methods, fields } = useRoomForm({ defaultValues: { user_id: userId } });

  return (
    <Form methods={methods} onSubmit={createRoomAPI.mutate}>
      <FormControl field={fields.name} type="text" />
      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="neutral" className="ms-auto" onClick={handleClose}>
          { t('close') }
        </Button>
        <Button variant="brand" type="submit" disabled={createRoomAPI.isLoading}>
          {createRoomAPI.isLoading && <Spinner className="me-2" />}
          { t('room.create_room') }
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
