import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateInvitation from '../../../../hooks/mutations/admin/manage_users/useCreateInvitation';
import useInviteUserForm from '../../../../hooks/forms/admin/manage_users/useInviteUserForm';

export default function InviteUserForm({ handleClose }) {
  const { t } = useTranslation();
  const createInvitationAPI = useCreateInvitation({ onSettled: handleClose });
  const { methods, fields } = useInviteUserForm();

  return (
    <Form methods={methods} onSubmit={createInvitationAPI.mutate}>
      <FormControl field={fields.emails} type="text" autoFocus />

      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="neutral" className="ms-auto" onClick={handleClose}>
          {t('close')}
        </Button>
        <Button variant="brand" type="submit" disabled={createInvitationAPI.isLoading}>
          {createInvitationAPI.isLoading && <Spinner className="me-2" />}
          {t('admin.manage_users.send_invitation')}
        </Button>
      </Stack>
    </Form>
  );
}

InviteUserForm.propTypes = {
  handleClose: PropTypes.func,
};

InviteUserForm.defaultProps = {
  handleClose: () => { },
};
