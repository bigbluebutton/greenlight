import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import FormControl from '../../../shared_components/forms/FormControl';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import useCreateInvitation from '../../../../hooks/mutations/admin/manage_users/useCreateInvitation';
import { createInvitationFormFields } from '../../../../helpers/forms/CreateInvitationHelpers';

export default function InviteUserForm({ handleClose }) {
  const { t } = useTranslation();
  const methods = useForm();
  const createInvitation = useCreateInvitation({ onSettled: handleClose });
  const { isSubmitting } = methods.formState;
  const fields = createInvitationFormFields;

  fields.emails.placeHolder = t('admin.manage_users.enter_user_email');

  return (
    <Form methods={methods} onSubmit={createInvitation.mutate}>
      <FormControl field={fields.emails} type="text" />

      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="neutral" className="ms-auto" onClick={handleClose}>
          {t('close')}
        </Button>
        <Button variant="brand" type="submit" disabled={isSubmitting}>
          { isSubmitting && <Spinner className="me-2" /> }
          { t('admin.manage_users.send_invitation') }
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
