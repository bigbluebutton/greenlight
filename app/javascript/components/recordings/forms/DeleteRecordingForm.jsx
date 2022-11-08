import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Form from '../../shared_components/forms/Form';
import Spinner from '../../shared_components/utilities/Spinner';

export default function DeleteRecordingForm({ mutation: useDeleteAPI, recordId, handleClose }) {
  const { t } = useTranslation();
  const methods = useForm();
  const deleteAPI = useDeleteAPI({ recordId, onSettled: handleClose });

  return (
    <>
      <p className="text-center"> { t('recording.are_you_sure_delete_recording') }</p>
      <Form methods={methods} onSubmit={deleteAPI.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="neutral" onClick={handleClose}>
            { t('close') }
          </Button>
          <Button variant="danger" type="submit" disabled={deleteAPI.isLoading}>
            { t('delete') }
            {deleteAPI.isLoading && <Spinner />}
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeleteRecordingForm.propTypes = {
  handleClose: PropTypes.func,
  recordId: PropTypes.string,
  mutation: PropTypes.func.isRequired,
};

DeleteRecordingForm.defaultProps = {
  handleClose: () => { },
  recordId: -1,
};
